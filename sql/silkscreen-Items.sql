select we.wip_entity_name job
, we.project_name project
, line_code line
, status_type_disp
, msip.segment1 assembly
, msi.segment1 component
, msi.description
, wro.required_quantity
, decode(wro.wip_supply_type, '1', 'Push', '2', 'Assembly Pull', '3', 'Opperation Pull', '4', 'Bulk', '5', 'Supplier', '6', 'Phantom') supply_type
, date_released
from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msi
, mtl_system_items_b msip
where we.organization_id  = 85
	and msip.organization_id = we.organization_id
	and wro.organization_id  = we.organization_id
	and msi.organization_id  = we.organization_id
	and (msi.description like '%Silk%' or msi.description like '%silk%' or msi.description like '%SILK%')
	and we.wip_entity_id       = wro.wip_entity_id(+)
	and wro.inventory_item_id  = msi.inventory_item_id
	and msip.inventory_item_id = we.primary_item_id
	--and wro.wip_supply_type in( '1')
	and we.status_type_disp in ('Released')
	and trunc(date_released) = trunc(sysdate)
	--and we.wip_entity_name  = '1930846'
order by 1
