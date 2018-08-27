select oha.order_number
	||'-'
	||ola.line_number "Order Number"
, ola.shipment_number "Shipment Number"
, ola.request_date
, ola.promise_date
, ola.ordered_item
, ola.ordered_quantity
, (select max(attribute1) from bom_operational_routings boro where organization_Id = 85 and alternate_routing_designator is null and boro.assembly_item_id = ola.inventory_item_id) "Line"

, (
		select meaning
		from oe_lookups
		where ola.shipment_priority_code = lookup_code
			and lookup_type                 = 'SHIPMENT_PRIORITY'
	) "Priority"
,oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) "Status"
, (select max(date_released) from wip_discrete_jobs_v where project_id = ola.project_id and primary_item_id = ola.inventory_item_id) "Date Released"
from oe_order_lines_all ola
, oe_order_headers_all oha
where ola.org_id        = 83
	and ola.attribute20    = 'BLANKET'
	and ola.open_flag      = 'Y'
	and ola.shippable_flag = 'Y'
	and ola.cancelled_flag = 'N'
	and ola.promise_date   < trunc(sysdate,'WW') + 14
	and ola.header_id      = oha.header_id 
	and ola.ship_from_org_id = 85
	and ola.source_type_code             <> 'EXTERNAL'
	and ola.order_source_id            <> 10 
	and oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) not in ('Awaiting Supply', 'Awaiting Shipping', 'Awaiting Receipt','Picked')
	order by ola.promise_date asc