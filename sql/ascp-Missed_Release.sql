select p2.organization_code org_code
, msc.item_segments item_number
, msc.description
, msc.new_start_date
, msc.new_due_date
, msc.quantity_rate quantity
,msc.schedule_group_name
,msc.project_number
,msc.planner_code
,msc.order_type_text order_type
,msc.order_number planned_order_number
,msc.buyer_name
,msc.source_vendor_name
,p1.organization_code source_org
, msc.*
from msc_orders_v msc
, mtl_parameters p1
, mtl_parameters p2
, msc_system_items msc_item
where 1                               = 1
	and msc.days_from_today              = 0
	and msc.order_type                   = 5
	and msc.category_set_id              = 1014
	and msc.quantity                    <> 0
	and msc.source_table                 = 'MSC_SUPPLIES'
	and action                           = 'Release'
	and msc.organization_id             in (85, 90)
	and msc.plan_id                      = 21
	and msc.source_organization_id       = p1.organization_id(+)
	and msc.organization_id              = p2.organization_id(+)
	and msc.inventory_item_id            = msc_item.inventory_item_id
	and msc.plan_id                      = msc_item.plan_id
	and msc.organization_id              = msc_item.organization_id
	and msc_item.replenish_to_order_flag = 'N'