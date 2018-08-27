select a.segment1 "Item"
, decode(a.wip_supply_type, '1', 'Push', '2', 'Assembly Pull', '3', 'Opperation Pull', '4', 'Bulk', '5', 'Supplier', '6', 'Phantom') "Supply Type"
, a.wip_supply_subinventory "Supply Subinv"
,c.on_hand_qty "OHQ" 
, c.date_received "Date Recieved"
, round(abs(nvl(
	(
		select sum(primary_quantity)
		from mtl_material_transactions mmt
		where mmt.organization_id  = 90
			and mmt.inventory_item_id = a.inventory_item_id
			and subinventory_code     = c.subinventory_code
			and nvl(locator_id,987654321) = nvl(c.locator_id, 987654321)
			and transaction_type_id            in (35,52,53)
			and transaction_date      > sysdate - 31
	)
	,0)),2) "Issues"
, decode(nvl(
	(
		select sum(primary_quantity)
		from mtl_material_transactions mmt
		where mmt.organization_id  = 90
			and mmt.inventory_item_id = a.inventory_item_id
			and subinventory_code     = c.subinventory_code
			and nvl(locator_id,987654321) = nvl(c.locator_id, 987654321)
			and transaction_type_id            in (35,52,53)
			and transaction_date      > sysdate - 31
	)
	,0),0,0,round(12/(c.on_hand_qty/abs(nvl(
	(
		select sum(primary_quantity)
		from mtl_material_transactions mmt
		where mmt.organization_id  = 90
			and mmt.inventory_item_id = a.inventory_item_id
			and subinventory_code     = c.subinventory_code
			and nvl(locator_id,987654321) = nvl(c.locator_id, 987654321)
			and transaction_type_id            in (35,52,53)
			and transaction_date      > sysdate - 31
	)
	,0))),1)) "Turns"
, decode(nvl(
	(
		select sum(primary_quantity)
		from mtl_material_transactions mmt
		where mmt.organization_id  = 90
			and mmt.inventory_item_id = a.inventory_item_id
			and subinventory_code     = c.subinventory_code
			and nvl(locator_id,987654321) = nvl(c.locator_id, 987654321)
			and transaction_type_id            in (35,52,53)
			and transaction_date      > sysdate - 30.4167
	)
	,0),0,0,round(c.on_hand_qty/abs(nvl(
	(
		select sum(primary_quantity)
		from mtl_material_transactions mmt
		where mmt.organization_id  = 90
			and mmt.inventory_item_id = a.inventory_item_id
			and subinventory_code     = c.subinventory_code
			and nvl(locator_id,987654321) = nvl(c.locator_id, 987654321)
			and transaction_type_id            in (35,52,53)
			and transaction_date      > sysdate - 30.4167
	)
	,0)),1)) "MOH"
, nvl(cat.category_concat_segs,'Special') "Category"
, c.subinventory_code "Subinv"
, inv_project.get_pjm_locsegs(b.concatenated_segments) "Locator"
,a.attribute7 "EAU"
, round(c.on_hand_qty/decode(a.attribute7,0,1,a.attribute7),1) "MOH"
, round(12           /(c.on_hand_qty/decode(a.attribute7,0,1,a.attribute7)),1) "Turns"
, round(d.item_cost  * c.on_hand_qty,2) "Value"
, nvl(nvl(
	(
		select line
		from
			(
				select msic.segment1
				, msic.inventory_item_id
				, boro.attribute1 line
				, msic.attribute7 eau
				, sum(msip.attribute7      * bomc.component_quantity) usage
				,round(sum(msip.attribute7 * bomc.component_quantity) / decode(msic.attribute7,0,1,msic.attribute7) * 100,0) percent
				from apps.mtl_system_items_b msip
				, apps.bom_structures_b boms
				, apps.bom_components_b bomc
				, apps.mtl_system_items_b msic
				, apps.mtl_parameters mtlp
				, bom_operational_routings boro
				where boms.assembly_item_id                                  = msip.inventory_item_id
					and boms.organization_id                                    = msip.organization_id
					and boms.organization_id                                    = mtlp.organization_id
					and mtlp.organization_code                                  = 'BMX'
					and nvl(boms.common_bill_sequence_id,boms.bill_sequence_id) = bomc.bill_sequence_id
					and bomc.component_item_id                                  = msic.inventory_item_id
					and boms.organization_id                                    = msic.organization_id
					and bomc.disable_date                                      is null
					and msip.inventory_item_status_code                         = 'Active'
					and msip.attribute7                                         >0
					and msip.planning_make_buy_code                             = 1
					and boro.organization_id(+)                                 = msip.organization_id
					and boro.assembly_item_id(+)                                = msip.inventory_item_id
					and alternate_routing_designator                           is null
				group by msic.inventory_item_id
				, msic.attribute7
				, msic.segment1
				, boro.attribute1
				order by round(sum(msip.attribute7 * bomc.component_quantity) / decode(msic.attribute7,0,1,msic.attribute7) * 100,0) desc
			)
		where rownum           = 1
			and inventory_item_id = a.inventory_item_id
	)
	,(
		select attribute1
		from bom_operational_routings
		where alternate_routing_designator is null
			and assembly_item_id               = a.inventory_item_id
			and organization_id                = a.organization_id
	)
	) ,planner_code) "Product"
, a.planner_code "Planner"
, decode(a.planning_make_buy_code, 1,'Make',2,'Buy')"Make/Buy"
,      (
select safety_stock_quantity from (
select inventory_item_id , effectivity_date
,      safety_stock_quantity
from MTL_SAFETY_STOCKS 
where organization_id = 90
order by effectivity_date desc)
where rownum = 1
and inventory_item_id =a.inventory_item_id) "Safety Stock"
from mtl_system_items_b a
, (
		select moqd.inventory_item_id
		, moqd.organization_id
		, moqd.subinventory_code
		, max(date_received) date_received
		, moqd.locator_id
		, sum(primary_transaction_quantity) on_hand_qty
		from mtl_onhand_quantities_detail moqd
		group by moqd.inventory_item_id
		, moqd.organization_id
		, moqd.subinventory_code
		, moqd.locator_id
	)
	c
, apps.mtl_item_locations_kfv b
, cst_item_costs d
, mtl_item_categories_v cat
where a.organization_id  = c.organization_id
	and a.inventory_item_id = c.inventory_item_id
	and a.inventory_item_id = d.inventory_item_id(+)
	and a.organization_id   = d.organization_id(+)
	and d.cost_type_id(+)   = 1
	and a.organization_id   = 90
	and a.organization_id   = cat.organization_id(+)
	and cat.structure_id(+) = '50415'
	and a.inventory_item_id = cat.inventory_item_id(+)
	--and c.subinventory_code = 'DW COMP'
	and c.organization_id   = b.organization_id(+)
	and c.locator_id        = b.inventory_location_id(+) 
	