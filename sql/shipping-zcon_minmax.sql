select item "Item"
, location "Location"
, minimum_quantity "Mininum Quantity"
, zcon_inv "ZCON Inventory"
, bim_inv "BIM Inventory"
, demand "Demand"
, order_qty "Order Quantity" 
from (



select msi.segment1 item
      , (
    select max(mil.segment2
                 || '.'
                 || mil.segment3
                 || '.'
                 || mil.segment4)
    from mtl_onhand_quantities_detail moqd
        ,mtl_item_locations_kfv mil
    where moqd.organization_id = mil.organization_id (+)
          and moqd.locator_id = mil.inventory_location_id (+)
          and moqd.subinventory_code in (
        'SHP HR'
       ,'ZCONS'
    )
          and moqd.inventory_item_id = msi.inventory_item_id
          and moqd.organization_id = 85
) location
      ,msi.min_minmax_quantity minimum_quantity
      ,xxbim_get_quantity(msi.inventory_item_id,msi.organization_id,'TQ','ZCONS') zcon_inv
      ,xxbim_get_quantity(msi.inventory_item_id,msi.organization_id,'ATR','SHP HR') bim_inv
      ,nvl( (
    select sum(old_demand_quantity)
    from msc_demands mscs,msc_system_items msci
    where mscs.inventory_item_id = msci.inventory_item_id
          and mscs.organization_id = 85
          and mscs.organization_id = msci.organization_id
          and mscs.plan_id = msci.plan_id
          and mscs.plan_id = 21
          and msci.planner_code = 'ZCON'
		--	and mscs.origination_type           = 30
          and mscs.using_assembly_demand_date < sysdate + 10
          and msci.sr_inventory_item_id = msi.inventory_item_id
),0) demand
      , ( msi.max_minmax_quantity - xxbim_get_quantity(msi.inventory_item_id,msi.organization_id,'ATR') + nvl( (
    select sum(old_demand_quantity)
    from msc_demands mscs,msc_system_items msci
    where mscs.inventory_item_id = msci.inventory_item_id
          and mscs.organization_id = 85
          and mscs.organization_id = msci.organization_id
          and mscs.plan_id = msci.plan_id
          and mscs.plan_id = 21
          and msci.planner_code = 'ZCON'
			--and mscs.origination_type           = 30
          and mscs.using_assembly_demand_date < sysdate + 10
          and msci.sr_inventory_item_id = msi.inventory_item_id
),0) - nvl( (
    select sum(new_order_quantity) supply_qty
    from msc_supplies mscs,msc_system_items msci
    where mscs.inventory_item_id = msci.inventory_item_id
          and mscs.organization_id = 85
          and mscs.organization_id = msci.organization_id
          and mscs.plan_id = msci.plan_id
          and mscs.plan_id = 21
          and msci.planner_code = 'ZCON'
          and mscs.order_type = 3
          and msci.sr_inventory_item_id = msi.inventory_item_id
          and mscs.new_order_placement_date < sysdate + 10
    group by msci.item_name
),0) ) order_qty
from mtl_system_items_b msi
where msi.organization_id = 85
	--and msi.planner_code        = 'F-2'
      and inventory_planning_code = '2' --min max planning
      and planner_code like 'ZCON'
     
order by 1
        ,3
        )
        where order_qty > 0
        order by 4 desc,1