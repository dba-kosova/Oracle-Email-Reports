select msi.segment1 "Item"
, msi.description "Description"
, status_type_disp "Status"
, line_code "Line"
, wdj.wip_entity_name "Job"
, wdj.quantity_remaining "Quantity"
, to_char(trunc(scheduled_start_date), 'DD-MON-YYYY') "Start Day"
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
   , (select sum(usage_rate_or_amount * case when basis_type = 1 then quantity_in_queue else 1 end)
    
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
    and lower(resource_code) not like '%osv%'
  --and wdj.status_type_disp = 'Unreleased'
  and wor.resource_id = br.resource_id) "Hours"
  ,  (
        SELECT
            COUNT(1)
        FROM
            wip_discrete_jobs_v we,
            wip_requirement_operations wro
        WHERE
            we.organization_id = 85
            AND wro.organization_id = we.organization_id
            
            --AND we.attribute2 = '1'
            AND substr(wro.attribute2,0,1) = '1'
            
            AND we.wip_entity_id = wro.wip_entity_id
            AND wro.inventory_item_id = msi.inventory_item_id
            and trunc(we.scheduled_start_date) < trunc(sysdate)
            AND we.status_type IN (
                1,
                6
            )
    ) "Late Orders"
  
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
  and msi.organization_id   = wdj.organization_id
  and msi.inventory_item_id = wdj.primary_item_id
  and wdj.status_type_disp in ( 'Released', 'Unreleased','On Hold')
  --and wdj.line_code = 'CSD'
  and msi.planner_code in ( 'Banjo', 'NJIT')
  order by 8,10 desc,  scheduled_completion_date
  
  
