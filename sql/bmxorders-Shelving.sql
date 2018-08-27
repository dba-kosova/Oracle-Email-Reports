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
	,msi.min_minmax_quantity) "MIN"
, round(msi.attribute7,1) eau
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') atr
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATT') att
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') tq
, (
		select round(sum(ord.quantity) ,2) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			and ord.order_type        in (3,2)
			and quantity               > 0
			and ord.item_segments      = msi.segment1
			and category_id           in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
	)
	"Open Orders"
, (
		select sum(start_quantity)
		from wip_discrete_jobs_v
		where organization_id  =85
			and status_type_disp in ('Released', 'Unreleased')
			--and line_code         = 'OL'
			and primary_item_id =inventory_item_id
	)
	"Open BIM Jobs"
, (
		select round(sum(ord.quantity) ,2) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			and ord.order_type         = 11
			and quantity               > 0
			and ord.item_segments      = msi.segment1
			and category_id           in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
	)
	"In Transit"
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
	,msi.min_minmax_quantity) - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') -nvl(
	(
		select sum(start_quantity)
		from wip_discrete_jobs_v
		where organization_id  =85
			and status_type_disp in ('Released', 'Unreleased')
			--and line_code         = 'OL'
			and primary_item_id =inventory_item_id
	)
	,0) -nvl(
	(
		select round(sum(ord.quantity) ,2) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			and ord.order_type         = 11
			and quantity               > 0
			and ord.item_segments      = msi.segment1
			and category_id           in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
	)
	,0) "Shortage"
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
	and
	(
		planner_code like '%SHV%M'
		or planner_code = 'FC'
	)
order by 13
,nvl(
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
	,msi.min_minmax_quantity) - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') -nvl(
	(
		select sum(start_quantity)
		from wip_discrete_jobs_v
		where organization_id  =85
			and status_type_disp in ('Released', 'Unreleased')
			--and line_code         = 'OL'
			and primary_item_id =inventory_item_id
	)
	,0) -nvl(
	(
		select round(sum(ord.quantity) ,2) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			and ord.order_type         = 11
			and quantity               > 0
			and ord.item_segments      = msi.segment1
			and category_id           in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
	)
	,0) desc
