-- Steve

		select distinct msi.segment1 item_number
		, msi.description
		, nvl(pend_cost.item_cost, 0) pending_cost
		, nvl(frz_cost.item_cost, 0) frozen_cost
		, decode(msi.organization_id, 85, 'BIM', 90, 'BMX') org
		from mtl_system_items_b msi
		, cst_item_costs frz_cost
		, cst_item_costs pend_cost
		, mtl_item_categories_v mic
	
		where 1                        =1
			and msi.organization_id       = pend_cost.organization_id(+)
			and msi.inventory_item_id     = pend_cost.inventory_item_id(+)
			and pend_cost.cost_type_id(+) = 3
			and msi.organization_id       = frz_cost.organization_id(+)
			and msi.inventory_item_id     = frz_cost.inventory_item_id(+)
			and frz_cost.cost_type_id(+)  = 1
			and msi.organization_id      in ( 85, 90)
			and msi.item_type not        in ('ATO', 'AOC', 'RAD', 'REF', 'OP', 'EX', 'PTO', 'PC')
			and msi.inventory_item_id     = mic.inventory_item_id(+)
			and msi.organization_id       = mic.organization_id(+)
			and mic.category_set_id(+)    = 1
			and msi.inventory_item_status_code <> 'Inactive'
			and nvl(pend_cost.item_cost, 0) <> 0
			and nvl(frz_cost.item_cost, 0) = 0
order by 5,1
