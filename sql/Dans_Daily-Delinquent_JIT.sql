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
       ,substr( (
        select max(schedule_group_name)
        from(
            select(
                select schedule_group_name
                from wip_schedule_groups ws
                where ws.schedule_group_id = wdj2.schedule_group_id
                      and organization_id = wdj2.organization_id
            ) schedule_group_name,wip_entity_name,line_code,project_id,we2.wip_entity_id,scheduled_start_date,status_type
            from wip_discrete_jobs wdj2,wip_lines wl,wip_entities we2
            where wdj2.organization_id = 85
                  and wdj2.line_id = wl.line_id
                  and wdj2.organization_id = wl.organization_id
                  and line_code not like '%SUB%'
                  and line_code not in(
                'JIT','THR','NJIT','CSD','OSV'
            )
                  and status_type in(
                '1','6','3'
            ) -- unre, on hold. R is 3
                  and wdj2.wip_entity_id = we2.wip_entity_id
          --and wdj2.project_id     = wdj.project_id
            group by line_code,project_id,we2.wip_entity_id,scheduled_start_date,wip_entity_name,status_type,schedule_group_id,wdj2.organization_id
            order by status_type desc,scheduled_start_date asc
        )
        where project_id = wdj.project_id
              and rownum = 1
    ),0,4) bore
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
	
