select segment1 "Part Number"
, case when nvl(fixed_days_supply,0)          <> 20 then 'Fixed Days Supply should be 20'
		   when release_time_fence_code        <> 4 then 'Release time fence code should be "User-defined time fence"'
			 when nvl(release_time_fence_days,0) <> 10 then 'Release time fence days should be 10'
			 when acceptable_early_days          <> 10 then 'Acceptable early days should be 10'
			 when replenish_to_order_flag        <> 'Y' then 'Assemble to order box should be checked on all orgs and master'
			 end "Problem"
from mtl_system_items_b msi
where msi.organization_id       = 85
	and inventory_item_status_code = 'Active'
	and planner_code               = 'ACC-SHV'
	and
	(
		nvl(fixed_days_supply,0)          <> 20
		or nvl(release_time_fence_days,0) <> 10
		or release_time_fence_code        <> 4
		or acceptable_early_days <> 10
		or replenish_to_order_flag <> 'Y'
)