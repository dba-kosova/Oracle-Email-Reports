select concatenated_segments
from mtl_item_locations_kfv mil
where organization_id  = 85
	and disable_date     is null
	and subinventory_code = 'CMP HR'
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
		from mtl_material_transactions mmt
		where mmt.organization_id = 85
			and transaction_date between apps.xxbim_get_calendar_date('BIM', sysdate, -1) and trunc(sysdate)
			and mmt.subinventory_code = mil.subinventory_code
			and mmt.locator_id        = mil.inventory_location_id
	)
order by 1 asc
