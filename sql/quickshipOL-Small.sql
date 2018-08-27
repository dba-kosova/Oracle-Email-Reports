select decode(wdj.attribute4,10,'QS', 20, 'VIP', 30, 'FTS', 40, 'QS') "Priority"
, project_name	"Project"		
, wip_entity_name		"Job"	
, line_code			"Line"
, msi.segment1 			"Part Number"
, to_number(nvl(quantity_remaining, start_quantity)) "Quantity"
, wdj.attribute1 ||'.'|| wdj.attribute2||'.'||wdj.attribute3 "DFF"
, status_type_disp			"Status"
, date_released			"Date Released"
--, date_completed			"Date Completed"
from wip_discrete_jobs_v wdj			
, mtl_system_items_b msi			
where 1                  =1			
	and wdj.organization_id = 85		
	and wdj.primary_item_id = msi.inventory_item_id		
	and wdj.organization_id = msi.organization_id		
	and line_code not in ('JIT')
	--and line_code not like 'SUB%'
	and project_id in		
	(		
		select project_id	
		from wip_discrete_jobs_v wdj	
		, mtl_system_items_b msi	
		where 1                      =1	
			and wdj.organization_id     = 85
			and wdj.primary_item_id     = msi.inventory_item_id
			and wdj.organization_id     = msi.organization_id
			and wdj.quantity_remaining is not null
			and wdj.status_type_disp   in ('Released', 'Unreleased', 'On Hold')
			and wdj.attribute4          in (10,40) 
			and line_code in ( 'OL', 'THR', 'ACC', 'PFC')
	)		
	and wdj.status_type_disp not in ('Complete', 'Closed', 'Cancelled')
