select msip.segment1 item
, msic.segment1 child_item
, decode(bomc.wip_supply_type, '1', 'Push', '2', 'Assembly Pull', '3', 'Opperation Pull', '4', 'Bulk', '5', 'Supplier', '6', 'Phantom') bom_supply_type
, bomc.supply_subinventory bom_subinv
,boro.completion_subinventory router_subinv
, alternate_routing_designator
, inv_project.get_pjm_locsegs(b2.concatenated_segments) bom_locator
, inv_project.get_pjm_locsegs(b.concatenated_segments) router_locator
from apps.mtl_system_items_b msip
, apps.bom_structures_b boms
, apps.bom_components_b bomc
, apps.mtl_system_items_b msic
, apps.mtl_parameters mtlp
, bom_operational_routings boro
, apps.mtl_item_locations_kfv b
, apps.mtl_item_locations_kfv b2
where boms.assembly_item_id                                  = msip.inventory_item_id
	and boms.organization_id                                    = msip.organization_id
	and boms.organization_id                                    = mtlp.organization_id
	and mtlp.organization_code                                  = 'BIM'
	and nvl(boms.common_bill_sequence_id,boms.bill_sequence_id) = bomc.bill_sequence_id
	and bomc.component_item_id                                  = msic.inventory_item_id
	and boms.organization_id                                    = msic.organization_id
	and bomc.disable_date                                      is null
	and msip.inventory_item_status_code                         = 'Active'
	and boro.assembly_item_id                                   = msic.inventory_item_id
	and boro.organization_id                                    = msic.organization_id
	and
	(
		boro.completion_subinventory  <> bomc.supply_subinventory
		or boro.completion_locator_id <> bomc.supply_locator_id
	)
	and msic.replenish_to_order_flag = 'Y'
	and msic.item_type <> 'ATO'
	and boro.organization_id         = b.organization_id(+)
	and boro.completion_locator_id   = b.inventory_location_id(+)
	and 85                           = b2.organization_id(+)
	and bomc.supply_locator_id       = b2.inventory_location_id(+)
order by item_num
