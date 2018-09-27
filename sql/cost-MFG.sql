-- Charlie

select *
from
	(
		select msi.segment1 item_number
		, msi.description
		,msi.inventory_item_status_code
		, msi.creation_date item_creation_date
		, msi.item_type
		, msi.planner_code
		, mic.category_concat_segs inv_category
		, decode(msi.planning_make_buy_code, '1', 'Make', '2', 'Buy','None') make_buy
			--, XXBIM_GET_SOURCE_INFO(msi.inventory_item_id, msi.organization_id, 1, 'SOURCE_TYPE') SRC_RULE_MAKE_BUY
		, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id) on_hand_qty
		, msi.attribute7 avg_usage
		, msi.LIST_PRICE_PER_UNIT
		, nvl(pend_cost.item_cost, 0) pending_cost
		, nvl(frz_cost.item_cost, 0) frozen_cost
		, decode(msi.organization_id, 85, 'BIM', 90, 'BMX') org
		, decode (
			(
				select count(1) from bom_operational_routings where organization_id = msi.organization_id
					and assembly_item_id                                               = msi.inventory_item_id
			)
			, 1, 'Router', 'No Router') router
		, where_used.parent_item
        , where_used.inventory_item_status_code "Parent Status Code"
		, where_used.parent_creation_date
		from mtl_system_items_b msi
		, cst_item_costs frz_cost
		, cst_item_costs pend_cost
		, mtl_item_categories_v mic
		, (
				select p.segment1 parent_item
				, bom.organization_id
				, comp.component_item_id
				, p.creation_date parent_creation_date
                , inventory_item_status_code
				from mtl_system_items_b p
				, bom_structures_b bom
				, bom_components_b comp
				where bom.organization_id          = p.organization_id
					and bom.assembly_item_id          = p.inventory_item_id
					and bom.bill_sequence_id          = comp.bill_sequence_id
					and bom.alternate_bom_designator is null
			)
			where_used
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
			and msi.inventory_item_id     = where_used.component_item_id(+)
			and msi.organization_id       = where_used.organization_id(+)
	)
	c
where c.frozen_cost = 0
order by c.item_number
, c.parent_item
