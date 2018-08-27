select segment1, planner_Code, 
case when (planner_code like 'SUB%' and replenish_to_order_flag = 'N' and nvl(release_time_fence_days,0) <> 10) then 'release time fence is missing?'
when (planner_code = 'SUB'and replenish_to_order_flag = 'Y') then 'Planner code is wrong?' end "Problem"
from mtl_system_items_b msi
where msi.organization_id = 85
and ((planner_code like 'SUB%' and replenish_to_order_flag = 'N' and nvl(release_time_fence_days,0) <> 10) or
(
planner_code = 'SUB' and replenish_to_order_flag = 'Y'))

