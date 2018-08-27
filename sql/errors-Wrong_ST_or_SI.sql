select segment1 "Item"
,decode(wip_supply_type, 1, 'Push', 2, 'Assembly Pull', 'Other') "Supply Type"
, wip_supply_subinventory "Subinventory"
, decode(wip_supply_type, 1, 'cannot be push with a subinv', 2, 'Assembly pull must have a subinv', 'Other') "Error Type"
from mtl_system_items_b msi
where organization_id           = 85
	and inventory_item_status_code = 'Active'
	and
	(
		wip_supply_type              = 1
		and wip_supply_subinventory is not null
		or wip_supply_type           = 2
		and wip_supply_subinventory is null
		and planner_code not in 'TOL'
	)
