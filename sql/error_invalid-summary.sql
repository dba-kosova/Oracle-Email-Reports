select oha.order_number "Order Number"
, ola.line_number "Line Number"
, Ordered_item "Item"
, User_item_description "User Item Description"
, OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) 
, to_char(oha.creation_date,'MM/DD/YYYY') "Header Creation Date"
, to_char(oha.creation_date,'HH:MM:SS PM') "Header Creation Time"
, to_char(ola.creation_date,'MM/DD/YYYY') "Line Creation Date"
, to_char(ola.creation_date,'HH:MM:SS PM') "Line Creation Time"
, greatest(oha.booked_date, ola.creation_date) "Ordered Date"
, to_char(ola.request_date,'MM/DD/YYYY') "Request Date"
, ola.attribute18 "Agile ER Number"
from oe_order_lines_all ola
, oe_order_headers_all oha
where ola.header_id = oha.header_id
and ola.org_id = 83
and ola.open_flag = 'Y'
and ola.cancelled_flag = 'N'
and inventory_item_id in (9340212,9340214)
order by greatest(oha.booked_date, ola.creation_date) asc