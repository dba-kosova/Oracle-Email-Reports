select a.segment1 "Item"
,      c.subinventory_code "Subinventory" 
, to_char(txdate,'MM/DD/YY') "Date Recieved"
,      inv_project.get_pjm_locsegs(b.CONCATENATED_SEGMENTS) "Locator" 
,      c.on_hand_qty "Qty"

from mtl_system_items_b a 
,    APPS.MTL_ITEM_LOCATIONS_KFV b 
, MTL_SECONDARY_INVENTORIES msi
,    (SELECT moqd.inventory_item_id 
      ,      moqd.organization_id 
      ,      moqd.subinventory_code 
      ,      max(date_received) txdate
      ,      moqd.locator_id 
      ,      sum(primary_transaction_quantity) on_hand_qty 
      FROM MTL_ONHAND_QUANTITIES_DETAIL moqd 
      GROUP BY moqd.inventory_item_id, moqd.organization_id, moqd.subinventory_code, moqd.locator_id) c 
 
where a.organization_id = c.organization_id 
  and a.inventory_item_id = c.inventory_item_id 
  and a.organization_id = 85 
  and c.organization_id = b.organization_id(+) 
  and c.locator_id = b.inventory_location_id(+)
  and a.wip_supply_type = 1
  and a.organization_id = msi.organization_id
  and msi.disable_date is null
  and msi.reservable_type = 2
  and c.subinventory_code = msi.secondary_inventory_name
  and c.subinventory_code not in ('ZCONS','ACC FINAL','BD FINAL','CMP RCV','BACKFLUSH','CSD FINAL','MRB','MX RCV','RMA','RD FINAL')
  order by c.subinventory_code desc