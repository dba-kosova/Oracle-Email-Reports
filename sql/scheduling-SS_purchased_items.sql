select msi.segment1 "Item"
, msi.description "Description"
, item_type "Item Type"
, msi.planner_code "Planner"
, (select max(full_Name) from per_all_people_f where person_Id =  msi.buyer_id) "Buyer"
, nvl(nvl(
	(
		select max(line)
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
					and mtlp.organization_code                                  = 'BIM'
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
			and inventory_item_id = msi.inventory_item_id
	)
	,(
		select attribute1
		from bom_operational_routings
		where alternate_routing_designator is null
			and assembly_item_id               = msi.inventory_item_id
			and organization_id                = msi.organization_id
	)
	) ,planner_code) "Product"
, item_cost "Cost"
, msi.full_lead_time "Full Lead Time"
, msi.cumulative_total_lead_time "Lead Time"
, round(msi.attribute7,1) "EAU"
, round(abs(
	(
		select avg(quantity)
		from
			(
				select ord.item_segments
				, round(sum(ord.quantity) ,2) quantity
				, trunc( new_due_date, 'MM')
				from msc_orders_v ord
				where ord.organization_code = 'BIM:BIM'
					and ord.compile_designator = 'BIM'
					and ord.order_type         = 29
					and category_id           in
					(
						select category_id
						from mtl_item_categories_v
						where category_set_id = 1
					)
				group by trunc( new_due_date, 'MM')
				,ord.item_segments
			)
		where item_segments = msi.segment1
	)
	),1) "Forecast"
, (
		select safety_stock_quantity
		from
			(
				select inventory_item_id
				, effectivity_date
				, safety_stock_quantity
				from mtl_safety_stocks
				where organization_id = 85
				order by effectivity_date desc
			)
		where rownum           = 1
			and inventory_item_id =msi.inventory_item_id
	)
	"Safety Stock"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATR') "ATR"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'ATT') "ATT"
, xxbim_get_quantity(msi.inventory_item_id, msi.organization_id, 'TQ') "TQ"
, (
		select min(sourcing_rule_name)
		from mrp_sr_assignments_v mis
		where mis.organization_id = msi.organization_id
			and inventory_item_id    = msi.inventory_item_id
	)
	"Sourcing Rule"
, (
		select max(category_concat_segs)
		from mtl_item_categories_v
		where category_set_name = 'BIM Safety Stock Priority'
			and organization_id    = msi.organization_id
			and inventory_item_id  = msi.inventory_item_id
	)
	"Safety Stock Priority"
from mtl_system_items_b msi
, mtl_item_categories_v cat
, cst_item_costs cic
where msi.organization_id         = 85
	and cat.structure_id             = '50415'
	and msi.organization_id          = cic.organization_id(+)
	and msi.inventory_item_id        = cic.inventory_item_id(+)
	and msi.organization_id          = cat.organization_id
	and cic.cost_type_id(+)          = 1
	and msi.inventory_item_id        = cat.inventory_item_id
	and inventory_item_status_code   = 'Active'
	and nvl(msi.wip_supply_subinventory,'A') not in ( 'ZAPIT', 'FASTENAL')
	and planning_make_buy_code       = 2
	and nvl(
	(
		select planning_make_buy_code
		from mtl_system_items_b
		where organization_id  = 90
			and inventory_item_id = msi.inventory_item_id
	)
	,2)                     <> 1
	and item_type not       in ('RAD', 'REF', 'OP', 'TOOL', 'EX')
	and category_concat_segs = 'Standard'
