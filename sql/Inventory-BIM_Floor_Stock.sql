select item "Item"
, item_small "Part"
, planner_code "Planner"
, item_type "Type"
, status "Status"
, item_cost "Cost"
	, round(avg(std_wip_usage),2) wip_avg
	, round(stddev(std_wip_usage),2) wip_stdv
	,wip_supply_subinventory
, decode(count(1),0,0,round(sum(has_orders)/ count(1),2)) "Weeks Demand"
, fc "FC Cat"
, std "Std Cat"
from
	(
		select items.item
		, item_small
		, items.item_type
		, items.item_cost
		, items.planner_code
		, items.eau
		, items.inventory_item_id item_id
		, items.inventory_planning_code
		, items.planning_make_buy_code
		, items.min_minmax_quantity
		, items.max_minmax_quantity
		, items.organization_id org_id
		,items.ss_value
		, items.std
		, items.fc
		,wip_supply_subinventory
		, items.ss
		,status
		, items.inventory_item_id
		, decode(items.organization_id, 90,'BMX', 85, 'BIM') org
		, decode(planning_make_buy_code, 1,'Make', 'Buy') make_buy
		, nvl(v.sales_order_demand,0) sales_order_demand
		, nvl(v.miscellaneous_issue,0) miscellaneous_issue
		, nvl(v.interorg_issue,0) interorg_issue
		, nvl(decode(nvl(v.sales_order_demand,0)+ nvl(v.std_wip_usage,0),0,0,1),0) has_orders
		, nvl(std_wip_usage,0) std_wip_usage
		from
			(
				select item
				, item_small
				, planner_code
				, item_type
				, item_cost
				, eau
				,wip_supply_subinventory
				, inventory_item_id
				, inventory_planning_code
				, planning_make_buy_code
				, min_minmax_quantity
				, max_minmax_quantity
				, organization_id
				,status
				,ss_value
				, std
				, fc
				, ss
				, dt
				from
					(
						select msi.segment1 item
						, nvl(substr(msi.segment1, 0,instr(msi.segment1, '*')-1), msi.segment1) item_small
						, planner_code
						, item_type
						, item_cost
						, msi.attribute7 eau
						, msi.inventory_item_id inventory_item_id
						, msi.inventory_planning_code
						, planning_make_buy_code
						, min_minmax_quantity
						, max_minmax_quantity
						,wip_supply_subinventory
						, msi.organization_id
						, msi.inventory_item_status_code status
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
									and inventory_item_id = msi.inventory_item_id
							)
							ss_value
						, nvl(cat.category_concat_segs,'Special') std
						, cat_fc.category_concat_segs fc
						, case
								when cat.category_concat_segs = 'Standard'
								then nvl(ss_cat.category_concat_segs,'Low')
								else ss_cat.category_concat_segs
							end ss
						from mtl_system_items_b msi
						, mtl_item_categories_v cat
						, mtl_item_categories_v ss_cat
						, mtl_item_categories_v cat_fc
						, cst_item_costs cic
						where 1                        =1
							and msi.organization_id       = 85
							and msi.organization_id       = cat.organization_id(+)
							and cat.category_set_id(+)    = '1100000101'
							and msi.inventory_item_id     = cat.inventory_item_id(+)
							and ss_cat.category_set_id(+) = '1100000121'
							and msi.inventory_item_id     = ss_cat.inventory_item_id(+)
							and msi.organization_id       = ss_cat.organization_id(+)
							and msi.inventory_item_id     = cat_fc.inventory_item_id(+)
							and msi.organization_id       = cat_fc.organization_id(+)
							and cat_fc.category_set_id(+) = '1100000062'
							and cic.cost_type_id(+)       = 1
							and msi.inventory_item_id     = cic.inventory_item_id(+)
							and (wip_supply_subinventory like '%COMP' or wip_supply_subinventory in ('OL RH', 'OL RG'))
							and msi.organization_id       = cic.organization_id(+)
							and msi.planner_code not     in ( 'JIT', 'REF', 'TOL', 'TPK', 'CAT')
							and item_type not            in ('TOOL', 'DSP', 'TOOL PKG')
							--and planning_make_buy_code    = 1
							--and planner_code not         in ('NJIT', 'SUB', 'SUB-ATO', 'FO CSD Obs')
					)
					a
				, (
						select sysdate - (rownum*7) dt
						from dual
							connect by rownum < 53
					)
					b
			)
			items
		, (
				select nvl(substr(msi.segment1, 0,instr(msi.segment1, '*')-1), msi.segment1) item
				, mdh.organization_id
				, period_start_date
				, sum(std_wip_usage) std_wip_usage
				, sum(sales_order_demand) sales_order_demand
				, sum(miscellaneous_issue) miscellaneous_issue
				, sum(interorg_issue) interorg_issue
				from apps.mtl_demand_histories mdh
				, mtl_system_items_b msi
				where 1                    =1--msi.inventory_item_id = '9479168'
					and msi.inventory_item_id = mdh.inventory_item_id
					and msi.organization_id   =mdh.organization_id
					and closed_flag           = 'Y'
				group by nvl(substr(msi.segment1, 0,instr(msi.segment1, '*')-1), msi.segment1)
				, mdh.organization_id
				, period_start_date
			)
			v
		where trunc(items.dt, 'WW') = trunc(v.period_start_date(+), 'WW')
			and items.item_small       = v.item(+)
			and items.organization_id  = v.organization_id(+)
	)
group by org
, item
, item_small
, planner_code
, item_type
, item_cost
, std
, ss
, fc
, ss_value
, eau
, make_buy
,min_minmax_quantity
,max_minmax_quantity
,status
,wip_supply_subinventory
