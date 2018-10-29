select project_number "Project"
, wip_entity_name "Job"
, msi.segment1 "Item"
, substr(msi.description,0,20) "Description"
, status_type_disp "Status"
, wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 DFF
, line_code "Line"
, start_quantity "Start QTY"
, to_number(quantity_remaining) "Open QTY"
, scheduled_start_date "Schedule Start"
, scheduled_completion_date "Schedule Completion"
, date_released "Released"
, nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = wdj.organization_Id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = wdj.primary_item_Id), 'Special') "Category"
, completion_subinventory "Completion Subinv"
, inv_project.get_pjm_locsegs(b.concatenated_segments) "Locator"
, schedule_group_name "Schedule Group"
from wip_discrete_jobs_v wdj
, apps.mtl_item_locations_kfv b
, mtl_system_items_b msi
, mtl_reservations mr
where wdj.organization_id      =  85
               and status_type_disp         in ('Released', 'Unreleased', 'On Hold')
							 and line_code not in ('CSD', 'JIT', 'NJIT', 'OSV')
               and wdj.organization_id       = b.organization_id(+)
               and wdj.completion_locator_id = b.inventory_location_id(+)
               and wdj.organization_id       = msi.organization_id
               and wdj.primary_item_id       = msi.inventory_item_id
							 and demand_source_header_id is null
               and wdj.wip_entity_id         = mr.supply_source_header_id(+)
order by scheduled_completion_date asc