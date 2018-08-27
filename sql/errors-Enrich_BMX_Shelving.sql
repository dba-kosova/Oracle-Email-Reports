select msi.segment1 "Item"
, 'forecast category should be BIMFCST.SHEL' "Forecast Cat"
from mtl_system_items_b msi
, mtl_item_categories_v cat_fc
where msi.organization_id = 90
	and
	(
		msi.planner_code = 'FC'
		or msi.planner_code like '%SHV%'
	)
	and inventory_item_status_code = 'Active'
	and nvl(cat_fc.category_concat_segs,'asdf') <> 'BIMFCST.SHEL'
	and msi.inventory_item_id                    = cat_fc.inventory_item_id(+)
	and msi.organization_id                      = cat_fc.organization_id(+)
	and cat_fc.category_set_id(+)                = '1100000062'