select distinct comp.segment1
, comp.planner_code
from wip_exceptions we
, mtl_system_items_b comp
, mfg_lookups ml2
where 1                   =1
	and we.component_item_id = comp.inventory_item_id
	and we.organization_id   = comp.organization_id
	and ml2.lookup_type(+)   = 'WIP_EXCEPTION_STATUS'
	and we.status_type       = ml2.lookup_code(+)
	and ml2.meaning          = 'Open'
	and we.creation_date     > trunc(sysdate)