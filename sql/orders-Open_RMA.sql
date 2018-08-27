select rma_number "Order Number"
, character1 "Line"
, oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) "Status"

, nvl(character11,(case when oe_line_status_pub.get_line_status(ola.line_id, ola.flow_status_code) = 'Awaiting Receipt' then 'RCV' else 'CS' end)) "Owner"



, character12  "Repair Job"
, ola.user_item_description "User Item"
, ola.ordered_item "Item"
, ordered_quantity "Quantity"
, qav.qa_creation_date "Creation Date"
, qa_created_by_name  "Created By"
, qav.last_update_date "Update Date"
, qa_last_updated_by_name  "Updated By"
, customer_name "Customer"
, character4  "Drawing"
, character5  "Product"
, character6  "Department"
, character7  "Component"
, character8  "Feature"
, character9  "Defect"
, character10  "Disposition"

, character13  "Type"
, character14  "Result"
, character15  "Disp Category"
, character16  "QA Findings"
, character17  "QTY Defective"
, character18  "Mfg Date"
from qa_results_v qav
, oe_order_lines_all ola
where name               = 'BIM RMA'
	and qav.rma_header_id   = ola.header_id
	and qav.character1      = ola.line_number
	and ola.open_flag       = 'Y'
	and ola.cancelled_flag  = 'N'
	and ola.booked_flag     = 'Y'
	and shippable_flag      = 'Y'
	and qav.organization_id = 85
order by qa_creation_date
