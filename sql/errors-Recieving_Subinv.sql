select decode(msi.organization_id,85,'BIM')"Org", msi.segment1 "Item"
, planner_code "Planner"
, nvl(flv.meaning, 'should be "Direct"') "Receipt Routing"
, nvl(mis.subinventory_code, 'should be "MX RCV"') "Recieving Subinv"
from mtl_system_items_b msi
, mtl_item_sub_defaults mis
, mrp_sr_assignments_v msa
, fnd_lookup_values_vl flv
where msi.organization_id       = 85
	and msi.organization_id        = msa.organization_id(+)
	and msi.inventory_item_id      = msa.inventory_item_id(+)
	and msi.organization_id        = mis.organization_id(+)
	and msi.inventory_item_id      = mis.inventory_item_id(+)
	and sourcing_rule_name         = 'BIM Transfer from BMX'
	and inventory_item_status_code = 'Active'
	and msi.receiving_routing_id = flv.lookup_code(+)
	and flv.lookup_type(+) = 'RCV_ROUTING_HEADERS'
	and (nvl(flv.meaning,'asdf') <> 'Direct Delivery' or nvl(mis.subinventory_code,'asdf') <> 'MX RCV')
	
union all
-- direct devlivery parts

select decode(msi.organization_id,85,'BIM','BMX')"Org", msi.segment1 "Item"
, planner_code "Planner"
, nvl(flv.meaning, 'should be "Direct"') "Receipt Routing"
, wip_supply_subinventory "Recieving Subinv"
from mtl_system_items_b msi
, mtl_item_sub_defaults mis
, fnd_lookup_values_vl flv
where msi.organization_id       in ( 85, 90)
	and msi.organization_id        = mis.organization_id(+)
	and msi.inventory_item_id      = mis.inventory_item_id(+)
	and inventory_item_status_code = 'Active'
	and wip_supply_subinventory in ('FASTENAL', 'ZAPIT')
	and msi.receiving_routing_id = flv.lookup_code(+)
	and flv.lookup_type(+) = 'RCV_ROUTING_HEADERS'
	and (nvl(flv.meaning,'asdf') <> 'Direct Delivery' or nvl(mis.subinventory_code,'asdf') <> wip_supply_subinventory)