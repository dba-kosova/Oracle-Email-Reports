select 
 wdj.wip_entity_name "Job"
, wdj.project_name "Project"
, msi.segment1 "Part"
, msi.description "Description"
, wdj.scheduled_start_date "Scheduled Start Date"
, wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 "DFF"
, wdj.status_type_disp "Status"
, msi.planner_code "Planner"
, wdj.line_code "Line"
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
	and msi.organization_id   = wdj.organization_id
	and msi.inventory_item_id = wdj.primary_item_id
	and wdj.status_type_disp  = 'Unreleased'
	and (wdj.attribute2 = '0' and wdj.attribute3 is null
		or wdj.attribute3 = '0')
	and trunc(scheduled_start_date) < trunc(sysdate)
	and (wdj.line_code is null or wdj.line_code like 'SUB%' or wdj.line_code in ('CSS', 'ACC', 'ACC-SHV', 'NJIT', 'OSV'))