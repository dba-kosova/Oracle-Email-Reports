select msi.segment1 "Item"
,      msi.description "Description"
, msi.FIXED_LOT_MULTIPLIER "Box Size"
, sourcing_rule_name vendor
,      xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') "On Hand"
, item_cost "Unit Cost"
from mtl_system_items_b msi
,MRP_SR_ASSIGNMENTS_V  mis
, CST_ITEM_COSTS cic
where msi.organization_id = 85
and msi.organization_id = mis.organization_id
and msi.inventory_item_id = mis.inventory_item_id
and msi.organization_id = cic.organization_id
and msi.inventory_item_id = cic.inventory_item_id
and cic.cost_type_id= 1
and wip_supply_subinventory in ('OL RG', 'OL RH', 'OL PIST','BUSHING','D-NUT')
and sourcing_rule_name not like 'BIM-Arcon Ring % Spec Corp'
and sourcing_rule_name not like 'BIM-Smith % Richardson Mfg. Co'
and sourcing_rule_name not like 'BIM-Fmt'
and sourcing_rule_name not like 'BIM-Avanti Engineering'