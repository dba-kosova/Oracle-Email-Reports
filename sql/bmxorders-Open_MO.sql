-- open move orders
select toh.header_id "Move Order"
, mmtt.pick_slip_number "Pick Slip"
, toh.creation_date "Created"
, tol.line_number "MO Line"
, msi.segment1 "Part"
, vl3.meaning "Source"
, vl2.meaning "Type"
, mtt.transaction_type_name "Transaction Type"
, vl.meaning "Status"
, tol.quantity - nvl(tol.quantity_delivered,0) "Open Qty"
, usr.user_name "Created By"
, mmtt.subinventory_code "Subinv"
, inv_project.get_pjm_locsegs(b.concatenated_segments) "Locator"
, mmtt.department_code "Line"
, wdj.wip_entity_name "Job"
,wdj.project_name "Project"
from mtl_txn_request_headers toh
, mtl_txn_request_lines tol
, mtl_material_transactions_temp mmtt
, fnd_lookup_values_vl vl
, fnd_lookup_values_vl vl2
, fnd_lookup_values_vl vl3
, mtl_transaction_types mtt
, apps.fnd_user usr
, mtl_system_items_b msi
, apps.mtl_item_locations_kfv b
, wip_discrete_jobs_v wdj
where toh.header_id             = tol.header_id
	and vl.lookup_type             = 'MTL_TXN_REQUEST_STATUS'
	and vl.lookup_code             = tol.line_status
	and toh.organization_id        = tol.organization_id
	and vl.meaning                not in( 'Canceled by Source', 'Closed')
	and tol.line_id                = mmtt.move_order_line_id
	and vl2.lookup_type            = 'MOVE_ORDER_TYPE'
	and vl2.lookup_code            = toh.move_order_type
	and vl3.lookup_type            = 'INV_RESERVATION_SOURCE_TYPES'
	and vl3.lookup_code            = mmtt.transaction_source_type_id
	and mmtt.transaction_type_id   = mtt.transaction_type_id
	and usr.user_id                = toh.created_by
	and mmtt.organization_id       = 90
	and mmtt.organization_id       = msi.organization_id
	and mmtt.organization_id       = tol.organization_id
	and tol.inventory_item_id      = msi.inventory_item_id
	and mmtt.organization_id       = b.organization_id(+)
	and mmtt.locator_id            = b.inventory_location_id(+)
	and mmtt.organization_id       = wdj.organization_id(+)
	and mmtt.transaction_source_id = wdj.wip_entity_id(+)
order by toh.creation_date asc