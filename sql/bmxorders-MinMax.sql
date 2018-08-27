select msi.segment1 "Parte"
/*, msi.planner_code
, msi.min_minmax_quantity minimum_quantity
, msi.max_minmax_quantity maximum_quantity
, round(msi.min_minmax_quantity/decode(msi.attribute7,0,1,msi.attribute7),1) minimum_months
, round(msi.max_minmax_quantity/decode(msi.attribute7,0,1,msi.attribute7),1) maximum_months
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') OHQ
, nvl(
	(
		select sum(new_order_quantity) supply_qty
		from msc_supplies mscs
		, msc_system_items msci
		where mscs.inventory_item_id       = msci.inventory_item_id
			and mscs.organization_id          = 90
			and mscs.organization_id          = msci.organization_id
			and mscs.plan_id                  = msci.plan_id
			and mscs.plan_id                  = 21
		--	and msci.planner_code             = 'F-2'
			and mscs.order_type               = 3
			and msci.sr_inventory_item_id     = msi.inventory_item_id
			and mscs.new_order_placement_date < sysdate + 90
		group by msci.item_name
	)
	,0) supply_qty
,nvl(
	(
		select sum(old_demand_quantity)
		from msc_demands mscs
		, msc_system_items msci
		where mscs.inventory_item_id         = msci.inventory_item_id
			and mscs.organization_id            = 90
			and mscs.organization_id            = msci.organization_id
			and mscs.plan_id                    = msci.plan_id
			and mscs.plan_id                    = 21
	--		and msci.planner_code               = 'F-2'
			and mscs.origination_type           = 30
			and mscs.using_assembly_demand_date < sysdate + 90
			and msci.sr_inventory_item_id       = msi.inventory_item_id
	)
	,0) demand_qty
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') - nvl(
	(
		select sum(old_demand_quantity)
		from msc_demands mscs
		, msc_system_items msci
		where mscs.inventory_item_id         = msci.inventory_item_id
			and mscs.organization_id            = 90
			and mscs.organization_id            = msci.organization_id
			and mscs.plan_id                    = msci.plan_id
			and mscs.plan_id                    = 21
	--		and msci.planner_code               = 'F-2'
			and mscs.origination_type           = 30
			and mscs.using_assembly_demand_date < sysdate + 90
			and msci.sr_inventory_item_id       = msi.inventory_item_id
	)
	,0) + nvl(
	(
		select sum(new_order_quantity) supply_qty
		from msc_supplies mscs
		, msc_system_items msci
		where mscs.inventory_item_id       = msci.inventory_item_id
			and mscs.organization_id          = 90
			and mscs.organization_id          = msci.organization_id
			and mscs.plan_id                  = msci.plan_id
			and mscs.plan_id                  = 21
		--	and msci.planner_code             = 'F-2'
			and mscs.order_type               = 3
			and msci.sr_inventory_item_id     = msi.inventory_item_id
			and mscs.new_order_placement_date < sysdate + 90
		group by msci.item_name
	)
	,0) available_quantity
, msi.attribute7 average_usage
, (select attribute7 from mtl_system_Items_b where organization_id = 85 and inventory_item_id= msi.inventory_item_id) bim_usage
	--reorder*/
, (msi.max_minmax_quantity - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') + nvl(
	(
		select sum(old_demand_quantity)
		from msc_demands mscs
		, msc_system_items msci
		where mscs.inventory_item_id         = msci.inventory_item_id
			and mscs.organization_id            = 90
			and mscs.organization_id            = msci.organization_id
			and mscs.plan_id                    = msci.plan_id
			and mscs.plan_id                    = 21
		--	and msci.planner_code               = 'F-2'
			and mscs.origination_type           = 30
			and mscs.using_assembly_demand_date < sysdate + 90
			and msci.sr_inventory_item_id       = msi.inventory_item_id
	)
	,0) - nvl(
	(
		select sum(new_order_quantity) supply_qty
		from msc_supplies mscs
		, msc_system_items msci
		where mscs.inventory_item_id       = msci.inventory_item_id
			and mscs.organization_id          = 90
			and mscs.organization_id          = msci.organization_id
			and mscs.plan_id                  = msci.plan_id
			and mscs.plan_id                  = 21
	--		and msci.planner_code             = 'F-2'
			and mscs.order_type               = 3
			and msci.sr_inventory_item_id     = msi.inventory_item_id
			and mscs.new_order_placement_date < sysdate + 90
		group by msci.item_name
	)
	,0))  "Orden CTD"
from mtl_system_items_b msi

where msi.organization_id    = 90
	--and msi.planner_code        = 'F-2'
	and inventory_planning_code = '2' --min max planning
	and planner_code like '%SHV'
	and (msi.min_minmax_quantity - xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') + nvl(
	(
		select sum(old_demand_quantity)
		from msc_demands mscs
		, msc_system_items msci
		where mscs.inventory_item_id         = msci.inventory_item_id
			and mscs.organization_id            = 90
			and mscs.organization_id            = msci.organization_id
			and mscs.plan_id                    = msci.plan_id
			and mscs.plan_id                    = 21
		--	and msci.planner_code               = 'F-2'
			and mscs.origination_type           = 30
			and mscs.using_assembly_demand_date < sysdate + 90
			and msci.sr_inventory_item_id       = msi.inventory_item_id
	)
	,0) - nvl(
	(
		select sum(new_order_quantity) supply_qty
		from msc_supplies mscs
		, msc_system_items msci
		where mscs.inventory_item_id       = msci.inventory_item_id
			and mscs.organization_id          = 90
			and mscs.organization_id          = msci.organization_id
			and mscs.plan_id                  = msci.plan_id
			and mscs.plan_id                  = 21
	--		and msci.planner_code             = 'F-2'
			and mscs.order_type               = 3
			and msci.sr_inventory_item_id     = msi.inventory_item_id
			and mscs.new_order_placement_date < sysdate + 90
		group by msci.item_name
	)
	,0)>0
)
	
order by 1
, 2
