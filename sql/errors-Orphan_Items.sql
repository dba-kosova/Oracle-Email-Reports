select decode(a.organization_id,85,'BIM','BMX')
, a.segment1
, b.segment19
, (
		select project_number
		from pjm.pjm_seiban_numbers
		where project_id = b.segment19
	)
	project
, c.subinventory_code
, inv_project.get_pjm_locsegs(b.concatenated_segments) locator
, c.on_hand_qty
, round(d.item_cost * c.on_hand_qty,2) inv_cost
, xxbim_get_quantity(a.inventory_item_id, a.organization_id, 'TQ', 'BACKFLUSH') qty_in_backflush
from mtl_system_items_b a
, apps.mtl_item_locations_kfv b
, (
		select moqd.inventory_item_id
		, moqd.organization_id
		, moqd.subinventory_code
		, moqd.locator_id
		, sum(primary_transaction_quantity) on_hand_qty
		from mtl_onhand_quantities_detail moqd
		group by moqd.inventory_item_id
		, moqd.organization_id
		, moqd.subinventory_code
		, moqd.locator_id
	)
	c
, cst_item_costs d
where a.organization_id       = c.organization_id
	and a.inventory_item_id      = c.inventory_item_id
	and a.inventory_item_id      = d.inventory_item_id(+)
	and a.organization_id        = d.organization_id(+)
	and d.cost_type_id(+)        = 1
	and a.organization_id       in (90, 85)
	and c.organization_id        = b.organization_id(+)
	and c.locator_id             = b.inventory_location_id(+)
	and c.subinventory_code not in ('SHP HR', 'STAGE','CMP HR','STAGELOC')
	and c.subinventory_code not like '%SHIP'
	and b.segment19 is not null
	and not exists
	(
		select *
		from wip_discrete_jobs wd
		where wd.project_id  = b.segment19
			and wd.status_type in (3, 1, 6)
			and wd.line_id not in (13,20,19,23,33,34,21,27,28,29,30,31)
	)

	union all

	select decode(a.organization_id,85,'BIM','BMX')
, a.segment1
, b.segment19
, (
		select project_number
		from pjm.pjm_seiban_numbers
		where project_id = b.segment19
	)
	project
, c.subinventory_code
, inv_project.get_pjm_locsegs(b.concatenated_segments) locator
, c.on_hand_qty
, round(d.item_cost * c.on_hand_qty,2) inv_cost
, xxbim_get_quantity(a.inventory_item_id, a.organization_id, 'TQ', 'BACKFLUSH') qty_in_backflush
from mtl_system_items_b a
, apps.mtl_item_locations_kfv b
, (
		select moqd.inventory_item_id
		, moqd.organization_id
		, moqd.subinventory_code
		, moqd.locator_id
		, sum(primary_transaction_quantity) on_hand_qty
		from mtl_onhand_quantities_detail moqd
		group by moqd.inventory_item_id
		, moqd.organization_id
		, moqd.subinventory_code
		, moqd.locator_id
	)
	c
, cst_item_costs d
where a.organization_id       = c.organization_id
	and a.inventory_item_id      = c.inventory_item_id
	and a.inventory_item_id      = d.inventory_item_id(+)
	and a.organization_id        = d.organization_id(+)
	and d.cost_type_id(+)        = 1
	and a.organization_id       in (90, 85)
	and c.organization_id        = b.organization_id(+)
	and c.locator_id             = b.inventory_location_id(+)
	and c.subinventory_code not in ('SHP HR', 'STAGE','CMP HR','STAGELOC','DCK HR','TOOL OSV', 'TOOL FLOOR','TOOL CRIB','ZCONS')
	and c.subinventory_code not like '%SHIP'
	and b.segment19 is null and locator_id is not null