-- open move orders
select 

toh.request_number MO,round((sysdate - case when apps.xxbim_get_working_days(85,toh.creation_date,sysdate) >1 then toh.creation_date + 8/24 else toh.creation_date end)*24,0)-5 hours_past_goal,
  
  wdj.line_code Line 

,toh.creation_date
from mtl_txn_request_headers toh
, mtl_txn_request_lines tol
, mtl_material_transactions_temp mmtt
, fnd_lookup_values_vl vl
, fnd_lookup_values_vl vl2
, fnd_lookup_values_vl vl3
, mtl_transaction_types mtt
, apps.fnd_user usr
, mtl_system_items_b msi
, apps.mtl_item_locations_kfv b
, wip_discrete_jobs_v wdj
where toh.header_id             = tol.header_id
  and vl.lookup_type             = 'MTL_TXN_REQUEST_STATUS'
  and vl.lookup_code             = tol.line_status
  and toh.organization_id        = tol.organization_id
  and tol.line_id                = mmtt.move_order_line_id
  and vl2.lookup_type            = 'MOVE_ORDER_TYPE'
  and vl2.lookup_code            = toh.move_order_type
  and vl3.lookup_type            = 'INV_RESERVATION_SOURCE_TYPES'
  and vl3.lookup_code            = mmtt.transaction_source_type_id
  and mmtt.transaction_type_id   = mtt.transaction_type_id
  and usr.user_id                = toh.created_by
  and mmtt.organization_id       = 85
  and usr.user_Name = 'JITAUTO'
  and mmtt.organization_id       = msi.organization_id
  and mmtt.organization_id       = tol.organization_id
  and tol.inventory_item_id      = msi.inventory_item_id
  and mmtt.organization_id       = b.organization_id(+)
  and mmtt.locator_id            = b.inventory_location_id(+)
  and mmtt.organization_id       = wdj.organization_id(+)
  and mmtt.transaction_source_id = wdj.wip_entity_id(+)
  and toh.last_update_date between APPS.XXBIM_GET_CALENDAR_DATE('BIM',sysdate,-1) and trunc(sysdate)
and wdj.attribute5 is not null
and round((sysdate - case when apps.xxbim_get_working_days(85,toh.creation_date,sysdate) >1 then toh.creation_date + 8/24 else toh.creation_date end)*24,0)>5
group by toh.request_number ,round((sysdate - case when apps.xxbim_get_working_days(85,toh.creation_date,sysdate) >1 then toh.creation_date + 8/24 else toh.creation_date end)*24,0)-5 ,
  
  wdj.line_code  

,toh.creation_date
