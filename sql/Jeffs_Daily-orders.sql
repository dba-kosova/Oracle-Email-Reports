select distinct
 wdj.wip_entity_name "Job"
, pjm.project_number "Project"
, (select attribute1 from bom_operational_routings b where alternate_routing_designator is null and b.organization_id = ola.ship_from_org_id and assembly_item_id = ola.inventory_item_id) "Line"
, msi.segment1 "Item"
, substr(msi.description,0,30) "Description"
, wdj.quantity_remaining "Open Qty"
, wdj.date_released "Released"
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


, ola.attribute20 "Blanket"

    
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
    
, e.party_name "Customer"

, wdj.schedule_group_name "Schedule Group"

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
    
and wdj.status_type_disp = 'Released'
    and ola.ship_from_org_id = 85
    and nvl((select promise_date
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
    and line_id   = ola.line_id),promise_date) <= greatest(apps.xxbim_get_calendar_date('BIM', sysdate,5),'31-OCT-18')
