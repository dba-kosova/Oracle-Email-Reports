select msi.segment1 "Item"
, msi.description "Description"
, status_type_disp "Status"
, line_code "Line"
, wdj.wip_entity_name "Job"
, wdj.quantity_remaining "Quantity"
, to_char(trunc(scheduled_completion_date), 'DD-MON-YYYY') "Due Day"
, wdj.schedule_group_name machine_group
  , (select count(1)
from wip_discrete_jobs_v we
, wip_requirement_operations wro
where we.organization_id  = 85
	and wro.organization_id  = we.organization_id
	
	and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
    and we.status_type in(1,6) -- unreleased,on hold
    ) lines_waiting
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
	and wdj.line_code in ( 'NJIT','JIT')
	and msi.planner_code in ( 'NJIT', 'JIT')

	order by scheduled_completion_date
	
