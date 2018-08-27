select oha.order_number "Order Number"
, ola.line_number "Line Num"
, ola.shipment_number "Shipment Num"
, ola.ordered_item "Item"
, ola.ordered_quantity "Quantity"
, ola.request_date "Request D"
, ola.schedule_ship_date "Ship D"
, ola.promise_date "Promise D"
from oe_order_lines_all ola
, oe_order_headers_all oha
where ola.org_id          = 83
	and ola.header_id        = oha.header_id
	and ola.attribute20      = 'BLANKET'
	and ola.open_flag        = 'Y'
	and ola.shippable_flag   = 'Y'
	and ola.cancelled_flag   = 'N'
	and ola.order_source_id <> 10
	and to_Char(ola.schedule_ship_date, 'MM') in (11,12)