select msi.segment1 "Item"
, msi.description "Description"
, decode(planning_make_buy_code, 1,'Make',2,'Buy') "Make/Buy"
, planner_code "Planner"
, (
		select max(full_name)
		from per_all_people_f
		where person_id = msi.buyer_id
	)
	"Buyer"
, msi.attribute7 "EAU"
, (select attribute7 from mtl_system_items_b where organization_id = 90 and segment1 = msi.segment1) "BMX EAU"
,minimum_order_quantity "MOQ"
, fixed_days_supply "Fixed Days Supply"
, nvl(frz_cost.item_cost, 0) "Item Cost"
, greatest(minimum_order_quantity-msi.attribute7*3,0) "moq over 3 months"
, greatest(minimum_order_quantity-msi.attribute7*3,0) * nvl(frz_cost.item_cost, 0)"value over 3 months"
, (
		select min(sourcing_rule_name)
		from mrp_sr_assignments_v mis
		where mis.organization_id = msi.organization_id
			and inventory_item_id    = msi.inventory_item_id
	)
	"Sourcing Rule"
, nvl(category_concat_segs,'Special') "Std_Spc"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') "OHQ"
from mtl_system_items_b msi
, cst_item_costs frz_cost
, mtl_item_categories_v cat
where msi.organization_id     = 85
	and planning_make_buy_code   = 2
	and msi.organization_id      = frz_cost.organization_id(+)
	and msi.inventory_item_id    = frz_cost.inventory_item_id(+)
	and frz_cost.cost_type_id(+) = 1
	--and minimum_order_quantity  is not null
	and cat.structure_id(+)      = '50415'
	and msi.organization_id      = cat.organization_id(+)
	and msi.inventory_item_id    = cat.inventory_item_id(+)
	and planner_code not in ('FC', 'TOL', 'REF', 'CAT')
	and planner_code not like '%SHV%'