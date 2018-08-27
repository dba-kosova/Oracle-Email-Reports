select we.date_released "Date Released", we.wip_entity_name "Job"
, we.project_name "Project"
, line_code "Line"
, msip.segment1 "Assembly"
, msi.segment1 "Component"
, msi.description "Description"
, wro.required_quantity "Open Qty"
--, wro.quantity_issued "Qty Issued"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') "On Hand"
--, decode(wro.quantity_issued, 0, 'No', 'Yes') issued_or_not
, decode(wro.wip_supply_type, '1', 'Push', '2', 'Assembly Pull', '3', 'Opperation Pull', '4', 'Bulk', '5', 'Supplier', '6', 'Phantom') "Supply Type"
, wro.supply_subinventory "Subinv"
from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msi
, mtl_system_items_b msip
where we.organization_id  = 85
	and msip.organization_id = we.organization_id
	and wro.organization_id  = we.organization_id
	and msi.organization_id  = we.organization_id
	and wro.wip_supply_type = 1
	and quantity_issued = 0
		and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
	and msip.inventory_item_id = we.primary_item_id
	--and wro.wip_supply_type in( '1')
	and we.status_type_disp = 'Released'
	and not exists (-- closed mo
SELECT   *
FROM mtl_txn_request_lines tol,
  mtl_material_transactions mmt
WHERE 1=1 
AND tol.line_id               = mmt.move_order_line_id
AND tol.organization_id       = 85
AND mmt.organization_id       = 85
AND mmt.organization_id       = tol.organization_id
and mmt.creation_date > sysdate-90
and mmt.TRANSACTION_SOURCE_ID = we.wip_entity_id
--
)
and not exists (-- open move orders
SELECT *
  FROM 
  mtl_txn_request_lines tol,
  mtl_material_transactions_temp mmtt
WHERE 1=1
AND tol.line_id              = mmtt.move_order_line_id
AND mmtt.organization_id     = 85
AND mmtt.organization_id     = tol.organization_id
and mmtt.TRANSACTION_SOURCE_ID = we.wip_entity_id
)