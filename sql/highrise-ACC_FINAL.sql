select a.segment1
      ,c.subinventory_code
      ,c.on_hand_qty
      ,date_received
from mtl_system_items_b a
    ,apps.mtl_item_locations_kfv b
    , (
    select moqd.inventory_item_id
          ,moqd.organization_id
          ,moqd.subinventory_code
          ,moqd.locator_id
          ,sum(primary_transaction_quantity) on_hand_qty
          ,max(date_received) date_received
    from mtl_onhand_quantities_detail moqd
    group by moqd.inventory_item_id
            ,moqd.organization_id
            ,moqd.subinventory_code
            ,moqd.locator_id
) c
where a.organization_id = c.organization_id
      and a.inventory_item_id = c.inventory_item_id
      and a.organization_id = 85
      and c.organization_id = b.organization_id (+)
      and c.locator_id = b.inventory_location_id (+)
      and c.subinventory_code = 'ACC FINAL'
order by date_received asc