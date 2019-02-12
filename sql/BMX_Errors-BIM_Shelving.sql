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
    or nvl(fixed_days_supply,0) <> 60
    or nvl(receiving_routing_id,0) <> 3
    or nvl(acceptable_early_days,0) <> 10
    or nvl(planning_time_fence_code,0) <> 4
    or nvl(full_lead_time,0) > 5
    or nvl(end_assembly_pegging_flag,'asdf') <> 'B'
    or nvl(replenish_to_order_flag,'N') <> 'Y'
    or nvl(atp_components_flag,'N') <> 'Y'
    or nvl(wip_supply_type,0) <> 1
    or nvl(cycle_count_enabled_flag,'N') <> 'Y'
    or nvl(mrp_planning_code,0) <> 7
    or nvl(release_time_fence_code,0) <> 4
    or nvl(release_time_fence_days,0) <> 20
    or nvl(sourcing_rule_name,'asdf') <> 'BIM Transfer from BMX'
    or not exists (select subinventory_code from mtl_item_sub_defaults where inventory_item_id = msi.inventory_item_id and organization_id = msi.organization_id)
    or nvl(minimum_order_quantity,0) <> greatest(round(msi.attribute7/10,0) * 10,25)
    )
  