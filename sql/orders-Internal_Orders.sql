select decode(o.ship_from_org_id, 85, 'BIM', 90, 'BMX') "Ship From"
, h.order_number
	|| '-'
	|| o.line_number "Order Number"
, wdj.project_number "Project"
, wdj.wip_entity_id "Job"
, ordered_item "Item"
, (select planner_Code from mtl_system_items_b where inventory_item_id = o.inventory_item_id and organization_id = o.ship_from_org_id) "Planner Code"
, o.ordered_quantity "Quantity"
, xxbim_get_quantity(o.inventory_item_id, o.ship_from_org_id, 'ATR') "QTY ATR"
, xxbim_get_quantity(o.inventory_item_id, o.ship_from_org_id, 'ATT') "QTY ATT"
, xxbim_get_quantity(o.inventory_item_id, o.ship_from_org_id, 'TQ') "QTY Total"
, wdj.scheduled_start_date "Schedule Start"
, wdj.scheduled_completion_date "Schedule Complete"
, wdj.date_released "Released"
, wdj.date_completed "Completed"
, o.request_date "Request Date"
, o.schedule_ship_date "Schedule Ship"
, o.promise_date "Promise"
, o.schedule_arrival_date "Arrival"
, oe_line_status_pub.get_line_status(o.line_id, o.flow_status_code) "Line Status"
from oe_order_lines_all o
, oe_order_headers_all h
, wip_discrete_jobs_v wdj
where o.open_flag       = 'Y'
and o.booked_flag = 'Y'
and o.cancelled_flag = 'N'
and shippable_flag = 'Y'
	and o.header_id        = h.header_id
	and h.org_id           = 83
	and h.order_source_id  = 10
	and o.project_id       = wdj.project_id(+)
	and ordered_item_id    = wdj.primary_item_id(+)
	and o.ship_from_org_id = wdj.organization_id(+)
order by o.schedule_arrival_date