select distinct 
source_org "Source"
,destination_org "To"
,order_number "ISO Number"
,req_number "Req Number"
, item "Item"
, planner "Planner"
, creation_date "Creation date"

,NEED_BY_DATE "Scheduled Arrival"


, quantity_shipped "Shipped"
, quantity_received "Recieved"
, open_qty "Open"
, shipment_line_status_code "Status"
from(select decode(from_organization_id, 90, 'BMX', 85,'BIM') source_org
, location_code destination_org
,(
		select distinct oha.order_number
		from po_requisition_lines_all prl
		, po_requisition_headers_all prh
		, oe_order_headers_all oha
		where prl.requisition_line_id  = rm.requisition_line_id
			and prl.requisition_header_id = prh.requisition_header_id
			and prh.segment1              = oha.orig_sys_document_ref
	)
	order_number
,(
		select prh.segment1
		from po_requisition_lines_all prl
		, po_requisition_headers_all prh
		where prl.requisition_line_id  = rm.requisition_line_id
			and prl.requisition_header_id = prh.requisition_header_id
	)
	Req_Number
, (
		select segment1
		from mtl_system_items_b
		where organization_id  = from_organization_id
			and inventory_item_id = item_id
	)
item
, (
		select planner_code
		from mtl_system_items_b
		where organization_id  = to_organization_id
			and inventory_item_id = item_id
	)
	Planner
, creation_date 
	,(select prl.NEED_BY_DATE
		from po_requisition_lines_all prl
		, po_requisition_headers_all prh
		where prl.requisition_line_id  = rm.requisition_line_id
			and prl.requisition_header_id = prh.requisition_header_id) NEED_BY_DATE
, quantity_shipped 
, quantity_received 
, quantity_shipped - quantity_received Open_qty
, shipment_line_status_code 
from apps.rcv_msl_v rm
where quantity_shipped - nvl(quantity_received,0) <>0
	and
	(
		to_organization_id       = 85
		and from_organization_id = 90
	)
	or
	(
		to_organization_id       = 90
		and from_organization_id = 85
	)
	and shipment_line_status_code <>'FULLY RECEIVED'
	
union all

select decode(source_organization_Id, 90, 'BMX', 85,'BIM') "From"
, decode(destination_organization_Id, 90, 'BIMBA MFG MEXICO', 85,'BIMBA MFG') "To"
,(
		select distinct oha.order_number
		from po_requisition_lines_all prl
		, po_requisition_headers_all prh
		, oe_order_headers_all oha
		where prl.requisition_line_id  = pr.requisition_line_id
			and prl.requisition_header_id = prh.requisition_header_id
			and prh.segment1              = oha.orig_sys_document_ref
	)
	"ISO Number"
,(
		select prh.segment1
		from po_requisition_lines_all prl
		, po_requisition_headers_all prh
		where prl.requisition_line_id  = pr.requisition_line_id
			and prl.requisition_header_id = prh.requisition_header_id
	)
	"Req Number"
, (
		select segment1
		from mtl_system_items_b
		where organization_id  = destination_organization_Id
			and inventory_item_id = item_id
	)
	"Item"
, (
		select planner_code
		from mtl_system_items_b
		where organization_id  = destination_organization_Id
			and inventory_item_id = item_id
	)
	"Planner"
, creation_date "Creation date"
	,NEED_BY_DATE
, quantity "Shipped"
, quantity_delivered "Recieved"
, quantity - quantity_delivered "Open"
, 'EXPECTED' "Status"
from PO_REQUISITION_LINES_all pr
where nvl(quantity_delivered,0) <> quantity 
and source_Type_code = 'INVENTORY'
and ((source_organization_Id = 85 and destination_organization_Id = 90) or (source_organization_Id = 90 and destination_organization_Id = 85))
and cancel_flag <> 'Y'
and exists ( select * from rcv_msl_v rm
where item_id = pr.item_id
and rm.requisition_line_Id = pr.requisition_Line_Id))
where source_org = 'BIM'
order by 8 asc