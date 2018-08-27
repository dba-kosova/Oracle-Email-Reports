select exception_type_text "Exception"
, order_number "Job"
, item_segments "Item"
, item_description "Description"
, sum(quantity) "Exception Quantity"
, (
		select sum(round(ord.quantity ,2)) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			and ord.order_type         = 18 --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
			and ord.item_segments      = t.item_segments
			and category_id           in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
	)
	ohq
, (
		select sum(round(ord.quantity ,2)) quantity
		from msc_orders_v ord
		where ord.organization_code = 'BIM:BIM'
			and ord.compile_designator = 'BIM'
			--AND ord.order_type = 18 --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
			and ord.item_segments = t.item_segments
			and category_id      in
			(
				select category_id
				from mtl_item_categories_v
				where category_set_id = 1
			)
			and new_due_date < apps.xxbim_get_calendar_date(85, sysdate, 20)
		group by ord.item_segments
	)
	net_20_days
, planner_code "Planner"
from apps.msc_exception_details_v t
where organization_id    = 85
	and category_set_id     = 1014
	and plan_id             = 21
	and planner_code       in ('MWS','P01','P02','P26','P28','P29','P30', 'NJIT')
	and exception_type      = 84
	and exception_type not in ( 5,9,19, 7) -- 7 is reschedule out
	--and item_segments = 'D-D0695'
group by exception_type_text
, order_number
, order_type
, item_segments
, item_description
, planner_code
order by 7 asc