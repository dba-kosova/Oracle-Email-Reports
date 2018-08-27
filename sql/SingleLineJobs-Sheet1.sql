select msi.segment1 "Part Number"
, wdj.line_code "Line Code"
, msi.planner_code "Planner Code"
, wdj.wip_entity_name "Job"
, wdj.project_name "Project"
, wdj.attribute1 ||'.' ||wdj.attribute2 ||'.'|| wdj.attribute3 "DFF"
, wdj.scheduled_start_date "Scheduled Start Date"
, wdj.creation_date "Created On"
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
	and msi.organization_id   = wdj.organization_id
	and msi.inventory_item_id = wdj.primary_item_id
	and nvl(line_code, 'abc') not        in ('ACC', 'NJIT', 'CSS', 'PM', 'OLE', 'FC', 'CSD')
	and nvl(planner_code, 'abc') not in ('SUB', 'NJIT', 'Banjo', 'SUB-ATO')
	and wdj.status_type_disp  = 'Unreleased'
and not exists (select project_Id from wip_discrete_Jobs_v where line_code = 'JIT'and organization_Id = 85  and project_Id = wdj.project_Id)
and scheduled_Start_date < apps.xxbim_get_calendar_date('BIM', sysdate, 10)
and wdj.attribute2 = '0'

group by msi.segment1 
, wdj.line_code
, msi.planner_code 
, wdj.wip_entity_name 
, wdj.project_name 
, wdj.attribute1 ||'.' ||wdj.attribute2 ||'.'|| wdj.attribute3 
, wdj.scheduled_start_date
, wdj.creation_date
order by line_code