select msi.segment1 
,      ohq_items.on_hand_qty -  nvl(open_orders.sum_ordered_qty, 0) available 
from mtl_system_items_b msi 
,    (select  moqd.inventory_item_id 
      ,       moqd.organization_id 
			 ,      moqd.subinventory_code 
      ,       sum(transaction_quantity) on_hand_qty 
      from mtl_onhand_quantities_detail moqd 
      ,     mtl_item_locations loc 
      where moqd.locator_id = loc.inventory_location_id(+) 
              and exists (select 1  
      from mtl_secondary_inventories si  
      where si.organization_id = moqd.organization_id  
        and si.secondary_inventory_name = moqd.subinventory_code  
        and si.availability_type = 1) 
      group by moqd.inventory_item_id, moqd.subinventory_code 
       ,       moqd.organization_id) OHQ_ITEMS 
       ,       (select oel.inventory_item_id, oel.ship_from_org_id, sum(ordered_quantity) sum_ordered_qty 
                from oe_order_lines_all oel 
                ,    oe_order_headers_all oeh 
                where oel.org_id = 83 
                  and oel.header_id = oeh.header_id 
                  and oeh.open_flag = 'Y' 
                  and oel.open_flag = 'Y' 
                  and oel.shippable_flag = 'Y' 
                  and oel.ordered_quantity > 0 
                  and line_category_code = 'ORDER' 
               group by oel.inventory_item_id, oel.ship_from_org_id) open_orders 
where ohq_items.inventory_item_id = msi.inventory_item_id 
  and ohq_items.organization_id = msi.organization_id 
  and msi.organization_id = 85 
  and msi.inventory_item_id = open_orders.inventory_item_id(+) 
  and msi.organization_id = open_orders.ship_from_org_id(+) 
  and ohq_items.on_hand_qty > NVL(open_orders.sum_ordered_qty, 0) 
	and ohq_items.subinventory_code = 'SHP HR'
	order by 1