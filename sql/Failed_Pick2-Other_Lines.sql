select we.date_released "Date Released"
, we.wip_entity_name "Job"
, we.project_name "Project"
, line_code "Line"
, msip.segment1 "Assembly"
, we.attribute4 "QS"

from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msip
where we.organization_id  = 85
	and msip.organization_id = we.organization_id
	and wro.organization_id  = we.organization_id
	and date_released > trunc(sysdate)
	and we.line_code not like 'SUB%'
	or we.line_code <> 'OLE'
	or we.line_code <> 'CSS'
	or we.line_code <> 'PM'
	or we.line_code <> 'PT'
	or we.line_code <> 'TB'
	or we.line_code <> 'UL'
    or we.line_code <> 'UB'
	or we.line_code <> 'EF'
	or we.line_code <> 'DW'
	and we.wip_entity_id       = wro.wip_entity_id
	and msip.inventory_item_id = we.primary_item_id
	and wro.wip_supply_type = '1'
	and we.status_type = 3 -- released
	and not exists (
	select wdj.wip_entity_id
from mtl_txn_request_headers toh
, mtl_txn_request_lines tol
, mtl_material_transactions_temp mmtt
, mtl_transaction_types mtt
, wip_discrete_jobs_v wdj
where toh.header_id             = tol.header_id
  and toh.organization_id        = tol.organization_id
  and tol.line_id                = mmtt.move_order_line_id
  and mmtt.transaction_type_id   = mtt.transaction_type_id
  and mmtt.organization_id       = 85
  and mmtt.organization_id       = tol.organization_id
  and mmtt.organization_id       = wdj.organization_id(+)
  and mmtt.transaction_source_id = wdj.wip_entity_id(+)
	and mmtt.inventory_item_id = wro.inventory_item_id
	and wdj.wip_entity_id = we.wip_entity_id
  )
	
	group by 
	 we.date_released 
, we.wip_entity_name
, we.project_name
, line_code
, msip.segment1 
, we.attribute4

order by line_code