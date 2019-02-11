SELECT ord.organization_code,ord.item_segments "Part Number"
,      round(ord.quantity ,2) "Quantity"
,      list_price "List Price"
,      round(amount,2) "Amount"
,      order_type_text "Order Type"
,      supplier_name "Supplier"
,      buyer_name "Buyer"
, old_due_date "Due Date"

FROM msc_orders_v ord
WHERE ord.organization_code = 'BIM:BMX'
  AND ord.compile_designator = 'BIM'
AND ord.order_type = 1 --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
and order_type_text = 'Purchase order'
  --AND ord.item_segments = 'MS-1050'
	and category_id in  (select category_id from mtl_item_categories_v where category_set_id = 1)
order by old_due_date