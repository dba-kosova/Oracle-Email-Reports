select line_code "Line", msi.segment1 "Item"
, msi.description "Description"
	, wdj.project_name "Project"
, wdj.wip_entity_name "Job"
, wdj.start_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped,0) "Open QTY"

, msi.full_lead_time "Oracle Lead Time"
, round((APPS.XXBIM_GET_WORKING_DAYS(85,	  APPS.XXBIM_GET_CALENDAR_DATE('BIM',  date_released ,nvl(msi.full_lead_time,1)+2),sysdate)),0) "Days Past Goal"
, date_released "Date Released"

, nvl(wdj.attribute4, ' ') "Priority"
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
	and msi.organization_id   = wdj.organization_id
	and msi.inventory_item_id = wdj.primary_item_id
	and line_code not in ( 'JIT', 'CSD', 'OSV', 'THR')
	and status_type = 3
	and APPS.XXBIM_GET_WORKING_DAYS(85,	  APPS.XXBIM_GET_CALENDAR_DATE('BIM',  date_released ,nvl(msi.full_lead_time,1)+2),sysdate) > 1
	
order by 8 desc