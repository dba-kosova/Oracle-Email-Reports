SELECT
    ord.item_segments,
    round(ord.quantity,2) quantity,
    order_type_text,
    supplier_name,
    buyer_name,
    ord.old_due_date,
     APPS.XXBIM_GET_WORKING_DAYS(85, ord.old_due_date, sysdate) "Days Late",
    (
        SELECT
            COUNT(1)
        FROM
            wip_discrete_jobs_v we,
            wip_requirement_operations wro,
            mtl_system_items_b msi
        WHERE
            we.organization_id = 85
            AND wro.organization_id = we.organization_id
            AND msi.organization_id = we.organization_id
            AND we.attribute2 = '1'
            AND substr(wro.attribute2,0,1) = '1'
            AND msi.segment1 = item_segments
            AND we.wip_entity_id = wro.wip_entity_id
            AND wro.inventory_item_id = msi.inventory_item_id
    --and wro.wip_supply_type in( '1')
    --  and we.status_type_disp in 'Unreleased', 'On Hold')
            AND we.status_type IN (
                1,
                6
            )
    ) orders_affected
    
FROM
    msc_orders_v ord
WHERE
    ord.organization_code = 'BIM:BIM'
    AND ord.compile_designator = 'BIM'
    AND ord.order_type = 1
 -- AND ord.item_segments = 'D-6668-P'
    AND category_id IN (
        SELECT
            category_id
        FROM
            mtl_item_categories_v
        WHERE
            category_set_id = 1
    )
    --AND ROWNUM < 10
    AND trunc(old_due_date) < trunc(SYSDATE)
    order by 8 desc, old_due_date asc