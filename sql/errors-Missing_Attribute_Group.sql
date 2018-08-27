select decode(organization_Id,85,'BIM','BMX') org, segment1, ATTRIBUTE_CATEGORY
from mtl_system_items_b
where (ATTRIBUTE_CATEGORY <> organization_Id or ATTRIBUTE_CATEGORY is null)
and organization_Id in( 90,85)