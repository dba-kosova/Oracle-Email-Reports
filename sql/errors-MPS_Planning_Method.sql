select segment1 "Item"
, decode(mrp_planning_code, 7, 'MRP/MPP Planned',3,'MRP planned',6, 'Not planned', 'other') "MPS Planning Method"
, item_type "Item Type"
,inventory_item_status_code "Status"
, case
		when
			(
				inventory_item_status_code <> 'Active'
				and mrp_planning_code       = 7
			)
		then 'should be not planned'
		when
			(
				inventory_item_status_code = 'Active'
				and mrp_planning_code     <> 7
			)
		then 'should be planned'
		else 'what?'
	end "Problem"
from mtl_system_items_b msi
where msi.organization_id = 85
	and segment1  not like ('OC_BIM_%')
  and segment1 not like ('RMA-%')
	and item_type not in ( 'RAD', 'TOOL', 'TOOL PKG', 'REF', 'OP', 'EX', 'PTO')
	and nvl(
	(
		select max(subinventory_code)
		from mtl_item_sub_defaults
		where inventory_item_id = msi.inventory_item_id
			and organization_id    = msi.organization_id
	)
	,'asdf') not in ('FL COMP', 'ZAPIT')
	and
	(
		(
			inventory_item_status_code <> 'Active'
			and mrp_planning_code       = 7
		)
		or
		(
			inventory_item_status_code = 'Active'
			and mrp_planning_code     <> 7
		)
	) 