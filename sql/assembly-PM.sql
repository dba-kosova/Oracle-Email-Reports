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
, decode(wdj.attribute4,10,'QS',20,'QS',30,'FTS',40,'QS', ' ') "Priority"
 , (  select  round(sum(mra.primary_reservation_quantity * (
		select ola2.unit_selling_price
		from oe_order_lines_all ola2
		, oe_order_headers_all oha2
		where 1=1
			and ola.header_id            = ola2.header_id
			and ola2.header_id           = oha2.header_id
			and oha.order_number         = oha2.order_number
			and ola.line_number          = ola2.line_number
			and ola2.unit_selling_price is not null
			and ola2.unit_selling_price <> '0'
			and ola.shipment_number      = ola2.shipment_number
			and rownum = 1
	)),2 )value
        from oe_order_lines_all ola, oe_order_headers_all oha
                , MTL_RESERVATIONS_ALL_v mra

       
        
        where 1=1
        and ola.header_id = oha.header_id
        and ola.line_id = mra.demand_source_line_id
        and mra.supply_source_header_id = wdj.wip_entity_id
        and mra.supply_source_type = 'Job or Schedule'
        and ola.org_id = 83
        and ola.open_flag = 'Y'
        and ola.cancelled_flag = 'N'
        and ola.shippable_Flag = 'Y'
        
        ) "Order Value"
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
							 and line_code = 'PM'
order by nvl((select min(schedule_ship_date) from oe_order_lines_all ola where wdj.project_id = ola.project_id and open_flag = 'Y' and cancelled_flag = 'N'),scheduled_completion_date) asc