select distinct msip.segment1 item 
, msic.segment1 child_item 
,      br.resource_code Res 
, to_number(mdev.element_value)/1000

, case when to_number(mdev.element_value)/1000 <= .312 and br.resource_code <> 'RD100' 
					or .312 < to_number(mdev.element_value)/1000 and to_number(mdev.element_value)/1000 <= .394 and br.resource_code <> 'RD102' 
					or .394 < to_number(mdev.element_value)/1000 and to_number(mdev.element_value)/1000 <= .562 and br.resource_code <> 'RD104' 
					or .562 < to_number(mdev.element_value)/1000 and br.resource_code <> 'RD106' 
					then 'error'
				else 'ok' end "error?"
, case when to_number(mdev.element_value)/1000 <= .312 and br.resource_code <> 'RD100'  then 'RD100'
			 when .312 < to_number(mdev.element_value)/1000 and to_number(mdev.element_value)/1000 <= .394 and br.resource_code <> 'RD102'  then 'RD102'
			 when .394 < to_number(mdev.element_value)/1000 and to_number(mdev.element_value)/1000 <= .562 and br.resource_code <> 'RD104'  then 'RD104'
			 when .562 < to_number(mdev.element_value)/1000 and br.resource_code <> 'RD106'  then 'RD106'
					
				else 'ok' end should_be
from apps.mtl_system_items_b msip 
, apps.bom_structures_b boms 
, apps.bom_components_b bomc 
, apps.mtl_system_items_b msic 
, apps.mtl_parameters mtlp 
,    bom_operational_routings boro 
,    bom_operation_sequences bos 
,    bom_operation_resources bore 
,    bom_resources br 
   , mtl_descr_element_values mdev

where boms.assembly_item_id = msip.inventory_item_id 
	and boms.organization_id   = msip.organization_id 
	and msip.segment1 like '%ROD%' 
		and mdev.element_name(+) = 'Schedule Group Diameter'
  AND msic.inventory_item_id = mdev.inventory_item_id(+)
--and msip.segment1 = 'GUIDE_ROD-0177-EF*001P7P'
	and msic.segment1 like 'MS%' 
	and boro.attribute1 = 'JIT' 
	and boms.organization_id                                    = mtlp.organization_id 
	and mtlp.organization_code                                  = 'BIM' 
	and nvl(boms.common_bill_sequence_id,boms.bill_sequence_id) = bomc.bill_sequence_id 
	and bomc.component_item_id                                  = msic.inventory_item_id 
	and boms.organization_id                                    = msic.organization_id 
	and bomc.disable_date                                      is null 
	and msip.INVENTORY_ITEM_STATUS_CODE = 'Active' 
	  and msip.organization_id = br.organization_id 
  and msip.inventory_item_id = boro.assembly_item_id 
  and boro.routing_sequence_id = bos.routing_sequence_id 
  and bos.operation_sequence_id = bore.operation_sequence_id 
  and bore.resource_id = br.resource_id 
  and bos.disable_date is null 
  and br.resource_code like 'RD1%' 
  and boro.alternate_routing_designator is null
	and (case when to_number(mdev.element_value)/1000 <= .312 and br.resource_code <> 'RD100' 
					or .312 < to_number(mdev.element_value)/1000 and to_number(mdev.element_value)/1000 <= .394 and br.resource_code <> 'RD102' 
					or .394 < to_number(mdev.element_value)/1000 and to_number(mdev.element_value)/1000 <= .562 and br.resource_code <> 'RD104' 
					or .562 < to_number(mdev.element_value)/1000 and br.resource_code <> 'RD106' 
					then 'error'
				else 'ok' end) <> 'ok'
		and br.resource_code in ('RD100', 'RD102','RD104', 'RD106')