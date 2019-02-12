select
    segment1 "Part Number",
    planner_code "Planner Code",
    inventory_item_status_code "Item Status - Active",
    fixed_days_supply "Fixed Days Supply - 60",
    minimum_order_quantity "Min Order Qty - 1 month usage",
    greatest(round(msi.attribute7/10,0) * 10,25) "correct MOQ",
    fl.meaning "Receipt Type - Direct Deliver",
    (select subinventory_code from mtl_item_sub_defaults where inventory_item_id = msi.inventory_item_id and organization_id = msi.organization_id) "Recieving Subinv - MXRCV",
    acceptable_early_days "Acceptable Days Early - 10",
    full_lead_time "Full Lead Time - < 5",
    fl4.meaning "Pegging - End Assy/Soft",
    replenish_to_order_flag "Assemble To Order - Y",
    atp_components_flag "ATP Components - Material Only",
    atp_flag "ATP - Material Only",
    fl5.meaning "Supply Type - Push",
    cycle_count_enabled_flag "Cycle Count Enabled - Yes",
    fl3.meaning "MRP Planning - MRP/MPP Planned" ,
    fl2.meaning "Release Time Fence - User Def",
    release_time_fence_days "Release Days - 20",
    sourcing_rule_name "Sourcing Rule - BIM Tr"
from
    mtl_system_items_b msi,
    fnd_lookup_values_vl fl,
    fnd_lookup_values_vl fl2,
    fnd_lookup_values_vl fl3,
    fnd_lookup_values_vl fl4,
    fnd_lookup_values_vl fl5,
    mrp_sr_assignments_v sourcing
where
    msi.organization_id = 85
    and planner_code like '%SHV-M'
    and msi.receiving_routing_id = fl.lookup_code(+)
    and fl.lookup_type (+) = 'RCV_ROUTING_HEADERS'
    and msi.organization_id = sourcing.organization_id (+)
    and msi.inventory_item_id = sourcing.inventory_item_id (+)
    and fl2.lookup_type(+) = 'MTL_RELEASE_TIME_FENCE'
    and msi.release_time_fence_code = fl2.lookup_code(+) 
    and fl3.lookup_type(+) = 'MRP_PLANNING_CODE'
    and msi.mrp_planning_code = fl3.lookup_code(+) 

    and fl4.lookup_type(+) = 'ASSEMBLY_PEGGING_CODE'
    and msi.end_assembly_pegging_flag = fl4.lookup_code(+) 
    and fl5.lookup_type(+) = 'WIP_SUPPLY'
    and msi.wip_supply_type = fl5.lookup_code(+) 

    and (inventory_item_status_code <> 'Active'
    or fixed_days_supply <> 60
    or receiving_routing_id <> 3
    or acceptable_early_days <> 10
    or planning_time_fence_code <> 4
    or full_lead_time > 5
    or end_assembly_pegging_flag <> 'B'
    or replenish_to_order_flag <> 'Y'
    or atp_components_flag <> 'Y'
    or wip_supply_type <> 1
    or cycle_count_enabled_flag <> 'Y'
    or mrp_planning_code <> 7
    or release_time_fence_code <> 4
    or release_time_fence_days <> 20
    or sourcing_rule_name <> 'BIM Transfer from BMX'
    or not exists (select subinventory_code from mtl_item_sub_defaults where inventory_item_id = msi.inventory_item_id and organization_id = msi.organization_id)
    or minimum_order_quantity <> greatest(round(msi.attribute7/10,0) * 10,25)
    )
  