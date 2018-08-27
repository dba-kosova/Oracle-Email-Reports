select msi.segment1 "Item"
, msi.planner_code "Planner"
, msi.full_lead_time
, msi.cumulative_total_lead_time "Lead Time"
, greatest(nvl(round(msi.attribute7,1),0), nvl(round(abs(
	(
		select avg(quantity)
		from
			(
				select ord.item_segments
				, round(sum(ord.quantity) ,2) quantity
				, trunc( new_due_date, 'MM')
				from msc_orders_v ord
				where ord.organization_code = 'BIM:BIM'
					and ord.compile_designator = 'BIM'
					and ord.order_type         = 29
					and category_id           in
					(
						select category_id
						from mtl_item_categories_v
						where category_set_id = 1
					)
				group by trunc( new_due_date, 'MM')
				,ord.item_segments
			)
		where item_segments = msi.segment1
	)
	),1),0)) "Max Usage"
, (
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
		where rownum           = 1
			and inventory_item_id =msi.inventory_item_id
	)
	"Safety Stock"
, nvl(priority.category_concat_segs, 'Low') "Priority"
from mtl_system_items_b msi
, mtl_item_categories_v cat
, mtl_item_categories_v priority
where msi.organization_id          = 85
	and priority.category_set_name    = 'BIM Safety Stock Priority'
	and priority.organization_id      = msi.organization_id
	and priority.inventory_item_id    = msi.inventory_item_id
	and cat.structure_id              = '50415'
	and msi.inventory_item_id         = cat.inventory_item_id
	and msi.organization_id           = cat.organization_id
	and inventory_item_status_code    = 'Active'
	and cat.category_concat_segs      = 'Standard'
	and priority.category_concat_segs = 'Manual'