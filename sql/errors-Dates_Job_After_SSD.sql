select decode(wdj.organization_id, 90,'BMX', 85, 'BIM') "Org"
,oha.order_number||'-'||ola.line_number "Order Number"

, ola.shipment_number "Shipment Num"
, ola.ordered_item "Item"
, ola.ordered_quantity "Quantity"
, ola.schedule_ship_date "Ship D"
, wdj.scheduled_completion_date "Job Completion Date"
--, oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code)
from oe_order_lines_all ola
, oe_order_headers_all oha
,MTL_RESERVATIONS_ALL_V mra
, wip_discrete_jobs_v wdj
where ola.org_id          = 83
and wdj.organization_id in ( 85 , 90)
	and ola.header_id        = oha.header_id
	and ola.line_id = mra.demand_source_line_id
	and mra.supply_source_header_id = wdj.wip_entity_id
	and ola.ship_from_org_id = wdj.organization_Id
	--and (nvl(ola.attribute20,'a')      = 'BLANKET' or ola.schedule_ship_date > sysdate + 10)
	and ola.open_flag        = 'Y'
	and ola.shippable_flag   = 'Y'
	and ola.cancelled_flag   = 'N'
	and ola.order_source_id <> 10
	and ola.schedule_ship_date > sysdate
	and ola.promise_date > sysdate
	and wdj.status_type_disp = 'Unreleased'
	and trunc(wdj.scheduled_completion_date) > trunc(ola.schedule_ship_date)
	order by 5 asc
	