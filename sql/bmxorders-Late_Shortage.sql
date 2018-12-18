select component "Item"
,description "Description"
, sum(required_quantity - nvl(quantity_issued,0)) "Open Requirement"
, sum(order_value) "Open Value"
,type "Type"
, planner_code "Planner"
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
from
	(
		select we.wip_entity_name job
		, we.project_name project
		, line_code line
		, msi.planner_code
		, msip.segment1 assembly
		, msi.segment1 component
		, msi.inventory_item_id
		, msi.description
		, we.attribute4
		, wro.required_quantity
		, wro.quantity_issued
		, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') on_hand
		, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') atr
		, decode(wro.quantity_issued, 0, 'No', 'Yes') issued_or_not
		, decode(wro.wip_supply_type, '1', 'Push', '2', 'Assembly Pull', '3', 'Opperation Pull', '4', 'Bulk', '5', 'Supplier', '6', 'Phantom') supply_type
		, wro.supply_subinventory
		, wro.attribute2
		, nvl(cat.category_concat_segs,'Special') type
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
        and mra.supply_source_header_id = we.wip_entity_id
        and mra.supply_source_type = 'Job or Schedule'
        and ola.org_id = 83
        and ola.open_flag = 'Y'
        and ola.cancelled_flag = 'N'
        and ola.shippable_Flag = 'Y'
        
        ) order_value
		from wip_discrete_jobs_v we
		, wip_requirement_operations wro
		, mtl_system_items_b msi
		, mtl_system_items_b msip
		, mtl_item_categories_v cat
		where we.organization_id        = 90
			and msip.organization_id       = we.organization_id
			and wro.organization_id        = we.organization_id
			and msi.organization_id        = we.organization_id
			and substr(wro.attribute2,0,1) = 1
			and we.wip_entity_id           = wro.wip_entity_id
			and wro.inventory_item_id      = msi.inventory_item_id
			and msip.inventory_item_id     = we.primary_item_id
			--and wro.wip_supply_type in( '1')
			and we.status_type_disp  in ('Unreleased')
			and msi.organization_id   = cat.organization_id(+)
			and cat.structure_id(+)   = '50415'
			and msi.inventory_item_id = cat.inventory_item_id(+)
            and we.scheduled_start_date < sysdate
		order by 5
	) comp
group by component
,description
,type,planner_code,comp.inventory_item_id
order by 3 desc