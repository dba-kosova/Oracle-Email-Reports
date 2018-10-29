select ordern "Order Number" 
, ship_set "Ship Set" 
, Minr "Min Request"
, Maxr "Max Request"
, Minp "Min Promise"
, Maxp "Max Promise"
, lines "Mismatched Lines"
, dist "Distributor"
, cust  "Customer"
, country "Country"

from (

select order_number ordern
, ship_set ship_set
, min(request_date) Minr
, max(request_date) Maxr
, min(promise_date) Minp
, max(promise_date) Maxp
, count(1) lines
,dist 
, cust
, country 
from
	(
		select h.order_number
		, set_name ship_set
		,trunc(l.request_date) request_date
		,trunc(l.promise_date) promise_date
		, e.country
		, e.party_name cust
		, e2.party_name dist
		from oe_order_lines_all l
		, oe_order_headers_all h
		, oe_sets s
		,hz_cust_accounts d
		, hz_parties e
		, hz_cust_acct_sites_all c
		, hz_cust_site_uses_all b
		,hz_cust_accounts d2
		, hz_parties e2
		, hz_cust_acct_sites_all c2
		, hz_cust_site_uses_all b2
		where h.org_id          = 83
			and l.open_flag        = 'Y'
			and l.ship_set_id      = s.set_id
			and l.cancelled_flag   = 'N'
			and l.order_source_id <> 10
			and l.header_id        = h.header_id
			and l.shippable_flag   = 'Y'
			and
			(
				select count(1)
				from ont.oe_order_lines_all
				where header_id =
					(
						select header_id
						from oe_order_lines_all
						where line_id = l.line_id
					)
					and shippable_flag = 'Y'
					and ship_set_id    =
					(
						select ship_set_id
						from oe_order_lines_all
						where line_id = l.line_id
					)
				group by ship_set_id
			)
			                         > 1
			and l.ship_to_org_id     = b.site_use_id -- or a.invoice_to_org_id
			and d.party_id           = e.party_id
			and c.cust_account_id    = d.cust_account_id
			and b.cust_acct_site_id  = c.cust_acct_site_id
			and l.invoice_to_org_id  = b2.site_use_id -- or a.invoice_to_org_id
			and d2.party_id          = e2.party_id
			and c2.cust_account_id   = d2.cust_account_id
			and b2.cust_acct_site_id = c2.cust_acct_site_id
		group by h.order_number
		, set_name
		,trunc(l.request_date)
		,trunc(l.promise_date)
		, e.country
		, e.party_name
		, e2.party_name
	)
having count(1) > 1
group by order_number
, ship_set
,dist
, cust
, country
order by min(request_date), min(promise_date)
)
where 
(greatest(Minr,Maxr) > Minp
or maxp<>minp)


union all


select order_number ordern
, ship_set ship_set
,request_date Minr
,request_date
, promise_date Minp
, promise_date
,1
,dist 
, cust
, country 
from
	(
		select h.order_number
		, set_name ship_set
		,trunc(l.request_date) request_date
		,trunc(l.promise_date) promise_date
		, e.country
		, e.party_name cust
		, e2.party_name dist
		from oe_order_lines_all l
		, oe_order_headers_all h
		, oe_sets s
		,hz_cust_accounts d
		, hz_parties e
		, hz_cust_acct_sites_all c
		, hz_cust_site_uses_all b
		,hz_cust_accounts d2
		, hz_parties e2
		, hz_cust_acct_sites_all c2
		, hz_cust_site_uses_all b2
		where h.org_id          = 83
			and l.open_flag        = 'Y'
			and l.ship_set_id      = s.set_id
			and l.cancelled_flag   = 'N'
			and l.order_source_id <> 10
			and l.header_id        = h.header_id
			and l.shippable_flag   = 'Y'
	and trunc(l.request_date-2) > trunc(l.promise_date)
			and l.ship_to_org_id     = b.site_use_id -- or a.invoice_to_org_id
			and d.party_id           = e.party_id
			and c.cust_account_id    = d.cust_account_id
			and b.cust_acct_site_id  = c.cust_acct_site_id
			and l.invoice_to_org_id  = b2.site_use_id -- or a.invoice_to_org_id
			and d2.party_id          = e2.party_id
			and c2.cust_account_id   = d2.cust_account_id
			and b2.cust_acct_site_id = c2.cust_acct_site_id
		group by h.order_number
		, set_name
		,trunc(l.request_date)
		,trunc(l.promise_date)
		, e.country
		, e.party_name
		, e2.party_name)



