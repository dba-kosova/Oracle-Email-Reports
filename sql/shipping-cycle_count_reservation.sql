select
    msi.segment1,
    mra.reservation_quantity,
    mra.subinventory_code,
    inv_project.get_pjm_locsegs(b.concatenated_segments) locator,
    mra.creation_date
from
    mtl_reservations_all_v mra,
    mtl_system_items_b msi,
    apps.mtl_item_locations_kfv b
where
    mra.organization_id = 85
    and mra.organization_id = msi.organization_id
    and mra.inventory_item_id = msi.inventory_item_id
    and mra.organization_id = b.organization_id (+)
    and mra.locator_id = b.inventory_location_id (+)
    and demand_source_type = 'Cycle Count'