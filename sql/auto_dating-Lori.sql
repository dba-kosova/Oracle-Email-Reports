select distinct order_number "Order Number"
,CUST_PO_NUMBER "PO Number"

, line_number "Line Number"
, shipment_number "Shipment Number"
, user_item_description "Part Number"
, ordered_quantity "Order Quantity"

,  ep1 "Customer"
, ep2 "Distributor"
     ---, ordered_item, user_item_description
, max(new_promise_date) "New Promise Date"
, promise_date "Old Promise Date"
,ship_method 	"Ship Method"


from
	(
		select v.order_number
		, olawin.line_number
		, olawin.shipment_number
		, olawin.ordered_item
		, olawin.promise_date
		, ordered_quantity
		, new_promise_date
		, user_item_description,
		 e.party_name ep1
, e2.party_name ep2
,CUST_PO_NUMBER
, (
		select service_level
		from WSH_CARRIER_SHIP_METHODS wcsm
		where 1=1
		and olawin.shipping_method_code = wcsm.ship_method_code
		and olawin.ship_from_org_id = wcsm.organization_id
	) ship_method
		from oe_order_lines_all olawin
		,(
				select msi.segment1 assembly_item
				, wdj.wip_entity_name job_number
				, wdj.line_code
				, b.demand_source_line_id
				, (
						select oha.order_number
						from oe_order_headers_all oha
						where oha.header_id = ola.header_id
					)
					order_number
				, line_number 
				, ola.request_date
				, ola.promise_date
				, ola.schedule_ship_date
				,decode(
					(
						select count(1) from ont.oe_order_lines_all where header_id =
							(
								select header_id
								from oe_order_lines_all
								where line_id = ola.line_id
							)
							and shippable_flag = 'Y'
							and ship_set_id    = ola.ship_set_id group by ship_set_id
					)
					, '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') ship_set
				, ola.ship_set_id
				, ola.header_id
				, (
						select min(old_schedule_date)
						from msc_supplies ord
						, msc.msc_system_items msc
						where ord.organization_id  = 85
							and order_type           in (1,2,3) --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
							and item_name             = msi2.segment1
							and ord.plan_id           = msc.plan_id
							and msc.plan_id           = 21
							and ord.organization_id   = msc.organization_id
							and ord.inventory_item_id = msc.inventory_item_id
							and old_schedule_date     > apps.xxbim_get_calendar_date('BIM', sysdate,-5)
					)
					supply_date
				, apps.xxbim_get_calendar_date('BIM',(
						select min(old_schedule_date)
						from msc_supplies ord
						, msc.msc_system_items msc
						where ord.organization_id  = 85
							and order_type           in (1,2,3) --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
							and item_name             = msi2.segment1
							and ord.plan_id           = msc.plan_id
							and msc.plan_id           = 21
							and ord.organization_id   = msc.organization_id
							and ord.inventory_item_id = msc.inventory_item_id
							and old_schedule_date     > apps.xxbim_get_calendar_date('BIM', sysdate,-5)
					)
					,5) new_promise_date
					--  , pjm_project.val_proj_idtoname(wdj.project_id) project_number
				, msi2.segment1 component_item
				, msi2.planner_code
				, wdj.status_type_disp job_status
				, count(1) over (partition by wro.inventory_item_id) jobs_short_this_comp
				, wdj.scheduled_start_date sched_job_start_date
				, wdj.scheduled_completion_date sched_job_end_date
				, wip_supply.meaning wip_supply
				, wro.supply_subinventory supply_si
				, wro.date_required
				, wro.required_quantity
				, wro.quantity_allocated
				, wro.quantity_issued
				, (wro.required_quantity                               - wro.quantity_issued) qty_open
				, substr(wro.attribute2, instr(wro.attribute2, '|', 1) + 1, instr(wro.attribute2, '|', -1) - instr(wro.attribute2, '|', 1) - 1) on_hand
				, substr(wro.attribute2, instr(wro.attribute2, '|',    -1) + 1, length(wro.attribute2) - instr(wro.attribute2, '|', -1)) total_req
				, substr(wro.attribute2, instr(wro.attribute2, '|',    -1) + 1, length(wro.attribute2) - instr(wro.attribute2, '|', -1)) - substr(wro.attribute2, instr(wro.attribute2, '|', 1) + 1, instr(wro.attribute2, '|', -1) - instr(wro.attribute2, '|', 1) - 1) qty_short
				from wip_discrete_jobs_v wdj
				, wip_requirement_operations wro
				, mtl_system_items_b msi
				, mtl_system_items_b msi2
				, mfg_lookups wip_supply
				, mtl_reservations b
				, oe_order_lines_all ola
				where wdj.organization_id    = 85
					and wdj.wip_entity_id       = wro.wip_entity_id
					and wdj.organization_id     = wro.organization_id
					and wdj.primary_item_id     = msi.inventory_item_id
					and wdj.organization_id     = msi.organization_id
					and wro.inventory_item_id   = msi2.inventory_item_id
					and wro.organization_id     = msi2.organization_id
					and wdj.wip_entity_id       = b.supply_source_header_id
					and ola.shipment_priority_code = 'Standard'
					and wdj.organization_id     = b.organization_id
					and b.demand_source_line_id = ola.line_id
					and wro.attribute2         is not null
					and wro.attribute2 not like '0%'
					and wro.wip_supply_type        = wip_supply.lookup_code(+)
					and wip_supply.lookup_type(+)  = 'WIP_SUPPLY'
					and ola.open_flag              = 'Y'
					and ola.booked_flag            = 'Y'
					and ola.shippable_flag         = 'Y'
					and ola.cancelled_flag         = 'N'
					and wdj.build_sequence is null
          order by jobs_short_this_comp desc
				, component_item
				, date_required
			)
			v
			,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b

,hz_cust_accounts d2
, hz_parties e2
, hz_cust_acct_sites_all c2
, hz_cust_site_uses_all b2
		where olawin.ship_set_id   = v.ship_set_id
			and olawin.header_id      = v.header_id
			and olawin.shippable_flag = 'Y'
			and olawin.open_flag      = 'Y'
			and olawin.cancelled_flag = 'N'
			and olawin.booked_flag    = 'Y'
			and olawin.shipment_priority_code = 'Standard'
      and olawin.actual_shipment_date is null  
      and olawin.attribute20  is null
			and new_promise_date      > apps.xxbim_get_calendar_date('BIM', olawin.promise_date, 3)
			and new_promise_date      < apps.xxbim_get_calendar_date('BIM', sysdate, 25)
			and olawin.ship_to_org_id
		                      = b.site_use_id -- or a.invoice_to_org_id
	and d.party_id          = e.party_id
	and c.cust_account_id   = d.cust_account_id
	and b.cust_acct_site_id = c.cust_acct_site_id
	and olawin.invoice_to_org_id
		                      = b2.site_use_id -- or a.invoice_to_org_id
	and d2.party_id          = e2.party_id
	and c2.cust_account_id   = d2.cust_account_id
	and b2.cust_acct_site_id = c2.cust_acct_site_id

		union all
		select v.order_number
		, olawin.line_number
		, olawin.shipment_number 
		, olawin.ordered_item
		, olawin.promise_date
		, ordered_quantity
		, new_promise_date
		, user_item_description,
		 e.party_name ep1
, e2.party_name ep2
		,CUST_PO_NUMBER
, (
		select service_level
		from  WSH_CARRIER_SHIP_METHODS wcsm
		where 1=1
		and olawin.shipping_method_code = wcsm.ship_method_code
		and olawin.ship_from_org_id = wcsm.organization_id
	) ship_method
		from oe_order_lines_all olawin
		,(
				select msi.segment1 assembly_item
				, msi.description
				, wdj.wip_entity_name
				, wdj.project_name
				, apps.xxbim_get_working_days(85, scheduled_start_date,date_released) days_late
				,apps.xxbim_get_calendar_date('BIM',sysdate,apps.xxbim_get_working_days(85, scheduled_start_date, scheduled_completion_date)+2) new_promise_date
				, b.demand_source_line_id
				, (
						select order_number
						from oe_order_headers_all
						where header_id = ola.header_id
					)
					order_number
				, ola.line_number
				, ola.request_date
				, ola.promise_date
				, ola.schedule_ship_date
				,decode(
					(
						select count(1) from ont.oe_order_lines_all where header_id =
							(
								select header_id
								from oe_order_lines_all
								where line_id = ola.line_id
							)
							and shippable_flag = 'Y'
							and ship_set_id    = ola.ship_set_id group by ship_set_id
					)
					, '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') ship_set
				, ola.ship_set_id
				, ola.header_id
				from mtl_system_items_b msi
				, wip_discrete_jobs_v wdj
				, mtl_reservations b
				, oe_order_lines_all ola
				where msi.organization_id                                                = 85
					and msi.organization_id                                                 = wdj.organization_id
					and msi.inventory_item_id                                               = wdj.primary_item_id
					and trunc(wdj.date_released)                                            = apps.xxbim_get_calendar_date('BIM', sysdate,-1)
					and trunc(scheduled_start_date)                                         < trunc(date_released)
					and apps.xxbim_get_working_days(85, scheduled_start_date,date_released) > 3
					and status_type_disp                                                    = 'Released'
					and wdj.build_sequence is null
					and wdj.wip_entity_id                                                   = b.supply_source_header_id
					and wdj.organization_id                                                 = b.organization_id
					and b.demand_source_line_id                                             = ola.line_id
					and ola.open_flag                                                       = 'Y'
					and ola.cancelled_flag                                                  = 'N'
					and ola.booked_flag                                                     = 'Y'
					and ola.shippable_flag                                                  = 'Y'
					and ola.shipment_priority_code = 'Standard'
			)
			v
				,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b

,hz_cust_accounts d2
, hz_parties e2
, hz_cust_acct_sites_all c2
, hz_cust_site_uses_all b2
		
		where olawin.ship_set_id   = v.ship_set_id
			and olawin.header_id      = v.header_id
			and new_promise_date      > olawin.promise_date
			and olawin.shippable_flag = 'Y'
			and olawin.open_flag      = 'Y'
			and olawin.cancelled_flag = 'N'
			and olawin.booked_flag    = 'Y'
			and olawin.shipment_priority_code = 'Standard'
      and olawin.actual_shipment_date is null 
      and olawin.attribute20  is null
			and new_promise_date > apps.xxbim_get_calendar_date('BIM', olawin.promise_date, 3)
			and olawin.ship_to_org_id
		                      = b.site_use_id -- or a.invoice_to_org_id
	and d.party_id          = e.party_id
	and c.cust_account_id   = d.cust_account_id
	and b.cust_acct_site_id = c.cust_acct_site_id
	and olawin.invoice_to_org_id
		                      = b2.site_use_id -- or a.invoice_to_org_id
	and d2.party_id          = e2.party_id
	and c2.cust_account_id   = d2.cust_account_id
	and b2.cust_acct_site_id = c2.cust_acct_site_id


	)
group by order_number, line_number, shipment_number, CUST_PO_NUMBER
,  ep1 , ordered_quantity
, ep2 , user_item_description
, promise_date,ship_method