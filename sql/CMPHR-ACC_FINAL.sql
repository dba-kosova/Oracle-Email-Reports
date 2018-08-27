SELECT
    a.segment1,
    c.subinventory_code,
    c.on_hand_qty
FROM
    mtl_system_items_b a,
    apps.mtl_item_locations_kfv b,
    (
        SELECT
            moqd.inventory_item_id,
            moqd.organization_id,
            moqd.subinventory_code,
            moqd.locator_id,
            SUM(primary_transaction_quantity) on_hand_qty
        FROM
            mtl_onhand_quantities_detail moqd
        GROUP BY
            moqd.inventory_item_id,
            moqd.organization_id,
            moqd.subinventory_code,
            moqd.locator_id
    ) c
WHERE
    a.organization_id = c.organization_id
    AND   a.inventory_item_id = c.inventory_item_id
    AND   a.organization_id = 85
    AND   c.organization_id = b.organization_id (+)
    AND   c.locator_id = b.inventory_location_id (+)
    AND   c.subinventory_code = 'ACC FINAL'