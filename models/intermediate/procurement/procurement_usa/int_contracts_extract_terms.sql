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
                    'mistral-7b',  -- 'mixtral-8x7b',  -- mistral-7b
                    concat(
                        '
                    You are an expert in reading supplier contracts and classifying payment terms. Examine the relevant text. Provide a result. If not relevant terms are found just say "None"
                    Just include terms from this list. DO NOT INCLUDE OTHER INFORMATION, REASONING OR EXPLANATION OR THE WORD RESPONSE, JUST OUTPUT THE TERMS.
                    Output Options: Net30, 2/10 Net30, Net10, Net15, COD, COA, None,

                    {description}
                    ',
                        procure_agent.public.retrieve_context(
                            concat(
                                'what are the payment term discounts', ' | ', supplier_name
                            )
                        )
                    )
                ),
                '.',
                ''
            ) as payment_term_extract
        from contracts

    )

select *
from processed
{% if is_incremental() %}
    where processed_time > (select max(processed_time) from {{ this }})
{% endif %}
