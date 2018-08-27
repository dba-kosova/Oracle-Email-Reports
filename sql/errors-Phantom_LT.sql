select organization_id "Org", segment1 "Item", 'Lead time should be 0' "Fix"
, planner_code
from mtl_system_items_b msi
where organization_id in (85,90)
and inventory_item_status_code = 'Active'
and item_type not in ('AOC', 'ATO')
and nvl(msi.FULL_LEAD_TIME,0) <> 0
and wip_supply_type = 6