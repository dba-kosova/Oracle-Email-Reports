select
org "org"
,job "Job"
,project "Project"
,line "Line"
,item "Item"
,description "Description"
,dff "DFF"
,order_qty "Order Qty"
,qty_reserved "Qty Reserved"
,open_qty "Open Qty"
,qty_atr "Qty ATR"
,qty_tq "Qty TQ"
,planned_start_date "Planned Start Date"
,released "Released"
,created "Created"
,request "Request"
,schedule_ship "Schedule Ship"
,promise "Promise"
,first_Promise_Date "1st Promise"
, nvl(trunc(case when status='Unreleased' then greatest(apps.xxbim_get_calendar_date('BIM',planned_start_date,total_lt),request)
     when status='Released' or status='Production Partial' then  greatest(apps.xxbim_get_calendar_date('BIM',planned_start_date,assy_lt-apps.xxbim_get_working_days(85,released,sysdate)),request)
     when status='On Hold' then greatest(apps.xxbim_get_calendar_date('BIM',planned_start_date, assy_lt),request)
     when line is null then promise
     when status = 'Picked' then sysdate
     else promise
     end),first_Promise_Date) "Estimated Ship Date"
,status "Status"
,Category "Category"
,hold "Hold"
,ship_set "Ship Set"
, Sourcing "Sourcing"
,Blanket "Blanket"
,Priority "Priority"
,ship_method "Ship Method"
,Unit_Price "Unit Price"
,total_price "Total Price"
,DOM_INT "DOM/INT"
,customer "Customer"
,distributor "Distributor"
,hold_details "Hold Details"
,Hold_Type "Hold Type"
,moves "Date Moves"
,Schedule_Group "Schedule Group"
,prefix "Prefix"
,staging "In Staging - 90% accurate"

from (

select distinct decode(ola.ship_from_org_id,85,'BIM',90,'BMX') org
, wdj.wip_entity_name job
, pjm.project_number project
, (select attribute1 from bom_operational_routings b where alternate_routing_designator is null and b.organization_id = ola.ship_from_org_id and assembly_item_id = ola.inventory_item_id) line
, msi.segment1 item
, substr(msi.description,0,30) description
, wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 dff
, ordered_quantity order_qty
, reservation_quantity qty_reserved
, wdj.quantity_remaining open_qty
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') Qty_ATR
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') Qty_TQ
, case when wdj.status_type = 3 /* released */ then trunc(date_released)
       else greatest(nvl((select
                        -- get greatest of all shortages
                        max((
                            select
                                trunc(min(old_schedule_date))
                            from
                                msc_supplies ord, msc.msc_system_items msc
                            where
                                ord.organization_id = 85
                                and order_type in(
                                    1, 2, 3
                                ) --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
                                and item_name = wro.segment1
                                and ord.plan_id = msc.plan_id
                                and msc.plan_id = 21
                                and ord.organization_id = msc.organization_id
                                and ord.inventory_item_id = msc.inventory_item_id
                                -- don't want way past due supply
                                -- and old_schedule_date > apps.xxbim_get_calendar_date('BIM', sysdate, - 5)
                        )) supply_date
                    from
                        wip_requirement_operations wro
                        , wip_discrete_jobs wd
                    where
                        1 = 1
                       -- and wro.wip_entity_id = 15696803
                        and wro.organization_id = 85
                        and wro.attribute2 is not null
                        and wro.attribute2 not like '0%'
                        and wro.wip_entity_id = wd.wip_entity_id
                        and wd.project_id = wdj.project_id
                ), trunc(scheduled_start_date)),trunc(sysdate, 'D')) end Planned_Start_Date
, wdj.date_released Released
, least(ola.creation_date,line_date) Created
, trunc(ola.request_date) Request
, trunc(ola.schedule_ship_date) Schedule_Ship
, trunc(ola.promise_date) Promise

, nvl((select promise_date
from
	(
		select hist_creation_date
		, promise_date
		,header_id
		,line_id
		from oe_order_lines_history h
		where 1=1
			and promise_date is not null
		order by hist_creation_date asc
	)
where rownum   = 1
	and line_id   = ola.line_id),promise_date) first_Promise_Date

, nvl(decode(wdj.status_type_disp, 'Released', 'Released', 'Unreleased', 'Unreleased', 'On Hold', 'On Hold', null) , (
		 OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) 
		
	)
	) Status
,nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = msi.organization_Id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = ola.inventory_item_id), 'Special') Category


, 
		 apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) Hold
	,decode(
						(
							select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
								and shippable_flag                                         = 'Y'
								and ship_set_id                                            = ola.ship_set_id group by ship_set_id
						)
						, '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') Ship_Set


	,(select distinct sourcing_rule_name from MRP_SR_ASSIGNMENTS_V  mis
where mis.organization_id = ola.ship_from_org_id
and mis.inventory_item_id = ola.inventory_item_id
	) Sourcing

, ola.attribute20 Blanket
,(select meaning from OE_LOOKUPS where ola.shipment_priority_code = lookup_code and lookup_type = 'SHIPMENT_PRIORITY') Priority
, (
		select service_level
		from  WSH_CARRIER_SHIP_METHODS wcsm
		where  wcsm.ship_method_code = ola.shipping_method_code
		and  wcsm.organization_id = ola.ship_from_org_id
	)
	Ship_Method
    
    , round(prc.net_price,2) Unit_Price
    , round(prc.net_price  * nvl(reservation_quantity,ordered_quantity), 2)  Total_Price
        
   , decode (e.country, 'US', 'DOM','CA', 'INT', 'MX','INT', null, 'DOM', 'INT') DOM_INT
, e.party_name Customer
, e2.party_name Distributor
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
and ohsa.hold_id = ohd.hold_id) Hold_Details

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
and ohsa.hold_id = ohd.hold_id) Hold_Type
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
, wdj.schedule_group_name Schedule_Group
, substr(msi.segment1, 0,instr(msi.segment1,'-')-1) Prefix
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
group by we.wip_entity_name),'No'),'No','No','Yes') staging
from 

oe_order_lines_all ola
, oe_order_headers_all oha
, PJM_SEIBAN_NUMBERS pjm
, MTL_RESERVATIONS_ALL_v mra
, wip_discrete_jobs_v wdj
, mtl_system_items_b msi
, hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b
, hz_cust_accounts d2
, hz_parties e2
, hz_cust_acct_sites_all c2
, hz_cust_site_uses_all b2
, (
		select header_id
		, line_number
		, shipment_number
        , min(creation_date) line_date
		, sum(unit_list_price ) list_price
		, sum(unit_selling_price) net_price
		from oe_order_lines_all
		group by header_id
		, line_number
		, shipment_number
	)
	prc
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
	and ola.header_id       = prc.header_id
	and ola.line_number     = prc.line_number
	and ola.shipment_number = prc.shipment_number


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
    and ola.line_type_id not in (1073,1127) -- return, sample, vendor order

)    orders


, (select t2.line_code
, t2.work_days + t2.padding assy_lt
, nvl(t1.work_days,0) + nvl(t1.padding,0) + t2.work_days + t2.padding total_lt
from
	(
		select wl.line_code
		, round(avg( apps.xxbim_get_working_days(85, date_released, date_completed))) work_days
		, round(stddev(apps.xxbim_get_working_days(85, date_released, date_completed))/2) padding
		from wip_discrete_jobs wdj
        , wip_lines wl
		where wdj.organization_id      = 85
			and wdj.line_id = wl.line_id
            and wdj.organization_Id = wl.organization_id
			and wdj.status_type      = 4
			and start_quantity            = quantity_completed
			and trunc(wdj.date_completed) > apps.xxbim_get_calendar_date('BIM',sysdate,-10)
			and wl.line_code not                           in ('CSD', 'NJIT','OSV', 'JIT')
			and wl.line_code not like 'SUB%'
		group by wl.line_code
	)
	t1
, (
		select line_code
		, round(avg( apps.xxbim_get_working_days(85, date_released, date_completed))) work_days
		, round(stddev(apps.xxbim_get_working_days(85, date_released, date_completed))) padding
		from
			(
                select wl_p.line_code
				, wdj.project_id
				, wdj.date_released
				, wdj.date_completed
				from wip_discrete_jobs wdj
                , wip_lines wl
				, wip_discrete_jobs wdj_p
                , wip_lines wl_p
				where wdj.organization_Id = 85
					and wdj_p.organization_id = 85
                    and wdj.status_type = 4 -- complete
					and wdj.project_id        = wdj_p.project_id
                    and wdj.organization_id = wl.organization_id
                    and wdj_p.organization_id = wl_p.organization_id
                    and wdj.line_id = wl.line_id
                    and wdj_p.line_id = wl_p.line_id
					and wl_p.line_code      <> 'JIT'
					and wl_p.line_code not like 'SUB%'
					and wdj.start_quantity        = wdj.quantity_completed
					and trunc(wdj.date_completed) > apps.xxbim_get_calendar_date('BIM',sysdate,-10)
					and wl.line_code             = 'JIT'
			)
		group by line_code
	)
	t2
where t2.line_code = t1.line_code(+)) lead_time

where orders.line = lead_time.line_code(+)

order by trunc(schedule_ship) asc
