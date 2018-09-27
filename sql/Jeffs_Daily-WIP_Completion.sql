select
	(
		select segment1
		from mtl_system_items_b
		where organization_id  = mmt.organization_id
			and inventory_item_id = mmt.inventory_item_id
	)
	"Item"
	, (
		select description
		from mtl_system_items_b
		where organization_id  = mmt.organization_id
			and inventory_item_id = mmt.inventory_item_id
	)
	"Description"
,transaction_date "Date"
, subinventory_code "Subinventory"
, inv_project.get_pjm_locsegs(
	(
		select c.concatenated_segments
		from apps.mtl_item_locations_kfv c
		where c.organization_id      = mmt.organization_id
			and c.inventory_location_id = mmt.locator_id
	)
	) "Locator"
, (
		select user_name
		from fnd_user
		where user_id = mmt.created_by
	)
	"User"
, primary_quantity "Quantity"
, primary_quantity*
	(
		select item_cost
		from cst_item_costs
		where cost_type_id     = 1
			and organization_id   = mmt.organization_id
			and inventory_item_id = mmt.inventory_item_id
	)
	"Value (frozen)"
, (
		select transaction_type_name
		from mtl_transaction_types
		where transaction_type_id = mmt.transaction_type_id
	)
	"Type"
, (
		select description
		from mtl_generic_dispositions
		where organization_id = mmt.organization_id
			and disposition_id   = transaction_source_id
	)
	"Account"
    ,transaction_type_id
    ,(select wdj.wip_entity_name from wip_discrete_jobs_v wdj where organization_id = mmt.organization_id and wip_entity_id = mmt.transaction_source_id) "Job"
    ,(select wdj.project_name from wip_discrete_jobs_v wdj where organization_id = mmt.organization_id and wip_entity_Id = mmt.transaction_source_id) "Project"
    ,(select wdj.line_code from wip_discrete_jobs_v wdj where organization_id = mmt.organization_id and wip_entity_Id = mmt.transaction_source_id) "Project"

from mtl_material_transactions mmt

where mmt.organization_id     = 85
	and transaction_date  between apps.xxbim_get_calendar_date('BIM', sysdate, -1) and trunc(sysdate)
    --and transaction_type_id = 44
    and transaction_type_id = 44

    order by 3