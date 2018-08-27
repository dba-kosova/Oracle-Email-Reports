select 
group_id "Group ID"
, source_code "Source"
, (select user_name from fnd_user fnd where fnd.user_id = mjs.created_by) "User"
, creation_date "Date"
, organization_id "Org"
, (
		select meaning
		from fnd_lookup_values
		where load_type  = lookup_code
			and lookup_type = 'WIP_LOAD_TYPE'
	)
	"Load Type"
, (
		select meaning
		from fnd_lookup_values
		where process_phase = lookup_code
			and lookup_type    = 'WIP_ML_PROCESS_PHASE'
	)
	"Phase"
, (
		select meaning
		from fnd_lookup_values
		where process_status = lookup_code
			and lookup_type     ='WIP_PROCESS_STATUS'-- 'WIP_ML_ERROR_TYPE'
	)
	"Status"
, (
		select item_name
		from msc_system_items
		where plan_id          = 21
			and sr_inventory_item_id = mjs.primary_item_id
			and organization_id = mjs.organization_id
	)
	"Item"
, (select wip_entity_name from wip_entities where wip_entity_id = mjs.wip_entity_id) "Job"
, first_unit_start_Date
, last_Unit_completion_date
, start_quantity "Start Quantity"
from wip_job_schedule_interface mjs
where creation_date > sysdate-1
and source_code = 'MSC'
--and group_id = 13372978
order by creation_date

