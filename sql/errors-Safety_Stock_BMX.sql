select part_number "Item"
, planner_code "Planner"
, max_eau "Usage"
, ssv "Old Safety Stock"
, new_ssv "New Safety Stock"
from
	(
		select part_number
		, planner_code
		, max_eau
		, ssv
		, full_lead_time
		, lead_time
		, bim_lead_time
		, case
				when planner_code           in ( 'BMX-BUY', 'BMX-MAKE') and max_eau > 0
				then greatest(round((max_eau * (nvl(lead_time,full_lead_time)+15)/30.4/5),0)*5,5)
				when nvl(planner_code,'asfd') not in ('BMX-BUY', 'BMX-MAKE') and max_eau > 0
				then greatest(round((max_eau * (nvl(lead_time,full_lead_time)+bim_lead_time + 15)/30.4/5),0)*5,5)
				else 0
			end new_ssv
		from
			(
				select msi.segment1 part_number
				, msi.planner_code
				, msi.full_lead_time
				, msi.cumulative_total_lead_time lead_time
				, (
						select cumulative_total_lead_time
						from mtl_system_items_b
						where inventory_item_id = msi.inventory_item_id
							and organization_id    = 85
					)
					bim_lead_time
				, greatest(nvl(round(msi.attribute7,1),0) , nvl(round(abs(
					(
						select avg(quantity)
						from
							(
								select ord.item_segments
								, round(sum(ord.quantity) ,2) quantity
								, trunc( new_due_date, 'MM')
								from msc_orders_v ord
								where ord.organization_code = 'BMX:BMX'
									and ord.compile_designator = 'BMX'
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
					),1),0)) max_eau
				, (
						select safety_stock_quantity
						from
							(
								select inventory_item_id
								, effectivity_date
								, safety_stock_quantity
								from mtl_safety_stocks
								where organization_id = 90
								order by effectivity_date desc
							)
						where rownum           = 1
							and inventory_item_id =msi.inventory_item_id
					)
					ssv
				from mtl_system_items_b msi
				, mtl_item_categories_v cat
								, mtl_item_categories_v ss_cat

				where msi.organization_id       = 90
					and cat.structure_id        = '50415'
					and msi.inventory_item_id      = cat.inventory_item_id
					and msi.organization_Id = cat.organization_Id
					and inventory_item_status_code = 'Active'
					and
					(
						msi.planner_code          = 'NJIT'
						or planning_make_buy_code = 2
					)
					and item_type not       in ('RAD', 'REF', 'OP', 'TOOL', 'EX')
					and cat.category_concat_segs = 'Standard'
					and planner_code not    in ('OL-SHV', 'ZAPIT')
					and ss_cat.category_set_id(+) = '1100000121'
					and msi.inventory_item_id     = ss_cat.inventory_item_id(+)
					and msi.organization_id       = ss_cat.organization_id(+)
					and nvl(ss_cat.category_concat_segs, 'Low') <> 'Manual'
			)
	
	)
where nvl(new_ssv,0) <> nvl(ssv,0)