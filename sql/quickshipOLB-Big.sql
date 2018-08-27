select * from (select decode(wdj.attribute4,10,'QS', 20, 'VIP', 30, 'FTS', 40, 'QS') "Priority"
, project_name	"Project"		
, wip_entity_name		"Job"	
, line_code			"Line"
, msi.segment1 			"Part Number"
, to_number(nvl(quantity_remaining, start_quantity)) "Quantity"
, status_type_disp			"Status"
, date_released			"Date Released"
, date_completed			"Date Completed"
from wip_discrete_jobs_v wdj			
, mtl_system_items_b msi			
where 1                  =1			
	and wdj.organization_id = 85		
	and wdj.primary_item_id = msi.inventory_item_id		
	and wdj.organization_id = msi.organization_id		
	--and line_code in ('JIT', 'SUB')		
	and project_id in		
	(		
		select project_id	
		from wip_discrete_jobs_v wdj	
		, mtl_system_items_b msi	
		where 1                      =1	
			and wdj.organization_id     = 85
			and wdj.primary_item_id     = msi.inventory_item_id
			and wdj.organization_id     = msi.organization_id
			and wdj.quantity_remaining is not null
			and wdj.status_type_disp   in ('Released', 'Unreleased', 'On Hold')
			and wdj.attribute4          in (10,20,30,40) 
			and line_code  in (  'OL', 'THR', 'ACC', 'PFC')
			and line_code not          in ('JIT', 'SUB')
	)		
union all

select 'QS'
, oha.order_number
	||'-'
	|| ola.line_number
, null col2
, (
		select attribute1
		from bom_operational_routings br
		where alternate_routing_designator is null
			and br.organization_id             = ola.ship_from_org_id
			and br.assembly_item_id            = inventory_item_id
	)
	line
, ola.ordered_item
, to_number(ola.ordered_quantity - nvl(shipped_QUANTITY,0))
, oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) line_status_func
, to_date(null) col7, to_date(null) col8
from oe_order_lines_all ola
, oe_order_headers_all oha
where 1                                                                         =1
	and ola.open_flag                                                              = 'Y'
	and ola.org_id                                                                 = 83
	and ola.shippable_flag                                                         = 'Y'
	and ola.cancelled_flag                                                         = 'N'
	and ola.booked_flag                                                            = 'Y'
	and ola.ship_from_org_id = 85
	and ola.shipment_priority_code                                                in ('QSH', 'EQS')
	and actual_shipment_date is null
	and ola.header_id                                                              = oha.header_id
	and oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) not in ('Production Open','Booked','Shipped', 'Picked','Awaiting Shipping')
	and (
		select attribute1
		from bom_operational_routings br
		where alternate_routing_designator is null
			and br.organization_id             = ola.ship_from_org_id
			and br.assembly_item_id            = inventory_item_id
	)  in (  'OL', 'THR', 'ACC', 'PFC')
)
order by 1,2,4,5