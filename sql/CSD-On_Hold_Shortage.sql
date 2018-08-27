select distinct comp.segment1 "Shortage Item", inventory_item_id
, decode(comp.planning_make_buy_code,1,'Make', 2,'Buy') "Make Buy"
, comp.planner_code "Planner"
, xxbim_get_quantity(comp.inventory_item_id, comp.organization_id, 'ATR') -
	(
		select sum(wro.required_quantity - quantity_issued) sum_open_qty
		from wip_requirement_operations wro
		, wip_discrete_jobs w
		where 1                    =1
			and wro.wip_entity_id     = w.wip_entity_id
			and wro.inventory_item_id = comp.inventory_item_id
			and w.organization_id     = comp.organization_id
			and w.status_type        in (1, 6)
		group by wro.inventory_item_id
		, w.organization_id
	)
	"Shortage Quantity"
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

        , (	select w.wip_entity_id, w.start_quantity, wro.inventory_item_id
		from wip_requirement_operations wro
		, wip_discrete_jobs w
		where 1                    =1
			and wro.wip_entity_id     = w.wip_entity_id
			--and wro.inventory_item_id = 9850587
			and w.organization_id     = 85
			and w.status_type        in (1, 6)
		group by w.wip_entity_id, start_quantity, wro.inventory_item_id) wip
        
        where 1=1
        and ola.header_id = oha.header_id
        and ola.line_id = mra.demand_source_line_id
        and mra.supply_source_header_id = wip.wip_entity_id
        and mra.supply_source_type = 'Job or Schedule'
        and ola.org_id = 83
        and ola.open_flag = 'Y'
        and ola.cancelled_flag = 'N'
        and ola.shippable_Flag = 'Y'
        and wip.inventory_item_id = comp.inventory_item_id
        ) "Order Value"
    , (
		select min(scheduled_completion_date)
		from wip_requirement_operations wro
		, wip_discrete_jobs w
		where 1                    =1
			and wro.wip_entity_id     = w.wip_entity_id
			and wro.inventory_item_id = comp.inventory_item_id
			and w.organization_id     = comp.organization_id
			and w.status_type        in (1, 6)
		
	) "Oldest Due Date"
, (
		select min(scheduled_completion_date )
		from wip_discrete_jobs_v w
		where 1                 =1
			and w.status_type_disp = 'Released'
			and w.primary_item_id  = comp.inventory_item_id
	)
	"Current Job Date"
    , (
		select min(wip_entity_name )
		from wip_discrete_jobs_v w
		where 1                 =1
			and w.status_type_disp = 'Released'
			and w.primary_item_id  = comp.inventory_item_id
	)
	"Job"
, (
		select max( expedited)
		from wip_discrete_jobs wd
		, wip_discrete_jobs_v w
		where wd.wip_entity_id  = w.wip_entity_id
			and w.status_type_disp = 'Released'
			and w.primary_item_id  = comp.inventory_item_id
			and wd.organization_id = w.organization_id
	)
	"Expedited"
from wip_exceptions we
, wip_discrete_jobs_v wdj
, mtl_system_items_b comp
where 1                   =1
	and we.wip_entity_id     = wdj.wip_entity_id
	and wdj.organization_id  = 85
	and we.component_item_id = comp.inventory_item_id(+)
	and we.organization_id   = comp.organization_id(+)
	and wdj.status_type_disp = 'On Hold'
	and
	(
		we.status_type = 1
		or
		(
			we.status_type      = 2
			and wdj.status_type = 6
		)
	)
	and
	(
		xxbim_get_quantity(comp.inventory_item_id, comp.organization_id, 'ATR') -
		(
			select sum(wro.required_quantity - quantity_issued) sum_open_qty
			from wip_requirement_operations wro
			, wip_discrete_jobs w
			where 1                    =1
				and wro.wip_entity_id     = w.wip_entity_id
				and wro.inventory_item_id = comp.inventory_item_id
				and w.organization_id     = comp.organization_id
				and w.status_type        in (1, 6)
			group by wro.inventory_item_id
			, w.organization_id
		)
	)
	<=0
order by 2 desc
,3,4