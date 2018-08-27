SELECT
    cycle_count_header_name "Cycle Count",
    (
        SELECT
            segment1
        FROM
            mtl_system_items_b
        WHERE
            organization_id = 85
            AND inventory_item_id = cce.inventory_item_id
    ) "Item",
    abc.abc_class_name "Class",
    cce.subinventory "Subinventory",
    (
        SELECT
            inv_project.get_pjm_locsegs(b.concatenated_segments)
        FROM
            mtl_item_locations_kfv b
        WHERE
            cce.organization_id = b.organization_id
            AND cce.locator_id = b.inventory_location_id
    ) "Locator",
    cce.system_quantity_first "System Qty",
    ( cce.count_quantity_first - cce.system_quantity_first ) "Adjust Qty",
    adjustment_amount,
    (
        SELECT
            COUNT(1)
        FROM
            wip_discrete_jobs_v we,
            wip_requirement_operations wro
        WHERE
            1 = 1
            AND wro.organization_id = we.organization_id
            AND cce.organization_id = we.organization_id
            AND we.attribute2 = '1'
            AND substr(wro.attribute2,0,1) = '1'
            AND we.wip_entity_id = wro.wip_entity_id
            AND wro.inventory_item_id = cce.inventory_item_id
            AND we.status_type IN (
                1,
                6
            )
    ) orders_missing_part
FROM
    mtl_abc_classes abc,
    mtl_cycle_count_classes cla,
    mtl_cycle_count_headers cch,
    mtl_cycle_count_items cci,
    mtl_cycle_count_entries cce
WHERE
    cch.organization_id = 85--:P_ORG_ID
    AND cce.organization_id = 85--:P_ORG_ID
    AND cce.inventory_item_id = cci.inventory_item_id
    AND cci.abc_class_id = abc.abc_class_id
    AND cci.abc_class_id = cla.abc_class_id
    AND cla.cycle_count_header_id = cch.cycle_count_header_id --:P_HeaderId
    AND cla.organization_id = 85                        --:P_Org_Id
    AND abc.organization_id = 85                        --:P_Org_id
    AND cci.cycle_count_header_id = cch.cycle_count_header_id --:P_HeaderID
			--AND   cch.cycle_count_header_id = 7003--:P_HeaderID
    AND cce.cycle_count_header_id = cch.cycle_count_header_id--:P_HeaderID
    AND (
        cce.entry_status_code = 5
        OR cce.entry_status_code = 2 -- pending approval
        --OR cce.entry_status_code = 3 -- recount
    )
    AND cce.count_type_code <> 4
			--and cch.cycle_count_header_name in ( 'PPG HR', 'CMP HR')
			/* and   TO_DATE(CCE.count_date_first,'DD-MON-RRRR') <=  to_date(:P_ToDate, 'DD-MON-RRRR')
			and   TO_DATE(CCE.count_date_first,'DD-MON-RRRR')>=  to_date(:P_FromDate, 'DD-MON-RRRR')*/
--			and trunc(cce.count_date_first, 'WW') = trunc(trunc(sysdate, 'WW')-1,'WW')--'18-SEP-2017'
    AND trunc(cce.count_date_first) BETWEEN apps.xxbim_get_calendar_date('BIM',SYSDATE,-1) AND trunc(SYSDATE)

			--and   TRUNC(CCE.count_date_first) >=  '18-SEP-2017'
ORDER BY
    9 DESC,
    abs(adjustment_amount) DESC