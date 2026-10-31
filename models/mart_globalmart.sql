
{{ config(materialized='view') }}

SELECT
    o.ORDERID,
    o.ORDERDATE,
    o.SHIPDATE,
    o.SHIPMODE,

    o.CUSTOMERID,
    c.CUSTOMERNAME,
    c.SEGMENT,
    c.COUNTRY,
    c.STATE,

    o.PRODUCTID,
    p.CATEGORY,
    p.PRODUCTNAME,
    p.SUBCATEGORY,
    p.NAME_CONFLICT,

    o.ORDERCOSTPRICE,
    o.ORDERSELLINGPRICE,
    o.ORDERPROFIT

FROM {{ ref('fct_orders') }} AS o

LEFT JOIN {{ ref('stg_customers') }} AS c
    ON o.CUSTOMERID = c.CUSTOMERID

LEFT JOIN {{ ref('dim_products') }} AS p
    ON o.PRODUCTID = p.PRODUCTID
