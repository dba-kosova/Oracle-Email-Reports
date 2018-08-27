select distinct decode(md.organization_Id, 85, 'BIM', 90, 'BMX') "Org", sup.order_number "Job"
, (
		select order_number
			|| '-'
			|| line_number ||'.'||shipment_number line_number
		from oe_order_lines_all ola
		, oe_order_headers_all oha
		where ola.header_id = oha.header_id
			and ola.line_id    = md.sales_order_line_id
	)
	"Project"
, nvl(sup.line_code, (
		select attribute1
		from bom_operational_routings
		where alternate_routing_designator is null
			and organization_id                = 85
			and assembly_item_id               = msc.sr_inventory_item_id
	)
	) "Line"
, (
		select ordered_item
		from oe_order_lines_all ola
		where ola.line_id = md.sales_order_line_id
	)
	"Item"
, substr(msc.description,0,20) "Description"
, sup.shortage "DFF"
, to_number(nvl(old_demand_quantity,0)) "Order QTY"
, to_number(nvl(sup.quantity_remaining,0)) "Open QTY"
, sup.scheduled_completion_date "Schedule Completion"
, sup.date_released  "Released"
, sup.date_completed  "Completed"
, (
		select creation_date
		from oe_order_lines_all ola
		where ola.line_id = md.sales_order_line_id
	)
	"Created"
, request_date "Request"
, schedule_ship_date "Schedule Ship"
, promise_date "Promise"
, nvl(decode(sup.status_type_disp, 'Released', 'Released', 'Unreleased', 'Unreleased', 'On Hold', 'On Hold', null) , (
		select OE_LINE_STATUS_PUB.Get_Line_Status(line_id, flow_status_code) LINE_STATUS_FUNC
		from oe_order_lines_all
		where line_id = md.sales_order_line_id
	)
	) "Status"
	,nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = md.organization_Id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = msc.sr_inventory_item_id), 'Special') "Category"
		, (
		select apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) ON_HOLD
		from oe_order_lines_all ola
		, oe_order_headers_all oha
		where ola.header_id = oha.header_id
		--	and oha.order_number = 10187449
			and ola.line_id    = md.sales_order_line_id
	)
	"Hold"
		,decode(
						(
							select count(1) from ont.oe_order_lines_all where header_id = (select header_id from oe_order_lines_all where line_id = md.sales_order_line_id)
								and shippable_flag                                         = 'Y'
								and ship_set_id                                            = (select ship_set_id from oe_order_lines_all where line_id = md.sales_order_line_id) group by ship_set_id
						)
						, '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') "Ship Set"

	
	,(select distinct sourcing_rule_name from MRP_SR_ASSIGNMENTS_V  mis
	, msc_system_items_v msi
where mis.organization_id = md.organization_id
and msi.organization_id = mis.organization_Id
and msi.sr_inventory_item_id = mis.inventory_item_id
and msi.inventory_item_id = md.inventory_item_id
	) "Sourcing"
	
	
, (
		select ola.attribute20
		from oe_order_lines_all ola
		where ola.line_id = md.sales_order_line_id
	)
	"Blanket"
, (
		select (select meaning from OE_LOOKUPS where shipment_priority_code = lookup_code and lookup_type = 'SHIPMENT_PRIORITY')
		from oe_order_lines_all ola
		where ola.line_id = md.sales_order_line_id
	)
	"Priority"
, (
		select service_level
		from oe_order_lines_all ola
		, WSH_CARRIER_SHIP_METHODS wcsm
		where ola.line_id = md.sales_order_line_id
		and ola.shipping_method_code = wcsm.ship_method_code
		and ola.ship_from_org_id = wcsm.organization_id
	)
	"Ship Method"
, round(nvl(
	(
		select ola2.unit_selling_price
		from oe_order_lines_all ola
		, oe_order_lines_all ola2
		, oe_order_headers_all oha
		, oe_order_headers_all oha2
		where ola.header_id           = oha.header_id
			and ola.header_id            = ola2.header_id
			and ola2.header_id           = oha2.header_id
			and oha.order_number         = oha2.order_number
			and ola.line_number          = ola2.line_number
			and ola2.unit_selling_price is not null
			and ola2.unit_selling_price <> '0'
			and ola.shipment_number      = ola2.shipment_number
			and ola.line_id              = md.sales_order_line_id
			and rownum = 1
	)
	,0),2) "Unit Price"
, decode (e.country, 'US', 'DOM','CA', 'INT', 'MX','INT', null, 'DOM', 'INT') "DOM/INT"
, e.party_name "Customer"
, e2.party_name "Distributor"
from msc_demands md
, msc_system_items msc
,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b

,hz_cust_accounts d2
, hz_parties e2
, hz_cust_acct_sites_all c2
, hz_cust_site_uses_all b2


, (
		select ms.inventory_item_id,END_ORDER_LINE_NUMBER,order_line_number
		, ms.order_number
		, ms.new_order_quantity
		, ms.qty_completed
		, wdj.quantity_remaining
		, ms.new_schedule_date
		, wdj.date_released
		, wdj.date_completed
		, wdj.scheduled_completion_date
		, wdj.status_type_disp
		, wdj.start_quantity
		, wdj.line_code
		, ms.project_id
		, wdj.attribute1
			|| '.'
			|| wdj.attribute2
			|| '.'
			|| wdj.attribute3 shortage
			, b.demand_source_line_Id
		from msc_supplies ms
		, wip_discrete_jobs_v wdj
		, mtl_reservations b 
		where 1                 =1
			and order_type        in(3, 1)
			and plan_id            = -1
			and ms.organization_id = wdj.organization_id(+)
			and ms.order_number    = wdj.wip_entity_name(+)
			and wdj.wip_entity_id = b.supply_source_header_id
			and wdj.organization_id = b.organization_id
	)
	sup
where md.organization_id  in ( 85, 90)
	and md.organization_id   = msc.organization_id
	and md.plan_id           = msc.plan_id
	and md.inventory_item_id = msc.inventory_item_id
	and md.origination_type  = 30
	and md.plan_id           = 21
	and
	(
		select flow_status_code
		from oe_order_lines_all
		where line_id = md.sales_order_line_id
	)
	not in ( 'CLOSED', 'CANCELLED')
	and
	(
		select order_source_id
		from oe_order_lines_all
		where line_id = md.sales_order_line_id
	)
	                                                             <> 10
	and nvl(md.daily_demand_rate, md.using_requirement_quantity) <> 0
	and md.order_number                                          is not null
	and md.sales_order_line_id = sup.demand_source_line_Id(+)
--	and md.inventory_item_id                                      = sup.inventory_item_id(+)
--	and md.project_id                                             = sup.project_id(+)
	and
	(
		select ship_to_org_id
		from oe_order_lines_all
		where line_id = md.sales_order_line_id
	)
	                        = b.site_use_id -- or a.invoice_to_org_id
	and d.party_id          = e.party_id
	and c.cust_account_id   = d.cust_account_id
	and b.cust_acct_site_id = c.cust_acct_site_id
	and
	(
		select invoice_to_org_id
		from oe_order_lines_all
		where line_id = md.sales_order_line_id
	)
	                        = b2.site_use_id -- or a.invoice_to_org_id
	and d2.party_id          = e2.party_id
	and c2.cust_account_id   = d2.cust_account_id
	and b2.cust_acct_site_id = c2.cust_acct_site_id
and md.old_demand_quantity = sup.quantity_remaining(+)

--and promise_Date < sysdate
and request_date < apps.xxbim_get_calendar_date('BIM', sysdate, -10)
--and md.inventory_item_id= '791190'
	and e.party_name       <> 'BIM-Internal Customer'
	and (nvl(sup.date_released,sysdate) < apps.xxbim_get_calendar_date('BIM', sysdate, -20)
	or	nvl(schedule_ship_date, sysdate) < apps.xxbim_get_calendar_date('BIM', sysdate, -20) and nvl(sup.date_released,sysdate-40) < apps.xxbim_get_calendar_date('BIM', sysdate, -20))
	and  nvl(decode(sup.status_type_disp, 'Released', 'Released', 'Unreleased', 'Unreleased', 'On Hold', 'On Hold', null) , (
		select OE_LINE_STATUS_PUB.Get_Line_Status(line_id, flow_status_code) LINE_STATUS_FUNC
		from oe_order_lines_all
		where line_id = md.sales_order_line_id
	)
	) not in ('Awaiting Shipping', 'Picked')
	and md.organization_Id = 85
order by nvl(sup.date_released,schedule_ship_date) asc
