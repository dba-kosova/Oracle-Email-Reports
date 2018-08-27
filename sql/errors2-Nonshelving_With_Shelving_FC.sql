
select msi.segment1
, planner_code
, item_type
, attribute7 eau
, cat.category_concat_segs
from mtl_system_items_b msi
, mtl_item_categories_v cat
where msi.organization_id       = 85
	and msi.organization_id        = cat.organization_id(+)
	and inventory_item_status_code = 'Active'
--	and planner_code               = 'SUB'
	and cat.structure_id        = '101'
	and msi.inventory_item_id      = cat.inventory_item_id(+)
	and category_concat_segs = 'BIMFCST.SHEL'
	and planning_make_buy_code = 1
	and planner_code not in ('ACC', 'FC')
	and planner_code not like '%SHV'
--	and msi.segment1 = 'DW-176-2'
