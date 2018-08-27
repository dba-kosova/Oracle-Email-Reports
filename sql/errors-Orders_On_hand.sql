select decode(l.ship_from_org_id,85,'BIM', 'BMX') "Org",
order_number "Order Number"
, line_number "Line Number"
, shipment_number "Shipment Number"
, ordered_item "Item"
, ordered_quantity "Quantity"
, xxbim_get_quantity(l.inventory_item_id, 85, 'ATR') "ATR BIM"
, xxbim_get_quantity(l.inventory_item_id, 90, 'ATR') "ATR BMX"
, oe_line_status_pub.get_line_status(l.line_id, l.flow_status_code) "Status"
, wdj.status_type_disp "Job Status"
, wip_entity_name "Job"
, project_name "Project"

from oe_order_lines_all l
, oe_order_headers_all h
, mtl_reservations_all_v mra
, wip_discrete_jobs_v wdj
where h.org_id                                                           = 83
	and l.open_flag                                                         = 'Y'
	and l.cancelled_flag                                                    = 'N'
	and l.order_source_id                                                  <> 10
	and order_type_id <> 1094 -- rma
	and l.header_id                                                         = h.header_id
	and l.shippable_flag                                                    = 'Y'
	and (xxbim_get_quantity(l.inventory_item_id, 85, 'ATR') >= ordered_quantity
	or xxbim_get_quantity(l.inventory_item_id, 90, 'ATR') >= ordered_quantity)
	--and l.request_date < APPS.XXBIM_GET_CALENDAR_DATE(decode(l.ship_from_org_id,85,'BIM','BMX'),sysdate, 5)
	and oe_line_status_pub.get_line_status(l.line_id, l.flow_status_code) = 'Production Open'
	and l.line_id                                                         = mra.demand_source_line_id
	and wdj.wip_entity_id                                                 = mra.supply_source_header_id