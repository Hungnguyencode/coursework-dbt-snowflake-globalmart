
{{ config(materialized='view') }}

SELECT
    CUSTOMERID,
    CUSTOMERNAME,
    SEGMENT,
    COUNTRY,
    STATE
FROM RAW.GLOBALMART.CUSTOMERS
