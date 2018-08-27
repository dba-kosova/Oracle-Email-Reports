select 
 requisition_header_id "REQ Header"
, requisition_line_id "REQ Line"
, msi.segment1 "Item"
, organization_id "Org"
, pori.creation_date "Created"
, quantity "Quantity"
, authorization_status "Authorization"
, pori.source_organization_id "Source Org"
, destination_organization_id "Dest Org"
, process_flag "Status"
, suggested_vendor_name "Vendor"
, need_by_date "Need by"
, pori.source_type_code "Source Code"
, pori.destination_type_code "Dest Code"

from po_requisitions_interface_all pori
, mtl_system_items_b msi
where 1           =1
	and pori.item_id = msi.inventory_item_id
	and org_id       = 83
	--and pori.source_organization_id in ( 90, 85)
	and msi.organization_id = nvl(pori.source_organization_id,85)
	and process_flag        = 'ERROR'
	and pori.creation_date  > trunc(sysdate)-1
order by 1,2
