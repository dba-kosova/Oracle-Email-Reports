select distinct organization_code, item, was, should_be
from (


select msip.segment1 item, nvl(msip.attribute5,'missing') was, organization_code
, case when msip.attribute5 not like '%:%:%' then 'you fix it..' 
			when substr(msip.attribute5, 0,instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)-1) <> mdev.element_value ||':'||max(msic.segment1) and max(msic.segment1) like 'MS%' then mdev.element_value ||':'||max(msic.segment1) ||':'|| substr(msip.attribute5, instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)+1)
			when substr(msip.attribute5, instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)+1) <> max(msic.segment1) then substr(msip.attribute5, 0,instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)) || max(msic.segment1)
			when msip.attribute5 is null then 'missing'
else 'you fix it..'
end should_be
, case  when msip.attribute5 not like '%:%:%' then 'you fix it..' 
		when substr(msip.attribute5, 0,instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)-1) <> mdev.element_value ||':'||max(msic.segment1) and max(msic.segment1) like 'MS%' then 'ms' 
			when substr(msip.attribute5, instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)+1) <> max(msic.segment1) then 'D'
			when msip.attribute5 is null then 'missing'
			else 'what?'
			end problem
			, max(msic.segment1) segment1
from apps.mtl_system_items_b msip
, apps.bom_structures_b boms
, mtl_descr_element_values mdev
, apps.bom_components_b bomc
, apps.mtl_system_items_b msic
, apps.mtl_parameters mtlp
where boms.assembly_item_id = msip.inventory_item_id
	and boms.organization_id   = msip.organization_id
	--and msip.segment1 like 'ROD%' ---> Parent Item
	and ((msic.segment1 like 'MS-%' and bomc.wip_supply_type <> 4) or (msic.segment1 like 'D-%' and bomc.wip_supply_type = 4)) ---> Child Item
	and mdev.element_name(+) = 'Schedule Group Diameter'
	and msip.planner_code = 'JIT'
	and msip.replenish_to_order_flag = 'Y'
  AND msic.inventory_item_id = mdev.inventory_item_id(+)
		--and bomc.wip_supply_type <> 4
	and boms.organization_id                                    = mtlp.organization_id
	and mtlp.organization_code                                  in ('BIM', 'BMX') 
	and nvl(boms.common_bill_sequence_id,boms.bill_sequence_id) = bomc.bill_sequence_id
	and bomc.component_item_id                                  = msic.inventory_item_id
	and boms.organization_id                                    = msic.organization_id
	and bomc.disable_date                                      is null
  and boms.alternate_bom_designator is null
	and (mdev.element_value <> substr(msip.attribute5,0, instr(msip.attribute5,':')-1)
	or substr(msip.attribute5,instr(msip.attribute5,':')+1, instr(msip.attribute5,':',instr(msip.attribute5,':')+1)-instr(msip.attribute5,':')-1) <> msic.segment1
	or substr(msip.attribute5, instr(msip.attribute5,':',instr(msip.attribute5, ':')+1)+1) <> msic.segment1
	or msip.attribute5 not like '%:%:%'
	or msip.attribute5 is null)
--	and msip.attribute5 is null
	--and msip.segment1 = 'ROD-0472-EF*001C85'
	--and msip.segment1 = 'ROD-0625-OL*005S8P'
	--and msip.segment1 = 'ROD-1000-FO*004BZY-3'
	--and msip.segment1 = 'ROD-0187-OL*002954'
--	and msip.segment1 = 'POST-0250-FO*000CBS'
--and msip.segment1 = 'POST-0500-FO*0002CL'
	and msip.INVENTORY_ITEM_STATUS_CODE = 'Active'
	and msip.segment1 not like 'BEAM%'
	and msip.segment1 not like 'OC%'
	and msip.segment1 not like 'AIR%'
  group by msip.attribute5,msip.segment1,mdev.element_value, organization_code
) 
where 
((problem = 'ms' and segment1 like 'MS%') or (problem = 'D' and segment1 like 'D-%') or problem = 'you fix it..'or was = 'missing')
order by 3 desc