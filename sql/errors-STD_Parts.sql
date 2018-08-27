select mtlp.organization_code 
,msip.segment1 item
, msic.segment1 child_item
, catp.category_concat_segs cat_p
, catc.category_concat_segs cat_c
from apps.mtl_system_items_b msip
, apps.bom_structures_b boms
, apps.bom_components_b bomc
, apps.mtl_system_items_b msic
, apps.mtl_parameters mtlp
, MTL_ITEM_CATEGORIES_V catc
, MTL_ITEM_CATEGORIES_V catp
where boms.assembly_item_id = msip.inventory_item_id
	and boms.organization_id   = msip.organization_id
	--and msip.segment1 like 'OC_BIM%' ---> Parent Item
	--and msic.segment1 like 'D-16247' ---> Child Item
	and boms.organization_id                                    = mtlp.organization_id
	and mtlp.organization_code                                in ('BIM','BMX')
	and nvl(boms.common_bill_sequence_id,boms.bill_sequence_id) = bomc.bill_sequence_id
	and bomc.component_item_id                                  = msic.inventory_item_id
	and boms.organization_id                                    = msic.organization_id
	and bomc.disable_date                                      is null
	and msip.INVENTORY_ITEM_STATUS_CODE = 'Active'
	and catc.structure_id(+) = '50415'
	and catp.structure_id(+) = '50415'
	and msip.inventory_item_id = catp.inventory_item_id(+)
	and msic.inventory_item_id = catc.inventory_item_id(+)
	and msip.organization_id = catp.organization_id(+)
and catp.category_concat_segs = 'Standard'
and nvl(catc.category_concat_segs,1) <> 'Standard'
and msic.organization_id = catc.organization_id(+)
union all
select 'BMX'
, msi.segment1
,null
, decode( nvl(cat.category_concat_segs, 'Special') , 'Special', 'should be special', 'should be standard')category
, null
from mtl_system_items_b msi
, mtl_item_categories_v cat
, mtl_item_categories_v cat_bmx
where msi.organization_id                          = 90
	and cat.structure_id(+)                           = '50415'
	and msi.inventory_item_id                         = cat.inventory_item_id(+)
	and cat.organization_id(+)                        = 85
	and cat_bmx.structure_id(+)                       = '50415'
	and msi.inventory_item_id                         = cat_bmx.inventory_item_id(+)
	and cat_bmx.organization_id(+)                    = msi.organization_id
	and planner_code                                 <> 'JIT'
	and nvl(cat_bmx.category_concat_segs, 'Special') <> nvl(cat.category_concat_segs,'Special')