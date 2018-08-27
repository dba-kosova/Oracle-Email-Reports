select msi.segment1 "Item"
, msi.planner_code "Planner"
, msi.attribute7 "EAU"
, cat.category_concat_segs "Cat"
, boro.attribute1 "Line"
, msi.shrinkage_rate "Shrinkage"
, decode(msi.shrinkage_rate, null,'should be .01', 'should be blank') "Shrinkage Update"
from mtl_system_items_b msi
, bom_operational_routings boro
, MTL_ITEM_CATEGORIES_V cat
where msi.organization_id           = 90
and msi.organization_Id = boro.organization_id(+)
and msi.inventory_item_id = boro.assembly_item_id(+)
and boro.alternate_routing_designator is null
and boro.attribute1 not in ('JIT')
and msi.organization_id = cat.organization_id(+)
	and msi.inventory_item_status_code = 'Active'
	and planning_make_buy_code = 1
	--and planner_code = 'SUB'
	and cat.structure_id(+) = '50415'
	and nvl(category_concat_segs, 'Special') = 'Special'
	and msi.inventory_item_id = cat.inventory_item_id(+)
	and nvl(msi.SHRINKAGE_RATE,9) <> .01
	
	