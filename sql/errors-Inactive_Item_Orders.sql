select inventory_item_status_code
      ,h.order_number
      ,o.line_number
      ,o.shipment_number
      ,o.*
from oe_order_lines_all o
    ,oe_order_headers_all h
    ,mtl_system_items_b msi
where o.open_flag = 'Y'
      and o.header_id = h.header_id
      and o.cancelled_flag = 'N'
      and o.shippable_flag = 'Y'
      and o.ordered_item_id = msi.inventory_item_id
      and o.ship_from_org_id = msi.organization_id
      and inventory_item_status_code <> 'Active'
      and o.org_id = 83
      and o.line_type_id <> 1073