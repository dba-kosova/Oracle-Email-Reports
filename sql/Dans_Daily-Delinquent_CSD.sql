select msi.segment1 "Item"
, msi.description "Description"
, status_type_disp "Status"
, line_code "Line"
, wdj.wip_entity_name "Job"
, wdj.quantity_remaining "Quantity"
, to_char(trunc(scheduled_completion_date), 'DD-MON-YYYY') "Due Day"
, (
		select expedited
		from wip_discrete_jobs
		where wip_entity_id = wdj.wip_entity_id
	)
	"Expedite"
	, (select max(br.resource_code) 
from wip_operations wo
,    wip_discrete_jobs_v wd
,    wip_operation_resources wor
,    mtl_system_items_b msi
,    bom_resources br

where wo.organization_id = 85
  and wd.organization_id = wo.organization_id
  and wor.organization_id = wo.organization_id
  and wo.organization_id = br.organization_id
  and wo.wip_entity_id = wd.wip_entity_id
  and wo.wip_entity_id = wor.wip_entity_id
  and msi.organization_id = wd.organization_id
  and msi.inventory_item_id = wd.primary_item_id
  and wo.operation_seq_num = wor.operation_seq_num
  and wip_entity_name = wdj.wip_entity_name
	and quantity_in_queue <> 0
	and lower(resource_code) not like '%oper%'
	and lower(resource_code) not like '%queue%'
  --and wdj.status_type_disp = 'Unreleased'
  and wor.resource_id = br.resource_id) "Resource"
  , (select count(1)
from wip_discrete_jobs_v we
, wip_requirement_operations wro
where we.organization_id  = 85
	and wro.organization_id  = we.organization_id
	
	and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
    and we.status_type in(1,6) -- unreleased,on hold
    ) lines_waiting
    , (select  round(sum(nvl(
	(
		select ola2.unit_selling_price
		from oe_order_lines_all ola2
		, oe_order_headers_all oha2
		where ola.header_id           = oha.header_id
			and ola.header_id            = ola2.header_id
			and ola2.header_id           = oha2.header_id
			and oha.order_number         = oha2.order_number
			and ola.line_number          = ola2.line_number
			and ola2.unit_selling_price is not null
			and ola2.unit_selling_price <> '0'
			and ola.shipment_number      = ola2.shipment_number
			and rownum = 1
	)
	,0)),2) value
from wip_discrete_jobs_v we
, wip_discrete_jobs_v we2
, wip_requirement_operations wro
, MTL_RESERVATIONS_ALL_v mra
, oe_order_lines_all ola
, oe_order_headers_all oha

where we.organization_id  = 85
	and wro.organization_id  = we2.organization_id
    and we.organization_Id = we2.organization_id
	and we2.wip_entity_id       = wro.wip_entity_id
    and we2.project_id = we.project_id
	and wro.inventory_item_id  = msi.inventory_item_id
    and we2.line_code = we.line_code
    and we.status_type in(1,6) -- unreleased,on hold
    and ola.line_id = mra.demand_source_line_id
    
    and mra.supply_source_header_id = we.wip_entity_id
    
    and ola.header_id = oha.header_id
    and ola.shippable_flag = 'Y'
    and ola.cancelled_flag = 'N'
    and ola.booked_flag = 'Y') value
    ,(select max(line_code)
from wip_discrete_jobs_v we
, wip_requirement_operations wro
where we.organization_id  = 85
	and wro.organization_id  = we.organization_id
	
	and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
    and we.status_type in(1,6) -- unreleased,on hold
    ) product
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
	and msi.organization_id   = wdj.organization_id
	and msi.inventory_item_id = wdj.primary_item_id
	and wdj.status_type_disp in ( 'Released', 'Unreleased','On Hold')
    and trunc(wdj.scheduled_completion_date) < trunc(sysdate)
	and wdj.line_code in ('CSD', 'OSV')
	and msi.planner_code in ( 'Banjo', 'NJIT')

	order by scheduled_completion_date
	
	
