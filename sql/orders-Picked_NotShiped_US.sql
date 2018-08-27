select decode(o.ship_from_org_id,85,'BIM', 90,'BMX') "Org",h.order_number "Order"
, o.line_number "Line"
, o.shipment_number "Shipment"
, o.user_item_description "Item"
, o.request_date "Request"
, oe_line_status_pub.get_line_status(o.line_id, o.flow_status_code) "Status"
, transaction_date "Pick Date"
, apps.ont_oexoewfr_xmlp_pkg.cf_hold_valueformula(o.header_id, o.line_id) "Holds"
, e.party_name "Customer"
, e.country "Country"
, decode(
	(
		select count(1) from ont.oe_order_lines_all where header_id =
			(
				select header_id
				from oe_order_lines_all
				where line_id = o.line_id
			)
			and shippable_flag = 'Y'
			and ship_set_id    =
			(
				select ship_set_id
				from oe_order_lines_all
				where line_id = o.line_id
			)
			group by ship_set_id
	)
	, '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') "Ship Set"
,picks.subinventory_code "Subinv"
, inv_project.get_pjm_locsegs(locator.concatenated_segments) "Locator"
,primary_quantity "Quantity"
, transfer_subinventory "From Subinv"
, inv_project.get_pjm_locsegs(transfer_locator.concatenated_segments) "From Locator"
,net_price*primary_quantity  "Net Price"
from ont.oe_order_lines_all o
, ont.oe_order_headers_all h
, apps.mtl_item_locations_kfv transfer_locator
, apps.mtl_item_locations_kfv locator
,hz_cust_accounts d
, hz_parties e
, hz_cust_acct_sites_all c
, hz_cust_site_uses_all b
,(
		select inventory_item_id
		, subinventory_code
		, locator_id
		, primary_quantity
		, transaction_date
		, transfer_subinventory
		, transfer_locator_id
		, trx_source_line_id
		, organization_id
		from mtl_material_transactions
		where 1=1 --organization_id    = 85
			and transaction_type_id = 52
			and primary_quantity    > 0
	)
	picks
    , (
		select header_id
		, line_number
		, shipment_number
		, sum(unit_list_price   ) list_price
		, sum(unit_selling_price ) net_price
		from oe_order_lines_all
		group by header_id
		, line_number
		, shipment_number
	)
	prc
where 1                                                                =1
	and h.org_id                                                          = 83
	and h.header_id                                                       = o.header_id
	and o.order_source_id                                                <> 10
	and o.shippable_flag                                                  = 'Y'
	and source_type_code                                                 <> 'EXTERNAL'
	and o.ship_from_org_id                                                in ( 85,90)
	and o.open_flag                                                       = 'Y'
	and o.cancelled_flag                                                  = 'N'
	and oe_line_status_pub.get_line_status(o.line_id, o.flow_status_code) = 'Picked'
	and o.ship_to_org_id                                                  = b.site_use_id -- or a.invoice_to_org_id
	and d.party_id                                                        = e.party_id
	and c.cust_account_id                                                 = d.cust_account_id
	and b.cust_acct_site_id                                               = c.cust_acct_site_id
	and o.line_id                                                         = picks.trx_source_line_id(+)
	and o.ship_from_org_id                                                = picks.organization_id(+)
	and picks.locator_id                                                  = locator.inventory_location_id(+)
	and picks.organization_id                                             = locator.organization_id(+)
	and picks.transfer_locator_id                                                  = transfer_locator.inventory_location_id(+)
	and picks.organization_id                                             = transfer_locator.organization_id(+)
	and e.country = 'US'
    	and o.header_id       = prc.header_id
	and o.line_number     = prc.line_number
	and o.shipment_number = prc.shipment_number