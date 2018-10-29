select wip_entity_name "Job"
, project_number "Project"
, msi.segment1 "Item"
, substr(msi.description,0,20) "Description"
--, line_code "Line"
, to_number(quantity_remaining) "Open QTY"
, date_released "Released"
, nvl((select min(schedule_ship_date) from oe_order_lines_all ola where wdj.project_id = ola.project_id and open_flag = 'Y' and cancelled_flag = 'N'),scheduled_completion_date) "Schedule Ship"
--, (select min(promise_Date) from oe_order_lines_all ola where wdj.project_id = ola.project_id and open_flag = 'Y' and cancelled_flag = 'N') "Promise"
, status_type_disp "Status"
, decode(wdj.attribute4,10,'QS',20,'QS',30,'FTS',40,'QS',' ') "Priority"

from wip_discrete_jobs_v wdj
, apps.mtl_item_locations_kfv b
, mtl_system_items_b msi
, mtl_reservations mr
where wdj.organization_id      in ( 85)
               and status_type_disp         in ('Released', 'Unreleased', 'On Hold')
               and wdj.organization_id       = b.organization_id(+)
               and wdj.completion_locator_id = b.inventory_location_id(+)
               and wdj.organization_id       = msi.organization_id
               and wdj.primary_item_id       = msi.inventory_item_id
               and wdj.wip_entity_id         = mr.supply_source_header_id(+)
							 and status_type_disp = 'Released'
							 and line_code = 'SUB-PT'
order by nvl((select min(schedule_ship_date) from oe_order_lines_all ola where wdj.project_id = ola.project_id and open_flag = 'Y' and cancelled_flag = 'N'),scheduled_completion_date) asc
