select a.segment1
, c.subinventory_code
, xxbim_get_quantity(a.inventory_item_id, a.organization_id, 'ATR', 'PPG HR') qty_atr
, round(d.item_cost * xxbim_get_quantity(a.inventory_item_id, a.organization_id, 'ATR', 'PPG HR'),2) inv_cost
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
where a.organization_id  = c.organization_id
	and a.inventory_item_id = c.inventory_item_id
	and a.inventory_item_id = d.inventory_item_id(+)
	and a.organization_id   = d.organization_id(+)
	and d.cost_type_id(+)   = 1
	and a.organization_id   = 85
	and c.organization_id   = b.organization_id(+)
	and c.locator_id        = b.inventory_location_id(+)
	and c.subinventory_code = 'PPG HR'