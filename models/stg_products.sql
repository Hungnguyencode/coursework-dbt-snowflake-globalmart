
{{ config(materialized='view') }}

SELECT
    CATEGORY,
    PRODUCTID,
    PRODUCTNAME,
    SUBCATEGORY
FROM RAW.GLOBALMART.PRODUCTS
