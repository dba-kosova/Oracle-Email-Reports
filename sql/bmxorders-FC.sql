select wip_entity_name "Trabajo"
, project_number "Proyecto"
, msi.segment1 "Parte"
, substr(msi.description,0,20) "Descripcion"
	--, line_code "Line"
, to_number(quantity_remaining) "Abierto CTD"
, date_released "Liberado"
, nvl(
	(
		select min(schedule_ship_date)
		from oe_order_lines_all ola
		where wdj.project_id = ola.project_id
			and open_flag       = 'Y'
			and cancelled_flag  = 'N'
	)
	, scheduled_completion_date) "Fecha de envio"
	--, (select min(promise_Date) from oe_order_lines_all ola where wdj.project_id = ola.project_id and open_flag = 'Y' and cancelled_flag = 'N') "Promise"
, status_type_disp "Estado"
from wip_discrete_jobs_v wdj
, apps.mtl_item_locations_kfv b
, mtl_system_items_b msi
, mtl_reservations mr
where wdj.organization_id     in ( 90)
	and wdj.organization_id       = b.organization_id(+)
	and wdj.completion_locator_id = b.inventory_location_id(+)
	and wdj.organization_id       = msi.organization_id
	and wdj.primary_item_id       = msi.inventory_item_id
	and wdj.wip_entity_id         = mr.supply_source_header_id(+)
	and status_type_disp          = 'Released'
	and line_code like 'FC%'
order by nvl(
	(
		select min(schedule_ship_date)
		from oe_order_lines_all ola
		where wdj.project_id = ola.project_id
			and open_flag       = 'Y'
			and cancelled_flag  = 'N'
	)
	,scheduled_completion_date) asc