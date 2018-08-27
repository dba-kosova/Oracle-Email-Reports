select exception_type_text "Exception"
, order_number "Job"
, order_type "Type"
, iteM_segments "Item"
, item_description "Description"
, quantity "Quantity"
, planner_code "Planner"
, from_date "From Date"
, to_date "To Date"
, due_date "Due Date"
, end_item_segments "End Item"
, old_due_date "Old Due Date"
, days_late "Days Late"
, firm_type "Firm"
, round(reschedule_in_days,0) "Reschedule In Days"
, round(reschedule_out_days,0) "Reschedule Out Days"
 from APPS.MSC_EXCEPTION_DETAILS_V
where organization_id = 85
and category_set_id = 1014
and plan_id = 21
and planner_Code in ('MWS','P01','P02','P26','P28','P29','P30')
and order_type in ('Purchase order', 'Planned Order') 
and exception_type  not in ( 5,9,19, 7) -- 7 is reschedule out
order by exception_type