select a.segment1 "Item"
, substr(a.description,0,30) "Description"
, c.primary_transaction_quantity "Trx Qty"
, c.subinventory_code "Subinventory"
, inv_project.get_pjm_locsegs(b.concatenated_segments) "Locator"
, c.date_received "Date Recieved"
, round((sysdate - c.date_received)*24,0) "Hours Since Reciept"
from mtl_onhand_quantities_detail c
, apps.mtl_item_locations_kfv b
,mtl_system_items_b a
where a.organization_id  = c.organization_id
	and a.inventory_item_id = c.inventory_item_id
	and a.organization_id   = 85
	and c.organization_id   = b.organization_id(+)
	and c.locator_id        = b.inventory_location_id(+)
	and exists
	(
		select secondary_inventory_name
		from mtl_secondary_inventories_fk_v
		where organization_id                        = 85
			and status_id                               = 100
			and secondary_inventory_name                = c.subinventory_code
			and round((sysdate - c.date_received)*24,0) > 4
	)

order by round((sysdate - c.date_received)*24,0) desc
