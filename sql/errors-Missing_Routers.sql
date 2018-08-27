select segment1
, description
, planner_code
, item_type
, decode(planning_make_buy_code, 1, 'Make','Buy') Make_buy
, attribute7 eau
, (select attribute1 from bom_operational_routings where alternate_routing_designator is null and organization_id = msi.organization_id and assembly_item_id = msi.inventory_item_id) line_code
from mtl_system_items_b msi
where organization_id           = 85
	and inventory_item_status_code = 'Active'
	--and planner_code = 'ACC'
	and planning_make_buy_code = 1
	and item_type not in ('TOOL', 'TOOL PKG', 'REF', 'RAD')
	and planner_code not in ('TPK', 'REF')
	and not exists (select * from bom_operational_routings where alternate_routing_designator is null and organization_id = msi.organization_id and assembly_item_id = msi.inventory_item_id)