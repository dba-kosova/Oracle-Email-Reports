select  item_segments	
, item_description	
, round((select attribute7 from mtl_system_items_b where organization_Id = 85 and segment1 = item_segments),0) EAU
, planner_code	
, buyer_name	
, order_Type
, max(days_late) Days_late
from apps.msc_exception_details_v a	
where a.organization_id in (85)	
	and a.category_set_id   = 3005
	and plan_id             = 21
	and exception_type      = 15
	and category_name       = 'Standard'
	and supply_project_id is null
	and nvl(planning_group,'abc') <> 'ATO'
	and comp_demand_date < sysdate + 10
group by organization_id	
, organization_code	
, category_name	
, inventory_item_id	
, item_segments	
, item_description	
, buyer_name	
, planner_code	
, order_Type, supply_item_segments, supply_order_type	
order by buyer_name desc	
, a.planner_code	