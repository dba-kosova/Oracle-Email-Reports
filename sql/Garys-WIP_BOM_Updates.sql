select
    we.status_type_disp "Status",
    we.wip_entity_name   "Job",
    we.project_name      "Project",
    (select user_name from fnd_user where we.last_updated_by = user_id) "Job Updated By",
    we.last_updated_by,
    line_code            "Line",
    msip.segment1        "Part Number",
    msi.segment1         "Component",
    (select user_name from fnd_user where wro.last_updated_by = user_id) "BOM Updated By"
from
    wip_discrete_jobs_v we,
    wip_requirement_operations wro,
    mtl_system_items_b msi,
    mtl_system_items_b msip
where
    we.organization_id = 85
    and msip.organization_id = we.organization_id
    and wro.organization_id = we.organization_id
    and msi.organization_id = we.organization_id
--    and msip.segment1 like 'FO-091%'
    and we.wip_entity_id = wro.wip_entity_id
    and wro.inventory_item_id = msi.inventory_item_id
    and msip.inventory_item_id = we.primary_item_id
    
    and (we.last_update_date <> we.creation_date
    or wro.last_update_date <> wro.creation_date)
    
    and greatest(wro.last_update_date,we.last_update_date) > apps.xxbim_get_calendar_date('BIM', sysdate,-1)
    and we.status_type_disp in (
        'Released',
        'Unreleased',
        'On Hold'
    )
