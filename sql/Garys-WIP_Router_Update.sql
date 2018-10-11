select wdj.wip_entity_name "Job"
, wdj.project_Name "Project"
,msi.segment1 "Part Number"
,      msi.description "Description"
,      wdj.line_code "Line"
,    (select user_name from fnd_user where wdj.last_updated_by = user_id) "Job Updated By"

,      wo.operation_seq_num "Op Seq"
,      wo.description "Operation"
,    (select user_name from fnd_user where wor.last_updated_by = user_id) "Router Step Updated By"
,    (select user_name from fnd_user where wo.last_updated_by = user_id) "Router Resource Updated By"

from wip_operations wo
,    wip_discrete_jobs_v wdj
,    wip_operation_resources wor
,    mtl_system_items_b msi
,    bom_resources br
,    bom_departments bd
where wo.organization_id = 85
  and wdj.organization_id = wo.organization_id
  and wor.organization_id = wo.organization_id
  and wo.organization_id = br.organization_id
  and wo.organization_id = bd.organization_id
  and wo.wip_entity_id = wdj.wip_entity_id
  and wo.wip_entity_id = wor.wip_entity_id
  and msi.organization_id = wdj.organization_id
  and msi.inventory_item_id = wdj.primary_item_id
  and wo.operation_seq_num = wor.operation_seq_num
and (wo.creation_date <> wo.last_update_date
or wor.creation_date <> wor.last_update_date)
  --and wip_entity_name = '1304836'
  and wdj.status_type_disp in ( 'Unreleased','Released', 'On Hold')
  and wor.resource_id = br.resource_id
  and wo.department_id = bd.department_id
  and greatest(wor.last_update_date, wo.last_update_date) > apps.xxbim_get_calendar_date('BIM',sysdate,-1)
