-- closed mo
SELECT toh.request_number MO
,greatest(0,round((mmt.transaction_date - case when apps.xxbim_get_working_days(85,toh.creation_date,mmt.transaction_date) >1 then toh.creation_date + 8/24 else toh.creation_date end)*24,0)-5) hours_past_goal
,bd.department_code Line 
,toh.creation_date creation_date
,mmt.transaction_date
FROM mtl_txn_request_headers toh,
  mtl_txn_request_lines tol,
  mtl_material_transactions mmt,
  fnd_lookup_values_vl vl,
  fnd_lookup_values_vl vl2,
  mtl_transaction_types mtt,
  apps.fnd_user usr,
  wip_discrete_jobs_v wdj,
  fnd_lookup_values_vl vl3,
  bom_departments bd
WHERE toh.header_id           = tol.header_id
AND toh.organization_id       = tol.organization_id
AND tol.line_id               = mmt.move_order_line_id
AND tol.organization_id       = 85
AND vl.lookup_type            = 'MTL_TXN_REQUEST_STATUS'
AND vl.lookup_code            = tol.line_status
AND vl2.lookup_type           = 'MOVE_ORDER_TYPE'
AND vl2.lookup_code           = toh.move_order_type
AND mmt.transaction_type_id   = mtt.transaction_type_id
AND usr.user_id               = toh.created_by
AND mmt.organization_id       = 85
AND mmt.organization_id       = tol.organization_id
AND mmt.department_id         = bd.department_id(+)
AND mmt.organization_id       = wdj.organization_id(+)
AND mmt.TRANSACTION_SOURCE_ID = wdj.wip_entity_id(+)
AND vl3.lookup_type           = 'INV_RESERVATION_SOURCE_TYPES'
and usr.user_Name = 'JITAUTO'
AND vl3.lookup_code           = mmt.TRANSACTION_SOURCE_TYPE_ID
and mmt.transaction_date between apps.xxbim_get_calendar_date('BIM',sysdate,-1) and trunc(sysdate)
and wdj.attribute5 is not null
--and round((mmt.creation_date - toh.creation_date)*24,0)>5
group by toh.request_number 
,toh.creation_date ,greatest(0,round((mmt.transaction_date - case when apps.xxbim_get_working_days(85,toh.creation_date,mmt.transaction_date) >1 then toh.creation_date + 8/24 else toh.creation_date end)*24,0)-5) 
,bd.department_code  
,mmt.transaction_date