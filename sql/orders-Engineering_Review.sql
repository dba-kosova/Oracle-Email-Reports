select
    oha.order_number "Order Number",
    ola.line_number "Line Number",
    ola.shipment_number "Shipment Number",
    ola.attribute18   "ER number",
    ola.creation_date "Creation Date",
    ola.ordered_item "Type",
    ola.request_date "Request Date",
    ola.ordered_quantity "Quantity",
    user_item_description "Part Number"
from
    oe_order_lines_all ola,
    oe_order_headers_all oha
where
    ola.ordered_item in (
        'ERR_INVALID_ITEM',
        'ENG_REVIEW'
    )
    and ola.header_id = oha.header_id
    and oha.org_id = 83
    and oha.booked_flag = 'Y'
    and ola.open_flag = 'Y'
    and ola.cancelled_flag = 'N'
    order by ola.creation_date asc