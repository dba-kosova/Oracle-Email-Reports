select (select segment1 from mtl_system_items_b where organization_id = mmt.organization_id and inventory_item_id = mmt.inventory_item_id) "Item"
, (select line_code from wip_discrete_jobs_v where organization_id = mmt.organization_id and transaction_source_id = wip_entity_id) "Line"
, subinventory_code "Subinventory"
, (select inv_project.get_pjm_locsegs(b.CONCATENATED_SEGMENTS) Locator 
from APPS.MTL_ITEM_LOCATIONS_KFV b 
where b.organization_id = mmt.organization_id
  and b.inventory_location_id = locator_id) "Locator"
  
,transaction_date
, (select user_name from fnd_user where user_id = mmt.created_by) "User"
, primary_quantity
, primary_quantity* (select item_cost from CST_ITEM_COSTS where cost_type_id = 1 and organization_Id = mmt.organization_id and inventory_item_id = mmt.inventory_item_id) "Cost Value"
, (
		select transaction_type_name
		from mtl_transaction_types
		where transaction_type_id = mmt.transaction_type_id
	)
	"Type"
    
    , (select distinct
   'linepick'
from
    mtl_material_transactions mmt_ship
where
    mmt_ship.organization_id = 85
    and mmt_ship.transaction_date > apps.xxbim_get_calendar_date('BIM', sysdate, - 1)
    and mmt_ship.transaction_type_id in (
        2
    ) -- subinv transfer
    and mmt_ship.transfer_subinventory = 'LINEPICK'

    -- match conditions
    and mmt_ship.inventory_item_id = mmt.inventory_item_id
    and mmt_ship.locator_id = mmt.locator_id
    and abs(mmt_ship.primary_quantity) = abs(mmt.primary_quantity)
    ) "Line Pick"
from mtl_material_transactions mmt
where mmt.organization_id = 85
	and transaction_date     > apps.xxbim_get_calendar_date('BIM', sysdate, -1)
	and transaction_type_id in (44)
order by transaction_date desc