select a.segment1 "Item"
, wip_supply_subinventory "Supply Type"
,      c.subinventory_code "On Hand"
,      inv_project.get_pjm_locsegs(b.CONCATENATED_SEGMENTS) "Locator" 
,      c.on_hand_qty "Qty"
from mtl_system_items_b a 
,    APPS.MTL_ITEM_LOCATIONS_KFV b 
,    (SELECT moqd.inventory_item_id 
      ,      moqd.organization_id 
      ,      moqd.subinventory_code 
      ,      moqd.locator_id 
      ,      sum(primary_transaction_quantity) on_hand_qty 
      FROM MTL_ONHAND_QUANTITIES_DETAIL moqd 
     GROUP BY moqd.inventory_item_id, moqd.organization_id, moqd.subinventory_code, moqd.locator_id) c 
where a.organization_id = c.organization_id 
  and a.inventory_item_id = c.inventory_item_id 
  and a.organization_id = 85 
  and c.organization_id = b.organization_id(+) 
  and c.locator_id = b.inventory_location_id(+)
	and a.wip_supply_type = 2
	and a.wip_supply_subinventory <> c.subinventory_code
	and c.subinventory_code not in ('CMP HR', 'PPG HR', 'TOOL FLOOR','DCK HR','TOOL OSV', 'STAGE', 'SHP HR', 'MHINV', 'CMP RCV', 'MRB','RMA','CSD FINAL')