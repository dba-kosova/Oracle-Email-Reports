select msc.item_segments "Item"
, msc.description "Description"
, msc.new_start_date "Start Date"
, msc.new_due_date "Due Date"
, msc.quantity_rate "Quantity"
,msc.planner_code "Planner"
,msc.order_type_text "Order Type"
,msc.order_number "Order Number"
from msc_orders_v msc
, mtl_parameters p1
, mtl_parameters p2
, msc_system_items msc_item
where 1                               = 1
	and msc.days_from_today              < 10
	and msc.order_type                   = 5
	and msc.category_set_id              = 1014
	and msc.quantity                    <> 0
	and msc.source_table                 = 'MSC_SUPPLIES'
	and action                           = 'Release'
	and nvl(msc.planner_code,'NJIT') = 'NJIT'
	and msc.organization_id             = (85)
	and msc.plan_id                      = 21
	and msc.source_organization_id       = p1.organization_id(+)
	and msc.organization_id              = p2.organization_id(+)
	and msc.inventory_item_id            = msc_item.inventory_item_id
	and msc.plan_id                      = msc_item.plan_id
	and msc.organization_id              = msc_item.organization_id
	and msc_item.replenish_to_order_flag = 'N'