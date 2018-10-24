SELECT DISTINCT
    wdj.line_code "Line",
    wdj.project_name "Project",
    wdj.wip_entity_name "Job",
    wdj.attribute1||'.'||wdj.attribute2||'.'||wdj.attribute3 "DFF",
    wdj.date_released "Date Released",
    msi.segment1 "Assembly",
    exception_item.segment1 "Exception",
    xxbim_get_quantity(exception_item.inventory_item_id,exception_item.organization_id,'ATR') "Qty ATR",
    (
        SELECT
            SUM(wro.required_quantity - quantity_issued) sum_open_qty
        FROM
            wip_requirement_operations wro,
            wip_discrete_jobs w
        WHERE
            1 = 1
            AND   wro.wip_entity_id = w.wip_entity_id
            AND   wro.inventory_item_id = exception_item.inventory_item_id
            AND   w.organization_id = exception_item.organization_id
            AND   w.status_type IN (3,6)
        GROUP BY
            wro.inventory_item_id,
            w.organization_id
    ) "Released Jobs Qty"
FROM
    wip_discrete_jobs_v wdj,
    mtl_system_items_b msi,
    (
        SELECT
            comp.segment1,
            comp.inventory_item_id,
            comp.organization_id,
            wip_entity_id
        FROM
            wip_exceptions we,
            mtl_system_items_b comp,
            mfg_lookups ml2
        WHERE
            1 = 1
            AND   we.component_item_id = comp.inventory_item_id
            AND   we.organization_id = comp.organization_id
            AND   ml2.lookup_type (+) = 'WIP_EXCEPTION_STATUS'
            AND   we.status_type = ml2.lookup_code (+)
            AND   (
                ml2.meaning = 'Open'
                OR    ( ml2.meaning = 'Resolved' )
            )
    ) exception_item
WHERE
    1 = 1
    AND   wdj.organization_id = exception_item.organization_id (+)
    AND   wdj.wip_entity_id = exception_item.wip_entity_id (+)
    AND   wdj.primary_item_id = msi.inventory_item_id
    AND   wdj.attribute3 = 0
    AND   wdj.status_type_disp = 'On Hold'
        and nvl(wdj.attribute9,'asdf') <> 'QA JIT Hold'

    --AND   xxbim_get_quantity(exception_item.inventory_item_id,exception_item.organization_id,'ATR') > 0
ORDER BY
    exception_item.segment1,
    line_code,
    project_name