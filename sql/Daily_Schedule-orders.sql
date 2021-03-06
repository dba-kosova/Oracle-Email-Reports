select 
wip_entity_name "Job"
, project_name "Project"
, line_code "Line"
, msi.segment1 "Item"
, substr(msi.description,0,20) "Description"
, to_number(quantity_remaining) "Open QTY"
, date_released "Released"
, nvl(nvl((select promise_date

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
	and line_id   = mr.demand_source_line_id),(select promise_date from oe_order_lines_all where line_id = mr.demand_source_line_id)),scheduled_completion_date) "1st Promise Date"
, (select request_date from oe_order_lines_all where line_id = mr.demand_source_line_id)  "Request Date"
, (select schedule_ship_date from oe_order_lines_all where line_id = mr.demand_source_line_id)  "Schedule Ship Date"
, (select attribute20 from oe_order_lines_all where line_id = mr.demand_source_line_id) "Blanket"



, wdj.schedule_group_name "Schedule Group"

     , round(nvl(
	(
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
	)
	,0),2) * nvl(reservation_quantity,ordered_quantity)  "Total Price"


, decode(nvl(to_char(demand_source_header_id), 'None'), 'None', 'None', 'Yes') "Sales Order"

, case when nvl((select wo.quantity_completed
from wip_operations wo
,    wip_discrete_jobs_v wd
,    mtl_system_items_b msi
where wo.organization_id = 85
  and wd.organization_id = wo.organization_id
  and wo.wip_entity_id = wd.wip_entity_id
  and msi.organization_id = wd.organization_id
  and msi.inventory_item_id = wd.primary_item_id
  and wd.wip_entity_id = wdj.wip_entity_id
  --and wd.status_type_disp = 'Released'
  --and line_code = 'OL'
  and rownum = 1
),0) > 0 then 'in assembly' else 'before assembly' end "Location"
, (select e.party_name "Customer"
from oe_order_lines_all ola
,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b
where ola.ship_to_org_id = b.site_use_id -- or a.invoice_to_org_id
	and d.party_id          = e.party_id
	and c.cust_account_id   = d.cust_account_id
	and b.cust_acct_site_id = c.cust_acct_site_id
    and line_id = mr.demand_source_line_id) "Customer"
    , substr(msi.segment1, 0,instr(msi.segment1,'-')-1) "Prefix"
     ,(select meaning from OE_LOOKUPS where ola.shipment_priority_code = lookup_code and lookup_type = 'SHIPMENT_PRIORITY') "Priority"

from wip_discrete_jobs_v wdj
, mtl_system_items_b msi
, mtl_reservations mr
, oe_order_lines_all ola
, oe_order_headers_all oha
where wdj.organization_id      = 85
	and status_type_disp         = 'Released'

	and wdj.organization_id       = msi.organization_id
	and wdj.primary_item_id       = msi.inventory_item_id
	and wdj.wip_entity_id         = mr.supply_source_header_id(+)
    and ola.header_id = oha.header_id(+)
    and mr.demand_source_line_id = ola.line_id(+)
    and line_code not in ('JIT','NJIT', 'OSV')
    
and
nvl(nvl((select promise_date
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
	and line_id   = mr.demand_source_line_id),(select promise_date from oe_order_lines_all where line_id = mr.demand_source_line_id)),scheduled_completion_date) <= apps.xxbim_get_calendar_date('BIM', sysdate, 90)
    
   
   
    
    