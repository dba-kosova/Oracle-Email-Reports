select decode(organization_Id,'90','BMX','85','BIM') org
,segment1
, description
, planner_code
, item_type
,decode(planning_make_buy_code, 1, 'Make','Buy') Make_buy
, attribute7 eau
from mtl_system_items_b msi
where organization_id in (85,90)
	and inventory_item_status_code = 'Active'
	--and planner_code = 'ACC'
	and planner_code is null
	and segment1 not like 'OC%'
	and segment1 not like 'CTO%'
	and item_type not in ('PTO', 'TOOL', 'TOOL PKG', 'EX', 'DSP', 'NS')
and ((NVL(attribute7,0) > 0 AND PLANNING_MAKE_BUY_CODE = 2) OR msi.PLANNING_MAKE_BUY_CODE =1)