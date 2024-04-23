{{
    config(
        materialized="incremental",
        unique_key="metadata_content_key",
        tags=["cortex_enabled"],
    )
}}

with
    contracts as (select * from {{ ref("int_contracts_load_into_vectordb") }}),

    processed as (
        select
            *,
            replace(
                snowflake.cortex.complete(
                    'mistral-large',  -- 'mixtral-8x7b',  -- mistral-7b
                    concat(
                        '
                    You are an expert in reading supplier contracts and classifying payment terms. Examine the relevant text. Provide a result. If not relevant terms are found just say "None"
                    Just include terms from this list. DO NOT INCLUDE OTHER INFORMATION, REASONING OR EXPLANATION OR THE WORD RESPONSE, JUST OUTPUT THE TERMS.
                    Output Options: Net30, 2/10 Net30, Net10, Net15, COD, COA, None,

                    {description}
                    ',
                        -- retrieves the relevant contract context
                        procure_agent.public.retrieve_context(
                            concat('what are the payment terms', ' | ', supplier_name)
                        )
                    )
                ),
                '.',
                ''
            ) as payment_term_extract,
            trim(
                snowflake.cortex.complete(
                    'mistral-large',  -- 'mixtral-8x7b',  -- mistral-7b
                    concat(
                        '
                    You are an expert in reading supplier contracts. Identify if there are any rebate terms offered in the contract.
                    If not just say "None" with NO PERIOD OR PUNCTUATION!!!!
                    Keep your response brief and do note provide REASONING OR EXPLANATION.
                    Example Outputs: 2% after exeeding $500,000 in annual spend

                    {description}
                    ',
                        -- retrieve the relevant context
                        procure_agent.public.retrieve_context(
                            concat(
                                'What are the rebate offerings for the supplier?',
                                ' | ',
                                supplier_name
                            )
                        )
                    )
                )
            ) as offered_rebates,
            iff(
                contains(offered_rebates, 'None') = true, false, true
            ) as supplier_has_rebate
        from contracts

    )

select *
from processed
{% if is_incremental() %}
    where processed_at > (select max(processed_at) from {{ this }})
{% endif %}
