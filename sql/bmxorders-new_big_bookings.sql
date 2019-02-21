select 
h.order_number
,l.line_number
,l.shipment_number
,l.ordered_item, l.user_item_description
,l.ordered_quantity
, (select attribute1 from bom_operational_routings b where alternate_routing_designator is null and b.organization_id = l.ship_from_org_id and assembly_item_id = l.inventory_item_id) "Line"
, l.link_to_line_Id, l.top_model_line_id, l.component_sequence_id, line_id
, l.ship_from_org_id
,OE_LINE_STATUS_PUB.Get_Line_Status(l.line_id, l.flow_status_code) status
,nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = l.ship_from_org_id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = l.inventory_item_id), 'Special') "Category"
    
from oe_order_lines_all l
, oe_order_headers_all h
, mtl_system_items_b m
where l.header_id = h.header_id
and h.org_id = 83
and OE_LINE_STATUS_PUB.Get_Line_Status(l.line_id, l.flow_status_code) in ('Booked', 'Supply Eligible')
and l.ship_from_org_id = 85
and l.open_flag = 'Y'
and l.cancelled_flag = 'N'
and ordered_item not in ('BIM-HZ','BIM-IS2','BIM-IS1')
and ordered_item not like '%ATO'
and ((l.shippable_flag = 'Y'
    and (select attribute1 from bom_operational_routings b where alternate_routing_designator is null and b.organization_id = l.ship_from_org_id and assembly_item_id = l.inventory_item_id) in ( 'OL', 'OL-B')
    ) or ordered_item like 'BIM%')
--and h.order_number = '10537177'
and l.inventory_item_id = m.inventory_item_id
and nvl(l.ship_from_org_id,85) = m.organization_id
and planning_make_buy_code = 1
and nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = l.ship_from_org_id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = l.inventory_item_id), 'Special') = 'Standard'
--
and ordered_quantity > 25
order by ordered_quantity desc
