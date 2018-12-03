select (select segment1 from mtl_system_items_b where organization_id = mmt.organization_id and inventory_item_id = mmt.inventory_item_id) "Item Number"
, primary_quantity "Adustment Qty"
, (select PRIMARY_UNIT_OF_MEASURE from mtl_system_items_b where organization_id = mmt.organization_id and inventory_item_id = mmt.inventory_item_id) "Unit of Measure"
, subinventory_code "Subinventory"
, (select inv_project.get_pjm_locsegs(b.CONCATENATED_SEGMENTS) 
from APPS.MTL_ITEM_LOCATIONS_KFV b 
where b.organization_id = mmt.organization_id
  and b.inventory_location_id = locator_id) "Locator"
  , (select user_name from fnd_user where user_id = mmt.created_by) "User Name"
    ,ACTUAL_COST "Unit Cost"
    , primary_quantity* ACTUAL_COST "Total Value"
    , abs(primary_quantity* ACTUAL_COST) "Net Value"
    , (select
    category_concat_segs
from
    mtl_item_categories_v ccs
where 1=1
    and mmt.inventory_item_id = ccs.inventory_item_id
    and mmt.organization_id = ccs.organization_id
    and ccs.structure_id = 50495

    ) "9 Box"

, (select max(approval_date)
from mtl_abc_classes abc		
, mtl_cycle_count_classes cla		
, mtl_cycle_count_headers cch		
, mtl_cycle_count_items cci		
, mtl_cycle_count_entries cce		
where cch.organization_id      = 85--:P_ORG_ID		
	and cch.organization_id       = mmt.organization_id	
	and cci.inventory_item_id     = mmt.inventory_item_id	
	and cce.organization_id       = 85--:P_ORG_ID	
	and cce.inventory_item_id     = cci.inventory_item_id	
	and cci.abc_class_id          = abc.abc_class_id	
	and cci.abc_class_id          = cla.abc_class_id	
	and cla.cycle_count_header_id = cch.cycle_count_header_id 
	and cla.organization_id       = 85                        
	and abc.organization_id       = 85                        
	and cci.cycle_count_header_id = cch.cycle_count_header_id 
	and cce.cycle_count_header_id = cch.cycle_count_header_id
	and	
	(	
		cce.entry_status_code    = 5
		or cce.entry_status_code = 2
		or cce.entry_status_code = 3
	)	
	and cce.count_type_code <> 4	
    and cce.subinventory = mmt.subinventory_code
   and nvl(cce.locator_id,'0') = nvl(mmt.locator_id,'0')
   ) "Last Cycle Count"
  ,TRANSACTION_REFERENCE "Comments"
,transaction_date "Date"

, (
		select transaction_type_name
		from mtl_transaction_types
		where transaction_type_id = mmt.transaction_type_id
	)
	"Type"
	, (select description from MTL_GENERIC_DISPOSITIONS where organization_id = mmt.organization_id and disposition_id = transactiON_source_id) "Account"
    
   , (select max(transaction_date)
from mtl_material_transactions mmt2
where mmt2.organization_id = mmt.organization_id
and mmt2.inventory_item_id = mmt.inventory_item_id
and mmt2.subinventory_code = mmt.subinventory_code
and mmt2.primary_quantity > 0
and mmt2.locator_id = mmt.locator_id
) "Last Reciept"
from mtl_material_transactions mmt
where mmt.organization_id = 85
	and transaction_date     > apps.xxbim_get_calendar_date('BIM', sysdate, -1)
    and transaction_date < trunc(sysdate)
    and mmt.subinventory_code not in ('TOOL CRIB', 'TOOL FLOOR')
	and transaction_type_id in (31,41)

