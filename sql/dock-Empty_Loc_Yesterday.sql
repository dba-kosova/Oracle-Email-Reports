select concatenated_segments,msi.segment1

, (select min(mmt_in.transaction_date)
from mtl_material_transactions mmt
, mtl_material_transactions mmt_in
where mmt.organization_id  = 85
    and mmt.organization_id   = mmt_in.organization_id
    and mmt.subinventory_code = mmt_in.subinventory_code
    and mmt.locator_id        = mmt_in.locator_id
    and mmt.inventory_item_id = mmt_in.inventory_item_id
    and mmt.transaction_date between apps.xxbim_get_calendar_date('BIM', sysdate, -1) and trunc(sysdate)
    and mmt.subinventory_code = mil.subinventory_code
    and mmt.locator_id        = mil.inventory_location_id
    ) date_recieved



from mtl_item_locations_kfv mil
, mtl_system_items_b msi
where mil.organization_id  = 85
and mil.organization_id = msi.organization_id
and mil.inventory_item_id = msi.inventory_item_id
    and disable_date     is null
    and subinventory_code = 'DCK HR'
    and empty_flag        = 'Y'
    and not exists
    (
        select locator_id
        from mtl_onhand_quantities_detail
        where locator_id = inventory_location_id
        group by locator_id
    )
    and exists
    (
        select subinventory_code
        , locator_id
        , inventory_item_Id
        from mtl_material_transactions mmt
        where mmt.organization_id = 85
            and transaction_date between apps.xxbim_get_calendar_date('BIM', sysdate, -1) and trunc(sysdate)
            and mmt.subinventory_code = mil.subinventory_code
            and mmt.locator_id        = mil.inventory_location_id
    )
    and (select min(mmt_in.transaction_date)
from mtl_material_transactions mmt
, mtl_material_transactions mmt_in
where mmt.organization_id  = 85
    and mmt.organization_id   = mmt_in.organization_id
    and mmt.subinventory_code = mmt_in.subinventory_code
    and mmt.locator_id        = mmt_in.locator_id
    and mmt.inventory_item_id = mmt_in.inventory_item_id
    and mmt.transaction_date between apps.xxbim_get_calendar_date('BIM', sysdate, -1) and trunc(sysdate)
    and mmt.subinventory_code = mil.subinventory_code
    and mmt.locator_id        = mil.inventory_location_id
    ) < sysdate - 30
order by mil.segment4 desc