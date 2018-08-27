select p.organization_code "Org"
, oeh.order_number "Order"
, oel.line_number "Line"
, oel.shipment_number "Shipment"
, oel.ordered_item "Item"
--, wd.item_description
, moline.creation_date "Date Picked"
, wd.released_status_name "Status"
, wd.delivery_id "Delivery"
--, tr.name trip_name
, b.name "Batch"
, wd.requested_quantity "Quantity"
--, wd.tracking_number
, mtl_trx.subinventory_code "Subinv"
, mtl_trx.locator_name "Locator"
, sold_to.account_name "Sold To"
, ship_to.account_name "Ship To"
, ship_to.party_site_name "Ship To Site"
, ship_to.address1 "Add1"
, ship_to.address2 "Add2"
, ship_to.city "City"
, ship_to.state "State"
, ship_to.postal_code "Zip Code"
, ship_to.country "Country"
--, wd.source_header_id
--, wd.source_line_id
, wd.source_header_type_name "Source"
from oe_order_lines_all oel
, wsh_deliverables_v wd
, wsh_delivery_details wdd
, mtl_txn_request_lines moline
, oe_order_headers_all oeh
, hz_cust_accounts_all sold_to
, mtl_parameters p
, wsh_picking_batches b
, wsh_delivery_trips_v tr
, (
		select hcsu.site_use_id
		, hcsu.cust_acct_site_id
		, hca.account_name
		, hca.account_number
		, hps.party_site_name
		, loc.address1
		, loc.address2
		, loc.address3
		, loc.address4
		, loc.city
		, loc.state
		, loc.country
		, loc.postal_code
		from hz_cust_site_uses_all hcsu
		, hz_cust_acct_sites_all hcas
		, hz_cust_accounts_all hca
		, hz_party_sites hps
		, hz_locations loc
		where 1                     =1
			and hcsu.cust_acct_site_id = hcas.cust_acct_site_id
			and hcas.cust_account_id   = hca.cust_account_id
			and hcas.party_site_id     = hps.party_site_id
			and hps.location_id        = loc.location_id
	)
	ship_to
, (
		select mmt.transaction_id
		, mmt.organization_id
		, mmt.move_order_line_id
		, mmt.subinventory_code
		, loc.concatenated_segments locator_name
		from mtl_material_transactions mmt
		, mtl_item_locations_kfv loc
		where 1                       = 1
			and mmt.transaction_quantity < 0
			and mmt.organization_id      = loc.organization_id(+)
			and mmt.locator_id           = loc.inventory_location_id(+)
	)
	mtl_trx
where 1                    = 1
	and wd.delivery_detail_id = wdd.delivery_detail_id
	and wd.source_header_id   = oeh.header_id
	and wd.source_line_id     = oel.line_id
	and wd.move_order_line_id = moline.line_id
	--AND moline.txn_source_line_id = oel.line_id
	and wd.released_status = 'Y'
	--AND moline.organization_id = mtl_trx.organization_id(+)
	--AND moline.line_id = mtl_trx.move_order_line_id(+)
	and wdd.transaction_id     = mtl_trx.transaction_id(+)
	and oeh.sold_to_org_id     = sold_to.cust_account_id
	and wd.ship_to_site_use_id = ship_to.site_use_id(+)
	and wd.batch_id            = b.batch_id(+)
	and wd.organization_id     = p.organization_id
	and wd.organization_id     = 90
	and wd.delivery_id         = tr.delivery_id(+)
	and tr.attribute2(+)       = 'N'