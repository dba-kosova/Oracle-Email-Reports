select ordered_Item, open_quantity open_qty, request, customer, distributer, (select count(1)
from oe_order_lines_all ola
	
		where ola.org_id          = 83
			and ola.attribute20      = 'BLANKET'
			and open_flag            = 'Y'
			and shippable_flag       = 'Y'
			and cancelled_flag       = 'N'
			and order_source_id     <> 10
		and ordered_item = dataset.ordered_item) open_lines
from
	(
		select ordered_item
		, sum(ordered_quantity) open_quantity
		, max(request_date) request
		, e.party_name customer
		, e2.party_name distributer
		from oe_order_lines_all ola
		,hz_cust_accounts d
		, hz_parties e
		, hz_cust_acct_sites_all c
		, hz_cust_site_uses_all b
		,hz_cust_accounts d2
		, hz_parties e2
		, hz_cust_acct_sites_all c2
		, hz_cust_site_uses_all b2
		where ola.org_id          = 83
			and ola.attribute20      = 'BLANKET'
			and open_flag            = 'Y'
			and shippable_flag       = 'Y'
			and cancelled_flag       = 'N'
			and order_source_id     <> 10
			and ship_to_org_id       = b.site_use_id -- or a.invoice_to_org_id
			and d.party_id           = e.party_id
			and c.cust_account_id    = d.cust_account_id
			and b.cust_acct_site_id  = c.cust_acct_site_id
			and invoice_to_org_id    = b2.site_use_id -- or a.invoice_to_org_id
			and d2.party_id          = e2.party_id
			and c2.cust_account_id   = d2.cust_account_id
			and b2.cust_acct_site_id = c2.cust_acct_site_id
		group by ordered_item
		, e.party_name
		, e2.party_name
	) dataset
where request < apps.xxbim_get_calendar_date('BIM', sysdate, 20)