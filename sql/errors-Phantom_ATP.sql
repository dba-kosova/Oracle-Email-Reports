select segment1 "Item", 
decode(ATP_FLAG, 'Y', 'should be N', 'ok') ATP_FLAG
,decode(ATP_COMPONENTS_FLAG,'N', 'should by Y', 'ok') ATP_COMPONENTS_FLAG
from mtl_system_items_b msi
where msi.organization_id = 85
	--and segment1             ='D-19090'
	and wip_supply_type = 6
	and item_type <> 'REF'
	and (ATP_FLAG <> 'N' or ATP_COMPONENTS_FLAG <> 'Y')