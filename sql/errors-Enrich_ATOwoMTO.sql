select organization_id, segment1
, description
, planner_code
, item_type
, replenish_to_order_flag 
, attribute7 eau
from mtl_system_items_b msi
where organization_id           in ( 85,90)
	and inventory_item_status_code = 'Active'
	--and planner_code = 'ACC'
	--and segment like = 'FO-091'
	and item_type in( 'AI', 'SFG')
	and replenish_to_order_flag <> 'Y'
	and planning_make_buy_code = 1
	order by 1