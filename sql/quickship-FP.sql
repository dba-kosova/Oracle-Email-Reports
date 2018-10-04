select * from (select 
case when wdj.attribute4 = 10 then 'QS'
when wdj.attribute4 = 20   and status_type_disp = 'Released'
and to_number(nvl(quantity_remaining, start_quantity))<100
and line_code not in ('JIT', 'CSS') then 'QS'
when wdj.attribute4 = 20  and scheduled_completion_date >= apps.XXBIM_GET_CALENDAR_DATE('BIM', sysdate, 5)then 'VIP'
when wdj.attribute4 = 40 then 'QS'else 'VIP'end Priority
, nvl((select max(apps.xxbim_get_working_days(85, hist.date_changed, sysdate)) days_old
from oe_order_headers_all oeh
, oe_order_lines_all oel
, (
		select line_id
		, max(hist_creation_date) date_changed
		from oe_order_lines_history
		where 1                          =1
			and shipment_priority_code not in ( 'QSH', 'EQS')
		group by line_id
	)
	hist
where oeh.header_id              = oel.header_id
	and oeh.open_flag               = 'Y'
	and oeh.booked_flag             = 'Y'
	and oel.open_flag               = 'Y'
	and oel.shippable_flag          = 'Y'
	and oel.ship_from_org_id        = 85
	and oel.shipment_priority_code in ( 'QSH', 'EQS')
	and oel.line_id                 = hist.line_id(+)
	and oel.project_id              = wdj.project_Id),APPS.XXBIM_GET_WORKING_DAYS(85, date_released,sysdate)) "QS Age"
--decode(wdj.attribute4,10,'QS', 20, 'VIP', 30, 'FTS', 40, 'QS') "Priority"
, project_name	"Project"		
, wip_entity_name		"Job"	
, line_code			"Line"
, msi.segment1 			"Part Number"
, to_number(nvl(quantity_remaining, start_quantity)) "Quantity"
, status_type_disp			"Status"
, date_released			"Date Released"
, date_completed			"Date Completed"
, schedule_group_name "Bore Size"
from wip_discrete_jobs_v wdj			
, mtl_system_items_b msi			
where 1                  =1			
	and wdj.organization_id = 85		
	and wdj.primary_item_id = msi.inventory_item_id		
	and wdj.organization_id = msi.organization_id	
	and wdj.status_type_disp <> 'Cancelled'
	--and line_code in ('JIT', 'SUB')		
	and project_id in		
	(		
	select project_id	
		from wip_discrete_jobs_v wdj	
		where 1                      =1	
			and wdj.organization_id     = 85
			and wdj.quantity_remaining is not null
			and wdj.status_type_disp   in ('Released', 'Unreleased', 'On Hold')
			--and SCHEDULED_START_DATE > APPS.XXBIM_GET_CALENDAR_DATE('BIM', sysdate, -90)
			and wdj.attribute4          in (10,40) 
			AND wdj.status_type IN (3, 4, 6) 
			and line_code not in (  'OL', 'THR', 'ACC', 'PFC','CSS')
			and line_code not          in ('JIT', 'SUB')
	)		
union all

select 'QS'
, (select max(apps.xxbim_get_working_days(85, hist.date_changed, sysdate)) days_old
from oe_order_headers_all oeh
, oe_order_lines_all oel
, (
		select line_id
		, max(hist_creation_date) date_changed
		from oe_order_lines_history
		where 1                          =1
			and shipment_priority_code not in ( 'QSH', 'EQS')
		group by line_id
	)
	hist
where oeh.header_id              = oel.header_id
	and oeh.open_flag               = 'Y'
	and oeh.booked_flag             = 'Y'
	and oel.open_flag               = 'Y'
	and oel.shippable_flag          = 'Y'
	and oel.ship_from_org_id        = 85
	and oel.shipment_priority_code in ( 'QSH', 'EQS')
	and oel.line_id                 = hist.line_id(+)
	and oel.project_id              = ola.project_Id) "Age"
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
, to_date(null) col7, to_date(null) col8, null col9
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
	and nvl((
		select attribute1
		from bom_operational_routings br
		where alternate_routing_designator is null
			and br.organization_id             = ola.ship_from_org_id
			and br.assembly_item_id            = inventory_item_id
	),'a') not in (  'OL', 'THR', 'ACC', 'PFC','CSS')
)
where priority = 'QS'
order by 1,3,5,6