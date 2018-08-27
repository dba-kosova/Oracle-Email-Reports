select we.date_released "Date Released"
, we.status_type_disp "Status"
, we.wip_entity_name "Job"
, we.project_name "Project"
, line_code "Line"
, msip.segment1 "Parent"
, msi.segment1 "Component"
, msi.description "Description"
, wro.required_quantity "Quantity Required"
, wro.quantity_issued "Quantity Issued"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') "On Hand"
, decode(wro.quantity_issued, 0, 'No', 'Yes') "Issued?"
, decode(wro.wip_supply_type, '1', 'Push', '2', 'Assembly Pull', '3', 'Opperation Pull', '4', 'Bulk', '5', 'Supplier', '6', 'Phantom') supply_type
, wro.supply_subinventory
from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msi
, mtl_system_items_b msip
where we.organization_id    = 90
	and msip.organization_id   = we.organization_id
	and wro.organization_id    = we.organization_id
	and msi.organization_id    = we.organization_id
	and wro.wip_supply_type    = 1
	and quantity_issued       <> wro.required_quantity
	and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
	and msip.inventory_item_id = we.primary_item_id
	and (we.status_type_disp    = 'Released' or (we.status_type_disp in ('Complete') and date_completed > sysdate-31))
order by 1
