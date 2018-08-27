select segment1 "Item"
,decode(nvl(fixed_days_supply,0),40,'ok', 'should be 40') "Fixed Days Supply"
, decode(nvl(attribute_category,0), organization_id,'ok', 'should be '
	||organization_id) "Attribute Context"
, decode(
	(
		select meaning from fnd_lookup_values where lookup_code = to_char(release_time_fence_code)
			and lookup_type                                        = 'MTL_RELEASE_TIME_FENCE'
	)
	, 'User-defined time fence','ok', 'should be: User-defined time fence') "Release Time Fence Code"
, decode( nvl(release_time_fence_days,0) , 15, 'ok', 'should be 15' ) "Release Time Fence"
, decode( nvl(acceptable_early_days,0) , 15 ,'ok', 'should be 15' )"Acceptable Days Early"
, nvl(planner_code, 'add planner code') "Planner Code"
--, decode(minimum_order_quantity, null, 'ok', 'should be blank') "Min Order Quantity"
, decode(END_ASSEMBLY_PEGGING_FLAG,'B', 'ok', 'should be "end assembly/ soft pegging"') "Pegging"
, decode(replenish_to_order_flag,'N', 'ok', 'ATO box should not be checked in any org') "Assemble to order"
, decode(MRP_PLANNING_CODE,7,'ok','should be MRP/MPP Planned') "Planning Method"
, decode(nvl(ATO_FORECAST_CONTROL,0),2,'ok','should be Consume and derive') "Forecast Control"
, decode(MAXIMUM_ORDER_QUANTITY, null,'ok','should be null') "MAXOQ"
, decode(FIXED_LOT_MULTIPLIER, null,'ok','should be null') "FLM"
from mtl_system_items_b msi
where msi.organization_id       = 85
	and inventory_item_status_code = 'Active'
	and
	(
		planner_code in ( 'NJIT', 'Banjo')
		or
		(
			item_type         = 'SA'
			and planner_code is null
		)
	)
	and
	(
		(nvl(fixed_days_supply,0)          <> 40 and nvl(attribute5,0) not like 'BIF Caps%')
		or nvl(release_time_fence_days,0) <> 15
		or nvl(release_time_fence_code,0 )       <> 4
		or nvl(acceptable_early_days,0 )         <> 15
		or nvl(attribute_category,00)     <> organization_id
		--or minimum_order_quantity         is not null
		or nvl(MAXIMUM_ORDER_QUANTITY,0)       <>0
		or (nvl(FIXED_LOT_MULTIPLIER,0) <> 0 and nvl(attribute5,0) like 'BIF Caps%')
		or nvl(END_ASSEMBLY_PEGGING_FLAG,'a') <> 'B'
		or nvl(replenish_to_order_flag,'N') <> 'N'
	)