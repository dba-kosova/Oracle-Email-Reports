select decode(a.organization_id, 90,'BMX', 85, 'BIM') "Org"
, a.padded_concatenated_segments "Item"
	--, a.description
, a.requirement_date "Date"
, a.source_type "Reservation Type"
, a.rsv_quantity "Quantity"
, a.sub "Subinventory"
, inv_project.get_pjm_locsegs(b.concatenated_segments) "Locator"
from mtl_reservations_v a
, apps.mtl_item_locations_kfv b
where 1                 =1
	and a.source_type      = 'Cycle Count'
	and a.organization_id in ( 85 , 90)
	and a.organization_id  = b.organization_id(+)
	and a.locator_id       = b.inventory_location_id(+)
order by 1
, 3