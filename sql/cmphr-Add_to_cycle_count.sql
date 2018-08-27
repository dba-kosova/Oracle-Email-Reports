select a.segment1 
,      c.subinventory_code 
,      inv_project.get_pjm_locsegs(b.CONCATENATED_SEGMENTS) Locator 

, items.priorty

from mtl_system_items_b a 
,    APPS.MTL_ITEM_LOCATIONS_KFV b 
,    (SELECT moqd.inventory_item_id 
      ,      moqd.organization_id 
      ,      moqd.subinventory_code 
      ,      moqd.locator_id 
      ,      sum(primary_transaction_quantity) on_hand_qty 
      FROM MTL_ONHAND_QUANTITIES_DETAIL moqd 
      GROUP BY moqd.inventory_item_id, moqd.organization_id, moqd.subinventory_code, moqd.locator_id) c 
 , (select msi.segment1 component, count(1) priorty

from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msi
, mtl_system_items_b msip
,apps.bom_structures_b boms
, apps.bom_components_b bomc
where we.organization_id  = 85
	and msip.organization_id = we.organization_id
	and wro.organization_id  = we.organization_id
	and msi.organization_id  = we.organization_id
	--and msip.segment1 like 'FO-091%'
	and we.wip_entity_id                                        = wro.wip_entity_id
	and wro.inventory_item_id                                   = msi.inventory_item_id
	and msip.inventory_item_id                                  = we.primary_item_id
	and wro.wip_supply_type                                     ='1'
	and we.status_type_disp                                     ='Released'
	and trunc(wro.last_update_date)                             = apps.xxbim_get_calendar_date('BIM',sysdate,-1)
	and APPS.XXBIM_GET_WORKING_DAYS(85, date_released,wro.last_update_date)<= 3

	and boms.assembly_item_id                                   = msip.inventory_item_id
	and boms.organization_id                                    = msip.organization_id
	and boms.organization_id                                    = we.organization_id
	and nvl(boms.common_bill_sequence_id,boms.bill_sequence_id) = bomc.bill_sequence_id
	and bomc.component_item_id                                  = msi.inventory_item_id
	and boms.organization_id                                    = msi.organization_id
	and bomc.disable_date                                      is null
	and bomc.component_quantity* we.start_quantity <> wro.required_quantity 
	group by msi.segment1,msi.inventory_item_id
	) items

where a.organization_id = c.organization_id 
  and a.inventory_item_id = c.inventory_item_id 
  and a.organization_id = 85 
	and c.subinventory_code in ('CMP HR', 'PPG HR')
  and c.organization_id = b.organization_id(+) 
  and c.locator_id = b.inventory_location_id(+)
	and a.segment1 = items.component
	and exists (select subinventory_code, inventory_item_id
from mtl_material_transactions mmt
where mmt.organization_id = 85
	and transaction_date     > APPS.XXBIM_GET_CALENDAR_DATE('BIM',sysdate,-2)
	and transaction_type_id = 35
	and subinventory_code in ('CMP HR', 'PPG HR')
	and inventory_item_id = a.inventory_item_id
	and subinventory_code = c.subinventory_code
) 
	order by 2,  items.priorty desc