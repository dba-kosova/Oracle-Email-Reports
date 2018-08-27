select msi.segment1 "Item"
, msi.description "Description"

, nvl(			
	(		
		select max(line_code)
		from wip_discrete_jobs wdj2	
		, wip_lines wl	
		where wdj2.organization_id = 85	
			and wdj2.line_id          =wl.line_id
			and wdj2.organization_id  = wl.organization_id
			and line_code not like '%SUB%'
			and line_code not in ('JIT', 'THR', 'NJIT','CSD')
			and wdj2.project_id     = wdj.project_id
	)		
	,'ACC') "Top Line"
, wdj.project_name "Project"
, wdj.wip_entity_name "Job"
, wdj.start_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped,0) "Open QTY"

, msi.full_lead_time "Oracle Lead Time"
, round((APPS.XXBIM_GET_WORKING_DAYS(85,	  APPS.XXBIM_GET_CALENDAR_DATE('BIM',  date_released ,nvl(msi.full_lead_time,1)),sysdate)),0) "Days Past Goal"
, date_released "Date Released"
, nvl(wdj.attribute4, ' ') "Priority"
, nvl((select min(promise_date) from oe_order_lines_all ola where wdj.project_id = ola.project_id and open_flag = 'Y' and cancelled_flag = 'N'),scheduled_completion_date) "Promise"
from mtl_system_items_b msi
, wip_discrete_jobs_v wdj
where msi.organization_id  = 85
	and msi.organization_id   = wdj.organization_id
	and msi.inventory_item_id = wdj.primary_item_id
	and line_code = 'JIT'
	and status_type = 3
	and APPS.XXBIM_GET_WORKING_DAYS(85,	  APPS.XXBIM_GET_CALENDAR_DATE('BIM',  date_released ,nvl(msi.full_lead_time,1)),sysdate) > 1
	and (msi.segment1 like 'ROD%' or msi.segment1 like 'GUI%' or msi.segment1 like 'TIE%')
order by 8 desc