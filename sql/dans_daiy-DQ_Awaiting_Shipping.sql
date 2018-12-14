select distinct
decode(ola.ship_from_org_id,85,'BIM',90,'BMX') "Org"
, wdj.wip_entity_name "Job"
, pjm.project_number "Project"
, (select attribute1 from bom_operational_routings b where alternate_routing_designator is null and b.organization_id = ola.ship_from_org_id and assembly_item_id = ola.inventory_item_id) "Line"
, msi.segment1 "Item"
, substr(msi.description,0,30) "Description"
, wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 "DFF"
, ordered_quantity "Order Qty"
, reservation_quantity "Qty Reserved"
, wdj.quantity_remaining "Open Qty"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') "Qty ATR"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') "Qty TQ"
, wdj.date_released "Released"
, ola.creation_date "Created"
, trunc(ola.request_date) "Request"
, trunc(ola.schedule_ship_date) "Schedule Ship"
, trunc(ola.promise_date) "Promise"

, nvl((select promise_date
from
	(
		select hist_creation_date
		, promise_date
		,header_id
		,line_id
		from oe_order_lines_history h
		where 1            =1
			and promise_date is not null
		order by hist_creation_date asc
	)
where rownum   = 1
	and line_id   = ola.line_id),promise_date) "1st Promise Date"

, nvl(decode(wdj.status_type_disp, 'Released', 'Released', 'Unreleased', 'Unreleased', 'On Hold', 'On Hold', null) , (
		 OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) 
		
	)
	) "Status"
,nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = msi.organization_Id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = ola.inventory_item_id), 'Special') "Category"


, 
		 apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) "Hold"
	,decode(
						(
							select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
								and shippable_flag                                         = 'Y'
								and ship_set_id                                            = ola.ship_set_id group by ship_set_id
						)
						, '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') "Ship Set"


	,(select distinct sourcing_rule_name from MRP_SR_ASSIGNMENTS_V  mis
where mis.organization_id = ola.ship_from_org_id
and mis.inventory_item_id = ola.inventory_item_id
	) "Sourcing"

, ola.attribute20 "Blanket"
,(select meaning from OE_LOOKUPS where ola.shipment_priority_code = lookup_code and lookup_type = 'SHIPMENT_PRIORITY') "Priority"
, (
		select service_level
		from  WSH_CARRIER_SHIP_METHODS wcsm
		where  wcsm.ship_method_code = ola.shipping_method_code
		and  wcsm.organization_id = ola.ship_from_org_id
	)
	"Ship Method"
    
    , round(nvl(
	(
		select ola2.unit_selling_price
		from oe_order_lines_all ola2
		, oe_order_headers_all oha2
		where ola.header_id           = oha.header_id
			and ola.header_id            = ola2.header_id
			and ola2.header_id           = oha2.header_id
			and oha.order_number         = oha2.order_number
			and ola.line_number          = ola2.line_number
			and ola2.unit_selling_price is not null
			and ola2.unit_selling_price <> '0'
			and ola.shipment_number      = ola2.shipment_number
			and rownum = 1
	)
	,0),2) "Unit Price"
    
     , round(nvl(
	(
		select ola2.unit_selling_price
		from oe_order_lines_all ola2
		, oe_order_headers_all oha2
		where ola.header_id           = oha.header_id
			and ola.header_id            = ola2.header_id
			and ola2.header_id           = oha2.header_id
			and oha.order_number         = oha2.order_number
			and ola.line_number          = ola2.line_number
			and ola2.unit_selling_price is not null
			and ola2.unit_selling_price <> '0'
			and ola.shipment_number      = ola2.shipment_number
			and rownum = 1
	)
	,0),2) * nvl(reservation_quantity,ordered_quantity)  "Total Price"
    
   , decode (e.country, 'US', 'DOM','CA', 'INT', 'MX','INT', null, 'DOM', 'INT') "DOM/INT"
, e.party_name "Customer"
, e2.party_name "Distributor" 
, (
select 
regexp_replace(listagg(ohd.name , ',' ) within group( order by ohd.name asc),'([^,]+)(,\1)*(,|$)', '\1\3') holds
from  OE_ORDER_HOLDS_ALL oeha 
,OE_HOLD_DEFINITIONS ohd 
, OE_HOLD_SOURCES_ALL ohsa
where header_id = ola.header_id
and nvl(line_id,ola.line_id) = ola.line_id
and oeha.released_flag = 'N'
and ohsa.hold_Source_id = oeha.hold_source_id
and ohsa.hold_id = ohd.hold_id) "Hold Details"

, (
select 
regexp_replace(listagg(ohd.type_code , ',' ) within group( order by ohd.type_code asc),'([^,]+)(,\1)*(,|$)', '\1\3') holds
from  OE_ORDER_HOLDS_ALL oeha 
,OE_HOLD_DEFINITIONS ohd 
, OE_HOLD_SOURCES_ALL ohsa
where header_id = ola.header_id
and nvl(line_id,ola.line_id) = ola.line_id
and oeha.released_flag = 'N'
and ohsa.hold_Source_id = oeha.hold_source_id
and ohsa.hold_id = ohd.hold_id) "Hold Type"
,(select count(1)
from oe_order_headers_all oeh
, oe_order_lines_all oel
, (
		select line_id
		, trunc(hist_creation_date) date_changed
		, max(promise_date) promise_date
		,hist_created_by
		from oe_order_lines_history
		where 1               =1
			and hist_created_by in ('4422', -- MG
			'2641',                         -- MP
			'4219',                         -- LM
			'2775')                         -- CP
		group by line_id
		,trunc(hist_creation_date)
		,hist_created_by
	)
	hist
where oeh.header_id = oel.header_id
	--AND oeh.open_flag = 'Y'
	and oeh.header_id                                                     = oha.header_id
	--and oel.line_number                                                      = '1'
	and oeh.booked_flag                                                      = 'Y'
	and nvl(hist.date_changed, greatest(oeh.booked_date, oel.creation_date)) >oeh.booked_date+2
	--and oel.open_flag = 'Y'
	--and oel.link_to_line_id is null
	and oel.shippable_flag   = 'Y'
	and oel.ship_from_org_id = 85
	and oel.line_id          = hist.line_id

and oel.line_id = ola.line_id
) moves
, wdj.schedule_group_name "Schedule Group"
, substr(msi.segment1, 0,instr(msi.segment1,'-')-1) "Prefix"
, decode(nvl((select wip_entity_name
from wip_discrete_jobs_v we
where we.organization_id     = 85
and we.status_type          = 1                                                 --unreleased
and we.scheduled_start_date > apps.xxbim_get_calendar_date('BIM', sysdate, -90) --just to make it faster
and line_code not                                                          in ( 'JIT', 'CSD', 'NJIT', 'OSV', 'FC', 'ACC')
and line_code not like 'SUB%'
and not exists
( -- this will list any "open" job (released, unreleased, on hold.. and canceled incase there was a recut)
              select project_id
              , status_type_disp
              from wip_discrete_jobs_v
              where line_code       = 'JIT'
                             and status_type not in (4,12) -- closed/complete
                             and project_id       = we.project_id
)

and we.wip_entity_name = wdj.wip_entity_name
group by we.wip_entity_name),'No'),'No','No','Yes') "In Staging - 90% accurate"
from 

oe_order_lines_all ola
, oe_order_headers_all oha
, PJM_SEIBAN_NUMBERS pjm
, MTL_RESERVATIONS_ALL_v mra
, wip_discrete_jobs_v wdj
, mtl_system_items_b msi
,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b

,hz_cust_accounts d2
, hz_parties e2
, hz_cust_acct_sites_all c2
, hz_cust_site_uses_all b2
where ola.header_id = oha.header_id
and ola.project_id = pjm.project_id
and ola.open_flag = 'Y'
and ola.shippable_flag = 'Y'
and ola.cancelled_flag = 'N'
and ola.booked_flag = 'Y'
and ola.org_id = 83
and ola.line_id = mra.demand_source_line_id(+)
and mra.supply_source_header_id = wdj.wip_entity_id(+)
and ola.ship_from_org_id = msi.organization_id
and ola.inventory_item_id = msi.inventory_item_id



and ola.ship_to_org_id = b.site_use_id -- or a.invoice_to_org_id
	and d.party_id          = e.party_id
	and c.cust_account_id   = d.cust_account_id
	and b.cust_acct_site_id = c.cust_acct_site_id
	and ola.invoice_to_org_id = b2.site_use_id -- or a.invoice_to_org_id
	and d2.party_id          = e2.party_id
	and c2.cust_account_id   = d2.cust_account_id
	and b2.cust_acct_site_id = c2.cust_acct_site_id
    and ola.order_source_id <> 10 -- internal orders
    and ola.source_type_code <> 'EXTERNAL'
    and ola.line_type_id not in (1073,1077,1127) -- return, sample, vendor order
    
    and greatest(ola.request_date, nvl((select promise_date
    from
        (
            select hist_creation_date
            , promise_date
            ,header_id
            ,line_id
            from oe_order_lines_history h
            where 1            =1
                and promise_date is not null
            order by hist_creation_date asc
        )
    where rownum   = 1
        and line_id   = ola.line_id),promise_date)) < trunc(sysdate)
and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Shipping'
    and  apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) = 'NO'
    and decode(
                            (
                                select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
                                    and shippable_flag                                         = 'Y'
                                    and ship_set_id                                            = ola.ship_set_id group by ship_set_id
                            )
                            , '1', 'No', null ,'No', 'Ship Set') = 'No'
        
order by trunc(schedule_ship_date) asc
