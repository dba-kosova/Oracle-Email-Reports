select msi.segment1 "Item"
, substr(msi.description,0,20) "Description"
, msi.planner_code "Planner"
, nvl(
	(
		select safety_stock_quantity
		from
			(
				select inventory_item_id
				, effectivity_date
				, safety_stock_quantity
				from mtl_safety_stocks
				where organization_id = 85
				order by effectivity_date desc
			)
		where inventory_item_id = msi.inventory_item_id
			and rownum             = 1
	)
	,msi.min_minmax_quantity) "Min"
, round(msi.attribute7,1) "EAU"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') ATR
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATT') ATT
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') TQ
, (
		select round(sum(ord.quantity) ,2) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			and ord.order_type        in (11,3,2)
			and quantity               > 0
			and ord.item_segments      = msi.segment1
			and category_id           in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
	)
	"Open QTY"
, case
		when xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') + nvl((
			(
				select round(sum(ord.quantity) ,2) quantity
				from msc_orders_v ord
				where ord.organization_code = 'BIM:BIM'
					and ord.compile_designator = 'BIM'
					and ord.order_type        in (11,3,2)
					and quantity               > 0
					and ord.item_segments      = msi.segment1
					and category_id           in
					(
						select category_id
						from mtl_item_categories_v
						where category_set_id = 1
					)
			)
			),0) < nvl(
			(
				select safety_stock_quantity
				from
					(
						select inventory_item_id
						, effectivity_date
						, safety_stock_quantity
						from mtl_safety_stocks
						where organization_id = 85
						order by effectivity_date desc
					)
				where inventory_item_id = msi.inventory_item_id
					and rownum             = 1
			)
			,min_minmax_quantity)
		then 'create jobs'
		when xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') < nvl(
			(
				select safety_stock_quantity
				from
					(
						select inventory_item_id
						, effectivity_date
						, safety_stock_quantity
						from mtl_safety_stocks
						where organization_id = 85
						order by effectivity_date desc
					)
				where inventory_item_id = msi.inventory_item_id
					and rownum             = 1
			)
			,min_minmax_quantity) / 2
		then 'expedite'
		else 'ok'
	end "Status"
from mtl_system_items_b msi
where msi.organization_id = 85
	and planner_code like '%SHV'
	--and planner_code not like '%M'
	
order by 10
, nvl(
	(
		select safety_stock_quantity
		from
			(
				select inventory_item_id
				, effectivity_date
				, safety_stock_quantity
				from mtl_safety_stocks
				where organization_id = 85
				order by effectivity_date desc
			)
		where inventory_item_id = msi.inventory_item_id
			and rownum             = 1
	)
	,msi.min_minmax_quantity) - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') desc