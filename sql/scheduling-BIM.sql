select msi.segment1 item
, msi.planner_code
, greatest((msi.max_minmax_quantity - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') + nvl(
	(
		select sum(old_demand_quantity)
		from msc_demands mscs
		, msc_system_items msci
		where mscs.inventory_item_id         = msci.inventory_item_id
			and mscs.organization_id            = 85
			and mscs.organization_id            = msci.organization_id
			and mscs.plan_id                    = msci.plan_id
			and mscs.plan_id                    = 21
			and mscs.origination_type           = 30
			and mscs.using_assembly_demand_date < sysdate + 30
			and msci.sr_inventory_item_id       = msi.inventory_item_id
	)
	,0) - nvl(
	(
		select sum(new_order_quantity) supply_qty
		from msc_supplies mscs
		, msc_system_items msci
		where mscs.inventory_item_id       = msci.inventory_item_id
			and mscs.organization_id          = 85
			and mscs.organization_id          = msci.organization_id
			and mscs.plan_id                  = msci.plan_id
			and mscs.plan_id                  = 21
			and mscs.order_type               = 3
			and msci.sr_inventory_item_id     = msi.inventory_item_id
			and mscs.new_order_placement_date < sysdate + 100
		group by msci.item_name
	)
	,0)),nvl(minimum_order_quantity,0)) order_qty
from mtl_system_items_b msi
where msi.organization_id    = 85
	and inventory_planning_code = '2' --min max planning
	and planner_code like '%SHV'
	and
	(
		msi.min_minmax_quantity - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') + nvl(
		(
			select sum(old_demand_quantity)
			from msc_demands mscs
			, msc_system_items msci
			where mscs.inventory_item_id         = msci.inventory_item_id
				and mscs.organization_id            = 85
				and mscs.organization_id            = msci.organization_id
				and mscs.plan_id                    = msci.plan_id
				and mscs.plan_id                    = 21
				and mscs.origination_type           = 30
				and mscs.using_assembly_demand_date < sysdate + 30
				and msci.sr_inventory_item_id       = msi.inventory_item_id
		)
		,0) - nvl(
		(
			select sum(new_order_quantity) supply_qty
			from msc_supplies mscs
			, msc_system_items msci
			where mscs.inventory_item_id       = msci.inventory_item_id
				and mscs.organization_id          = 85
				and mscs.organization_id          = msci.organization_id
				and mscs.plan_id                  = msci.plan_id
				and mscs.plan_id                  = 21
				and mscs.order_type               = 3
				and msci.sr_inventory_item_id     = msi.inventory_item_id
				and mscs.new_order_placement_date < sysdate + 100
			group by msci.item_name
		)
		,0)>0
	)
order by 1
, 3
