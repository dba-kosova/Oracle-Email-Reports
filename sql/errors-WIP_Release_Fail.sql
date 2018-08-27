select wdj.organization_id
, err.creation_date
, wjs.source_code
, err.error
, wdj.wip_entity_name
, wdj.schedule_group_name
from wip_interface_errors err
, wip_job_schedule_interface wjs
, wip_discrete_jobs_v wdj
where err.creation_date > trunc(sysdate)-1
	and err.interface_id   = wjs.interface_id
	and wjs.wip_entity_id  = wdj.wip_entity_id 