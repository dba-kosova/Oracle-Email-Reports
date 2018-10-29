select
     ord.item_segments   "Item",
     round(ord.quantity,2) "Quantity",
     order_type_text     "Order Type",
     supplier_name       "Supplier",
     buyer_name          "Buyer",
     order_number        "PO Number"
 from
     msc_orders_v ord
 where
     ord.organization_code = 'BIM:BIM'
     and ord.compile_designator = 'BIM'
     and ord.order_type = 8 -- po in recieving
     and category_id in (
         select
             category_id
         from
             mtl_item_categories_v
         where
             category_set_id = 1
     )
 order by
     new_due_date