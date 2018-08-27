select msi.segment1 "Item"
, msi.description "Description"
, status_type_disp "Status"
, line_code "Line"
, wdj.wip_entity_name "Job"
, wdj.quantity_remaining "Quantity"
, to_char(trunc(scheduled_completion_date), 'DD-MON-YYYY') "Completion Day"
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
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
	and msi.organization_id   = wdj.organization_id
	and msi.inventory_item_id = wdj.primary_item_id
	and wdj.status_type_disp in ( 'Released', 'Unreleased','On Hold')
	--and wdj.line_code = 'CSD'
	and msi.planner_code in ( 'Banjo', 'NJIT')

	order by scheduled_completion_date
	
	
