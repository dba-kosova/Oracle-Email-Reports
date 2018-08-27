select oeh.order_number
, oel.line_number
, oel.shipment_number
, oel.cust_po_number
, oel.ordered_item
, oel.user_item_description
, sum(wsh.shipped_quantity) shipped_qty
   , sum(round(nvl(
	(
		select ola2.unit_selling_price
		from oe_order_lines_all ola2
		, oe_order_headers_all oha2
		where oel.header_id           = oeh.header_id
			and oel.header_id            = ola2.header_id
			and ola2.header_id           = oha2.header_id
			and oeh.order_number         = oha2.order_number
			and oel.line_number          = ola2.line_number
			and ola2.unit_selling_price is not null
			and ola2.unit_selling_price <> '0'
			and oel.shipment_number      = ola2.shipment_number
			and rownum = 1
	)
	,0)*wsh.shipped_quantity,2)) "Total Price"
, wc.freight_code
, wc.service_level
, wsh.shipment_priority_code
, to_char(''''||wsh.tracking_number) "Tracking Number"
, to_char(oel.request_date, 'MM/DD/YYYY') request_date
, to_char(oel.promise_date, 'MM/DD/YYYY') promise_date
, to_char(oel.actual_shipment_date, 'MM/DD/YYYY') actual_shipment_date
, round(oel.promise_date - oel.actual_shipment_date,0) days_early
, hp_bill.party_name bill_to
, hp_ship.party_name ship_to
from oe_order_lines_all oel
, oe_order_headers_all oeh
, hz_cust_site_uses_all hcs_ship
, hz_cust_acct_sites_all hca_ship
, hz_party_sites hps_ship
, hz_parties hp_ship
, hz_cust_site_uses_all hcs_bill
, hz_cust_acct_sites_all hca_bill
, hz_party_sites hps_bill
, hz_parties hp_bill
, wsh.wsh_delivery_details wsh
,wsh_carrier_ship_methods wc

where oel.open_flag                  = 'N'
	and oel.org_id                      = 83
	and oel.order_source_id            <> 10
    and shippable_flag = 'Y'
	and oel.header_id                   = oeh.header_id
	--and oel.link_to_line_id            is null
	  AND oel.SHIPPABLE_FLAG = 'Y'
	and trunc(oel.actual_shipment_date) < trunc(promise_date)
	and trunc(oel.actual_shipment_date) between apps.xxbim_get_calendar_date('BIM', sysdate, -1) and trunc(sysdate)
	and oeh.invoice_to_org_id      = hcs_bill.site_use_id
	and hcs_bill.cust_acct_site_id = hca_bill.cust_acct_site_id
	and hca_bill.party_site_id     = hps_bill.party_site_id
	and hps_bill.party_id          = hp_bill.party_id
	and oeh.ship_to_org_id         = hcs_ship.site_use_id
	and hcs_ship.cust_acct_site_id = hca_ship.cust_acct_site_id
	and hca_ship.party_site_id     = hps_ship.party_site_id
	and hps_ship.party_id          = hp_ship.party_id
	and oel.ship_from_org_id       = wsh.organization_id(+)
	and oel.line_id                = wsh.source_line_id(+)
	and wsh.carrier_id             = wc.carrier_id
	and wsh.ship_method_code       = wc.ship_method_code
	and wsh.organization_id        = wc.organization_id
	and hp_bill.party_name <> 'John Henry Foster Minnesota Inc'
group by oeh.order_number
, oel.line_number
, oel.shipment_number
, oel.cust_po_number
, oel.ordered_item
, oel.user_item_description
, wc.freight_code
, wc.service_level
, wsh.shipment_priority_code
, wsh.tracking_number
, to_char(oel.request_date, 'MM/DD/YYYY')
, to_char(oel.promise_date, 'MM/DD/YYYY')
, to_char(oel.actual_shipment_date, 'MM/DD/YYYY')
, round(oel.promise_date - oel.actual_shipment_date,0)
, hp_bill.party_name
, hp_ship.party_name
