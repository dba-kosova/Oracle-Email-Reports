select item "Item"
, line  "Product"
, open_qty - xxbim_get_quantity(item_id, org, 'TQ') - nvl(
	(
		select sum(quantity_remaining)
		from mtl_system_items_b msi
		, wip_discrete_jobs_v wdj
		where msi.organization_id  = 85
			and msi.organization_id   = wdj.organization_id
			and msi.inventory_item_id = wdj.primary_item_id
			and status_type_disp      = 'Released'
			and segment1              = item
	)
	,0) "Demand after 8 weeks"
, nvl(
	(
		select min(promise_date)
		from oe_order_lines_all
		where promise_date    > rd
			and ordered_item     = item
			and org_id           = 83
			and ship_from_org_id = 85
			and open_flag        = 'Y'
			and cancelled_flag   = 'N'
			and shippable_flag   = 'Y'
	)
	, rd) "Next Release"
, ship_method "Ship Method"
from
	(
		select o.ordered_item item
		, nvl(b.attribute1,'ACC') line
		, sum(o.ordered_quantity- nvl(o.shipped_quantity,0)) open_qty
		, ship_from_org_id org
		, inventory_item_id item_id
		, min(promise_date) rd
		, min(decode (e.country, 'US', 'Ship Direct', 'Ship to BIM')) ship_method
		from oe_order_lines_all o
		, bom_operational_routings b
		,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b1
		where o.org_id                       = 83
			and o.ship_from_org_id              = b.organization_id(+)
			and o.inventory_item_id             = b.assembly_item_id(+)
			and b.alternate_routing_designator is null
			and o.ship_from_org_id              = 85
			and o.open_flag                     = 'Y'
			and o.cancelled_flag                = 'N'
			and o.shippable_flag                = 'Y'
			and o.order_source_id              <> 10
			and ordered_Item not in ('D-113786-A')
			and ordered_item like '%*%'
			and source_type_code               <> 'EXTERNAL'
		--	and promise_date > APPS.XXBIM_GET_CALENDAR_DATE('BIM', sysdate, 40)
			and o.ship_to_org_id   = b1.site_use_id -- or a.invoice_to_org_id
	and d.party_id          = e.party_id
	and c.cust_account_id   = d.cust_account_id
	and b1.cust_acct_site_id = c.cust_acct_site_id
			and b.attribute1 not               in ('FP', 'CSS', 'PT', 'EF')
			and
			(
				select distinct sourcing_rule_name
				from mrp_sr_assignments_v mis
				where mis.organization_id  = 85
					and mis.inventory_item_id = o.inventory_item_id
			)
			                                                  is null
			and o.ordered_quantity- nvl(o.shipped_quantity ,0) > 0
		group by ordered_item
		, nvl(b.attribute1,'ACC')
		, o.ship_from_org_id
		, inventory_item_id
	)
where open_qty - xxbim_get_quantity(item_id, org, 'TQ') -nvl(
	(
		select sum(quantity_remaining)
		from mtl_system_items_b msi
		, wip_discrete_jobs_v wdj
		where msi.organization_id  = 85
			and msi.organization_id   = wdj.organization_id
			and msi.inventory_item_id = wdj.primary_item_id
			and status_type_disp      = 'Released'
			and segment1              = item
	)
	,0)          > 100
	and open_qty > xxbim_get_quantity(item_id, org, 'TQ') + nvl(
	(
		select sum(quantity_remaining)
		from mtl_system_items_b msi
		, wip_discrete_jobs_v wdj
		where msi.organization_id  = 85
			and msi.organization_id   = wdj.organization_id
			and msi.inventory_item_id = wdj.primary_item_id
			and status_type_disp      = 'Released'
			and segment1              = item
	)
	,0)
	and rd is not null
order by to_date( nvl(
	(
		select min(promise_date)
		from oe_order_lines_all ola
		where promise_date    > rd
			and ordered_item     = item
			and org_id           = 83
			and ship_from_org_id = 85
			and
			(
				select distinct sourcing_rule_name
				from mrp_sr_assignments_v mis
				where 1                    =1
					and mis.organization_id   = ola.ship_from_org_id
					and mis.inventory_item_id = ola.inventory_item_id
					and sourcing_rule_name    = 'BIM Transfer from BMX'
			)
			                  is null
			and open_flag      = 'Y'
			and cancelled_flag = 'N'
			and shippable_flag = 'Y'
	)
	, rd)) asc