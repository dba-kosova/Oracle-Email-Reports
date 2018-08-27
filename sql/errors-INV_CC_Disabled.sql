select segment1 "Item"
,CYCLE_COUNT_ENABLED_FLAG "CC Enabled"
, planner_code "Planner"
from mtl_system_items_b msi
where organization_id = 85
and inventory_item_status_code = 'Active'

and CYCLE_COUNT_ENABLED_FLAG = 'N'
and planner_code not in ('REF','TPK', 'JIT', 'TOL')