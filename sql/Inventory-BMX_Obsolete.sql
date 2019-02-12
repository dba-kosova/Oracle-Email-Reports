select
    msi.segment1     "Item",
    description      "Description",
    msi.attribute7   "Monthly Usage (12 mo)",
    decode(nvl((
        select
            item_name
        from
            msc_demands md, apps.msc_system_items_v msc
        where
            md.plan_id = msc.plan_id
            and md.inventory_item_id = msc.inventory_item_id
            and md.organization_id = 85
            and md.organization_id = msc.organization_id
            and md.plan_id = 21
            and msc.sr_inventory_item_id = msi.inventory_item_id
        group by
            item_name
    ),'No'),'No','No','Yes') "BIM Demands",
    decode(nvl((
        select
            item_name
        from
            msc_demands md, apps.msc_system_items_v msc
        where
            md.plan_id = msc.plan_id
            and md.inventory_item_id = msc.inventory_item_id
            and md.organization_id = 90
            and md.organization_id = msc.organization_id
            and md.plan_id = 21
            and msc.sr_inventory_item_id = msi.inventory_item_id
        group by
            item_name
    ),'No'),'No','No','Yes') "BMX Demands",

    nvl(obs_cat.category_concat_segs, 'No')  "Obs Exception",  
    item_type        "Item Type",
    planner_code     "Planner",
    nvl(cat.category_concat_segs,'Special') "Std/Spc"
    ,on_hand_qty      "On Hand",
    (
        select
            transaction_date
        from
            (
                select
                    transaction_date,
                    inventory_item_id
                from
                    mtl_material_transactions mmt
                where
                    mmt.organization_id = 90
                    and transaction_type_id = 35
                order by
                    transaction_date desc
            )
        where
            inventory_item_id = msi.inventory_item_id
            and rownum = 1
    ) "Last Used",
    (
        select
            transaction_date
        from
            (
                select
                    transaction_date,
                    inventory_item_id
                from
                    mtl_material_transactions mmt
                where
                    mmt.organization_id = 90
                    and transaction_type_id in (
                        18,
                        44
                    )
                order by
                    transaction_date desc
            )
        where
            inventory_item_id = msi.inventory_item_id
            and rownum = 1
    ) "Date Recieved",
    item_cost        "Cost",
    nvl(on_hand_qty * nvl(item_cost, 0), 0) "Total Cost",
    nvl(( 
        select sum(abs(mmt.transaction_quantity))
        from
            mtl_material_transactions mmt
        where
            mmt.transaction_type_id in (
                35,
                33
            ) -- SO issue and WIP issue
            and trunc(mmt.transaction_date) between add_months(apps.xxbim_get_calendar_date('BIM', sysdate, - 1), - 6) and apps.xxbim_get_calendar_date
            ('BIM', sysdate, - 1)
            and inventory_item_id = msi.inventory_item_id
        
    ),0)  "Transaction Qty (6mo)",
        nvl(( 
        select sum(abs(mmt.transaction_quantity))
        from
            mtl_material_transactions mmt
        where
            mmt.transaction_type_id in (
                35,
                33
            ) -- SO issue and WIP issue
            and trunc(mmt.transaction_date) between add_months(apps.xxbim_get_calendar_date('BIM', sysdate, - 1), - 12) and apps.xxbim_get_calendar_date
            ('BIM', sysdate, - 1)
            and inventory_item_id = msi.inventory_item_id
        
    ),0)  "Transaction Qty (12mo)",
    nvl((
        select
            safety_stock_quantity
        from
            (
                select
                    inventory_item_id, effectivity_date, safety_stock_quantity
                from
                    mtl_safety_stocks
                where
                    organization_id = 90
                order by
                    effectivity_date desc
            )
        where
            rownum = 1
            and inventory_item_id = msi.inventory_item_id
    ), 0) "Safety Stock",
    to_char(msi.creation_date, 'MM/DD/YY') "Creation Date"
from
    mtl_system_items_b msi,
    cst_item_costs cic,
    (
        select
            sum(primary_transaction_quantity) on_hand_qty,
            inventory_item_id,
            organization_id
        from
            mtl_onhand_quantities_detail
        group by
            inventory_item_id,
            organization_id
    ) moqd,
    mtl_item_categories_v obs_cat,
    mtl_item_categories_v cat
where
    msi.inventory_item_id = moqd.inventory_item_id
    and msi.organization_id = moqd.organization_id
    and msi.inventory_item_id = cic.inventory_item_id (+)
    and msi.organization_id = cic.organization_id (+)
    and cic.cost_type_id (+) = 1
    and msi.organization_id = 90
    and item_type <> 'TOOL'
    and planner_code not in (
        'TOL',
        'TPK'
    )
    
    and msi.organization_id = obs_cat.organization_id(+) 
    and obs_cat.category_set_id (+) = '1100000161'
    and msi.inventory_item_id = obs_cat.inventory_item_id(+) 
    and obs_cat.category_id(+) = 7518
    
    and msi.organization_id = cat.organization_id(+)
    and cat.category_set_id(+)  = '1100000101'
    and cat.category_id(+) = 7493
    and msi.inventory_item_id = cat.inventory_item_id(+)
    
   