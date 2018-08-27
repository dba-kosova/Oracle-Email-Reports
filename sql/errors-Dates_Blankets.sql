select oha.order_number "Order Number"
, ola.line_number "Line Num"
, ola.shipment_number "Shipment Num"
, ola.ordered_item "Item"
, ola.ordered_quantity "Quantity"
, ola.request_date "Request D"
, ola.schedule_ship_date "Ship D"
, ola.promise_date "Promise D"
, ola.attribute20 "Blanket"
--, oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code)
from oe_order_lines_all ola
, oe_order_headers_all oha
, mtl_system_items_b msi
where ola.org_id          = 83
and ola.ship_from_org_id = msi.organization_id
and ola.inventory_item_id = msi.inventory_item_id
	and ola.header_id        = oha.header_id
	--and (nvl(ola.attribute20,'a')      = 'BLANKET' or ola.schedule_ship_date > sysdate + 10)
	and ola.open_flag        = 'Y'
	and ola.shippable_flag   = 'Y'
	and ola.cancelled_flag   = 'N'
	and ola.order_source_id <> 10
	and
	(
		trunc(ola.request_date)          = trunc(ola.schedule_ship_date)
		or trunc(ola.schedule_ship_date) >= trunc(ola.promise_date-3)
	)
	--and ola.schedule_ship_date > sysdate+10
	--and ola.promise_date > sysdate+10
	and planning_make_buy_code = 1
	--and order_number = '10419720'
	and oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) = 'Supply Eligible'
	order by 7 asc