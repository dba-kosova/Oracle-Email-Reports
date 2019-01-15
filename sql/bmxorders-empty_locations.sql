select 
inv_project.get_pjm_locsegs(CONCATENATED_SEGMENTS) Locator
from 
MTL_ITEM_LOCATIONS_KFV
where organization_Id = 90
and disable_date is null
and subinventory_code in ('CMP HR', 'DCK HR')
and empty_flag = 'Y'
and not exists (
select locator_id
from mtl_onhand_quantities_detail
where locator_id = inventory_location_id
group by locator_id
)