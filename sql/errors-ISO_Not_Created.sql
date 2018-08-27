SELECT req.creation_date, req.req_number, req.source_type, req.line_num, req.transferred_to_oe_flag, oe.order_number, oe.line_number, req.segment1, req.description, req.quantity, req.need_by_date, req.authorization_status
FROM (SELECT poh.segment1 REQ_NUMBER, pol.LINE_NUM, poh.creation_date, pol.TRANSFERRED_TO_OE_FLAG, msi.segment1, substr(msi.description, 1, 50) DESCRIPTION , pol.source_type_code source_type
           , pol.quantity, pol.NEED_BY_DATE, pol.DESTINATION_ORGANIZATION_ID, pol.SOURCE_ORGANIZATION_ID, poh.AUTHORIZATION_STATUS, poh.REQUISITION_HEADER_ID, pol.REQUISITION_LINE_ID
      FROM PO_REQUISITION_HEADERS_ALL poh
         , PO_REQUISITION_LINES_ALL pol
         , mtl_system_items_b msi
      WHERE 1=1
       AND poh.org_id = 83 
       AND poh.requisition_header_id = pol.requisition_header_id
       AND poh.creation_date > '01-JAN-2015'
       and pol.source_type_code <> 'VENDOR'
       AND poh.type_lookup_code = 'INTERNAL'
       AND pol.item_id = msi.inventory_item_id
       AND pol.DESTINATION_ORGANIZATION_ID = msi.organization_id
       AND poh.authorization_status <> 'CANCELLED') req
    , (SELECT order_number, line_number, oeh.ORIG_SYS_DOCUMENT_REF, oel.ORIG_SYS_LINE_REF
       FROM oe_order_headers_all oeh
          , oe_order_lines_all oel
      WHERE oeh.header_id = oel.header_id
        AND oeh.order_source_id = 10) oe
WHERE 1=1
  AND req.req_number = oe.orig_sys_document_ref(+)
  AND req.line_num = oe.orig_sys_line_ref(+)
  AND (nvl(req.transferred_to_oe_flag, 'N') = 'N' OR oe.order_number IS NULL)
ORDER BY creation_date desc, req_number desc
