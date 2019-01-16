select decode(oel.ship_from_org_id,90,'BMX',85,'BIM',oel.ship_from_org_id) "Ship from Org"
, oeh.order_number "Order Number"
, oel.line_number "Line Number"
, oel.shipment_number "Shipment Number"
, oel.cust_po_number "Customer PO"
, oel.ordered_item "Item"
, oel.user_item_description "UID"
, sum(wsh.shipped_quantity) "Shipped Qty"
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
, wc.freight_code "Freight Code"
, wc.service_level "Service Level"
, wsh.shipment_priority_code "Shipment Piority"
, to_char(''''||wsh.tracking_number) "Tracking Number"
, to_char(oel.request_date, 'MM/DD/YYYY') "Request Date"
, to_char(oel.promise_date, 'MM/DD/YYYY') "Promise Date"
 , apps.xxbim_get_calendar_date(decode(oel.ship_from_org_id,85,'BIM',90,'BMX MWF'),greatest(nvl(
    (
        select trunc(promise_date)
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
        where rownum = 1
            and line_id = oel.line_id
    )
    ,trunc(oel.promise_date)),trunc(oel.request_date)),decode(oel.invoice_to_org_id,222359,2,281854,2,222413,2,0)) "First Promise date"
, to_char(oel.actual_shipment_date, 'MM/DD/YYYY') "Ship Date"
, round(oel.promise_date - oel.actual_shipment_date,0) "Days Early"
, hp_bill.party_name "Bill To"
, hp_ship.party_name "Ship To"
, oel.attribute20 "Blanket"

, case
        when nvl(m.planner_code,'SHV') like '%SHV%' or planning_make_buy_code = '2'
        then 'shelving'
        else 'mto'
    end "Shelving"
    , nvl(category_concat_segs,'Special') "Category"
    
    
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
, mtl_system_items_b m
, mtl_item_categories_v mic

where oel.open_flag                  = 'N'
	and oel.org_id                      = 83
	and oel.order_source_id            <> 10
	and oel.ship_from_org_id = 90
    and oel.ship_from_org_id=  m.organization_id
    and oel.inventory_item_id =m.inventory_item_id
    and shippable_flag = 'Y'
	and oel.header_id                   = oeh.header_id
	--and oel.link_to_line_id            is null
	  AND oel.SHIPPABLE_FLAG = 'Y'
	--and trunc(oel.actual_shipment_date) < trunc(promise_date)
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
	--and hp_bill.party_name <> 'John Henry Foster Minnesota Inc'
        and oel.inventory_item_id                   = mic.inventory_item_id(+)
    and oel.ship_from_org_id                    = mic.organization_id(+)
    and mic.structure_id(+)                   = '50415'
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
, hp_ship.party_name, oel.attribute20
,m.planner_code
,planning_make_buy_code
,category_concat_segs
,oel.invoice_to_org_id
,oel.request_date
,oel.promise_date
, oel.ship_from_org_id
,oel.line_id