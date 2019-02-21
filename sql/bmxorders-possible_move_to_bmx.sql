select project_name "Project", wdj.project_id
, wip_entity_name "Job"
, msi.segment1 "Item"
, substr(msi.description,0,20) "Description"
, msi.planner_code "Planner"
, status_type_disp "Status"
, wdj.attribute1
    ||'.'
    || wdj.attribute2
    ||'.'
    || wdj.attribute3 "DFF"
, line_code "Line"
, decode(nvl(to_char(demand_source_header_id), 'None'), 'None', 'None', 'Yes') "Sales Order"
, start_quantity "Start QTY"
, to_number(quantity_remaining) "Open QTY"
, wdj.creation_date "Date Created"


, scheduled_start_date "Schedule Start"
, scheduled_completion_date "Schedule Completion"
, date_released "Released"
, nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = wdj.organization_Id
    and cat.structure_id    = '50415'
    and cat.inventory_item_id = wdj.primary_item_Id), 'Special') "Category"

from wip_discrete_jobs_v wdj
, apps.mtl_item_locations_kfv b
, mtl_system_items_b msi
, mtl_reservations mr
where wdj.organization_id     = 85
   -- and status_type_disp        = 'Unreleased'
    and wdj.status_type = 1 -- unreleased
    and wdj.organization_id       = b.organization_id(+)
    and wdj.completion_locator_id = b.inventory_location_id(+)
    and wdj.organization_id       = msi.organization_id
    and wdj.primary_item_id       = msi.inventory_item_id
    and wdj.wip_entity_id         = mr.supply_source_header_id(+)
    and (wdj.attribute2 <> 0
        or wdj.attribute3 <> 0)
    and line_code in ( 'OL', 'OL-B')
    and demand_source_header_id is not null
    and wdj.project_id is not null
    and not exists (select
we.wip_entity_name job
, we.project_name project
, we.line_code line
, msip.segment1 assembly
, msi.segment1 component
, msi.description
, wro.required_quantity
, wro.attribute2
, nvl(case when wro.wip_supply_type = 1 then xxbim_get_quantity(msi.inventory_item_id, 90, 'ATR') else xxbim_get_quantity(msi.inventory_item_id, 90, 'TQ') end,0) bmx_stock_level
from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msi
, mtl_system_items_b msip
where we.organization_id  = 85
	and msip.organization_id = we.organization_id
	and wro.organization_id  = we.organization_id
	and msi.organization_id  = we.organization_id
	and we.project_id = wdj.project_id    
	and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
	and msip.inventory_item_id = we.primary_item_id
    and we.status_type = 1
    and wro.wip_supply_type  in (1,2)
    and wro.inventory_item_id not in (select primary_item_Id from wip_discrete_jobs where project_id = we.project_id)
    and nvl(case when wro.wip_supply_type = 1 then xxbim_get_quantity(msi.inventory_item_id, 90, 'ATR') else xxbim_get_quantity(msi.inventory_item_id, 90, 'TQ') end,0) < wro.required_quantity)
order by scheduled_completion_date asc