select material "Material"
      ,material_quantity "Quantity"
      ,description "Description"
      ,dnumber "D Number"
      ,ddesc "Description"
      ,machine "Machine"
      ,job "Job"
      ,project "Project"
      ,quantity "Quantity"
      ,line "Line"
      ,top_line "Top Line"
      ,released "Released"
      ,due_date "Due"
      ,top_job "Top Job"
      ,bore "Bore"
      ,department "Dept"
      ,jit_jobs "Jit Jobs"
from (
    select msic.segment1 material
          ,decode(msic.segment1,'MS-1020','S205A','MS-1022','MIYANO','MS-1023','S205A','MS-1027','MIYANO','MS-1028','S205B','MS-1030','MIYANO'
,'MS-1031','BS20','MS-1034','SX25','MS-1036','M08','MS-1044','TS16','MS-1045','S205A','MS-1046','S205A','MS-1047','SX20','MS-1048'
,'S205B','MS-1049','BS20','MS-1050','SX25','MS-1051','M08','MS-1084','M08','MS-1090','MIYANO','MS-1091','MIYANO','MS-1093','MIYANO'
,'MS-1209','MIYANO','MS-1211','S205B','MS-1212','BS20','MS-1229','CITIZEN','MS-1375','CITIZEN','MS-1384','SX25','MS-1496','M08','MS-1556'
,'M08','MS-1573','SX20','MS-1580','BS20','MS-1714','TORNADO','MS-1776','CITIZEN','MS-1837','TS16','MS-1981','SHEAR/SAW','MS-1991'
,'SHEAR/SAW','MS-2039','RACK SAW','MS-2040','RACK SAW','MS-2041','RACK SAW','MS-2042','RACK SAW','MS-2062','RACK SAW','MS-2094-A'
,'TRACK SAW FO','MS-2095-A','TRACK SAW FO','MS-2146-A','TRACK SAW FO','MS-2239-A','OMNITURN','MS-2296','S205B','MS-2300','S205B',
'MS-2314-A','OMNITURN','MS-2315-A','OMNITURN','MS-2327','SHEAR/SAW','MS-2338','SX20','MS-2372','BS20','MS-2374','M08','MS-2375','BS32'
,'MS-2457','BS20','MS-2500','SHEAR/SAW','MS-2501','SHEAR/SAW','MS-2502','SHEAR/SAW','MS-2503','SHEAR/SAW','MS-2515','TRACK SAW FO'
,'MS-2543','M08','MS-2615','STAR','MS-2616','STAR','MS-2617','CITIZEN','MS-2618','CITIZEN','MS-2619','SX25','MS-2620','TORNADO','MS-2621'
,'CITIZEN','MS-2670','MIYANO','MS-2671','MIYANO','MS-2672','MIYANO','MS-2673','MIYANO','MS-2674','MIYANO','MS-2691','TORNADO','MS-2729'
,'CITIZEN','MS-2730','CITIZEN','MS-2751','CITIZEN','MS-2752','CITIZEN','MS-2753','CITIZEN','MS-2754','STAR','MS-2756-A','TSUGAMI POST'
,'MS-2757-A','TSUGAMI POST','MS-2758-A','TSUGAMI POST','MS-2759-A','TSUGAMI POST','MS-2770','S205B','MS-2797','STAR','MS-2798','STAR'
,'MS-2799','STAR','MS-2800','CITIZEN','MS-2900','STAR','MS-2901','STAR','MS-2902','STAR','MS-2903','CITIZEN','MS-2904','CITIZEN',
'MS-2926','SHEAR SAW','MS-2927','SHEAR SAW','MS-2934','STAR','MS-2959','CITIZEN','MS-2990','TORNADO','MS-2992','TORNADO','MS-3008'
,'S205A','MS-3092','BS20','MS-3094','S205A','MS-3236','CITIZEN','MS-3237','CITIZEN','MS-3238','CITIZEN','MS-3496','SX20','MS-3620'
,'SPECIAL','MS-3622','SPECIAL','MS-3624','M08','MS-3846-A','POST','MS-3903-A','POST','MS-3914','TRACK SAW FO','MS-3968','TRACK SAW FO'
,'MS-3970','TRACK SAW FO','MS-3971','TRACK SAW FO','MS-1008','Small Bore Lathe (A)','MS-1009','Small Bore Lathe (A)','MS-1018','Small Bore Lathe (A)'
,'MS-1239','Small Bore Lathe (A)','MS-1473','Small Bore Lathe (A)','MS-1757','Small Bore Lathe (A)','MS-1758','Small Bore Lathe (A)'
,'MS-1760','Small Bore Lathe (A)','MS-1761','Small Bore Lathe (A)','MS-1762','Small Bore Lathe (A)','MS-2167','Small Bore Lathe (A)'
,'MS-1476','Small Bore Lathe (A)','MS-3873-A','Small Bore Lathe (A)','MS-2025','Small Bore Lathe (A)','MS-1759','Small Bore Lathe (A)'
,'MS-1480','Small Bore Lathe (A)','MS-1006','Small Bore Lathe (B)','MS-1007','Small Bore Lathe (B)','MS-1474','Small Bore Lathe (B)'
,'MS-1478','Small Bore Lathe (B)','MS-1011','Small Bore Lathe (C)','MS-1482','Small Bore Lathe (C)','MS-2163','Small Bore Lathe (C)'
,'MS-1012','Large Bore Lathe (A)','MS-1014','Large Bore Lathe (A)','MS-1016','Large Bore Lathe (A)','MS-1486','Large Bore Lathe (A)'
,'MS-2162','Large Bore Lathe (A)','MS-1312','Large Bore Lathe (A)','MS-3876-A','Large Bore Lathe (A)','MS-3877-A','Large Bore Lathe (A)'
,'MS-3893-A','Large Bore Lathe (A)','MS-1013','Large Bore Lathe (B)','MS-1460','Large Bore Lathe (B)','MS-1465','Large Bore Lathe (B)'
,'MS-1466','Large Bore Lathe (B)','MS-1471','Large Bore Lathe (B)','MS-1492','Large Bore Lathe (B)','MS-1493','Large Bore Lathe (B)'
,'MS-2164','Large Bore Lathe (B)','MS-2165','Large Bore Lathe (B)','MS-2293','Large Bore Lathe (B)','MS-2294','Large Bore Lathe (B)'
,'MS-3895','Large Bore Lathe (B)','MS-3896','Large Bore Lathe (B)','Other') machine
          ,we.wip_entity_name job
          ,pjm.project_name project
          ,wdj.start_quantity - nvl(quantity_completed,0) quantity
          , (
        select max(line_code)
        from (
            select line_code
                  ,project_id
                  ,wip_entity_id
                  ,scheduled_start_date
            from wip_discrete_jobs wdj2
                ,wip_lines wl
            where wdj2.organization_id = 85
                  and wdj2.line_id = wl.line_id
                  and wdj2.organization_id = wl.organization_id
                  and line_code not like '%SUB%'
                  and line_code not in (
                'JIT'
               ,'THR'
               ,'NJIT'
               ,'CSD'
               ,'OSV'
            )
                  and status_type in (
                '1'
               ,'6'
               ,'3'
            ) -- unreleased, on hold
            group by line_code
                    ,project_id
                    ,wip_entity_id
                    ,scheduled_start_date
            order by scheduled_start_date asc
        )
        where project_id = wdj.project_id
    --group by line_code
    ) top_line
          ,case
            when date_released < apps.xxbim_get_calendar_date('BIM',sysdate,1) then 1
            else 2
        end
    late
          ,decode(priority_ms.inventory_item_id,null,2,1) priority_ms
          ,msi.description description
          ,decode(wdj.attribute4,10,1,40,1,30,1,20,2,3) shipment_priority
          ,to_char(date_released,'MM/DD/YY HH24:MI') released
          ,wro.quantity_per_assembly material_quantity
          , (
        select max(msic1.segment1)
        from mtl_system_items_b msic1
            ,wip_requirement_operations wro1
        where 1 = 1
              and wro1.organization_id = wdj.organization_id
              and wro1.wip_entity_id = we.wip_entity_id
              and wro1.wip_supply_type = 4
              and wro1.inventory_item_id = msic1.inventory_item_id
              and wro1.organization_id = msic1.organization_id
              and msic1.segment1 not like 'D-114642%'
              and msic1.segment1 not like 'MS%'
              and exists (
            select *
            from wip_operations wo1
            where 1 = 1
                  and wo1.organization_id = 85
          --and wo1.department_id   = departmentcode --bd departmentcode(select * from bom_departments)
                  and wo1.wip_entity_id = we.wip_entity_id
        )
    ) dnumber
          , (
        select max(msic1.description)
        from mtl_system_items_b msic1
            ,wip_requirement_operations wro1
        where 1 = 1
              and wro1.organization_id = wdj.organization_id
              and wro1.wip_entity_id = we.wip_entity_id
              and wro1.wip_supply_type = 4
              and wro1.inventory_item_id = msic1.inventory_item_id
              and wro1.organization_id = msic1.organization_id
              and msic1.segment1 not like 'D-114642%'
              and msic1.segment1 not like 'MS%'
              and exists (
            select *
            from wip_operations wo1
            where 1 = 1
                  and wo1.organization_id = 85
          --and wo1.department_id   = departmentcode --bd departmentcode(select * from bom_departments)
                  and wo1.wip_entity_id = we.wip_entity_id
        )
    ) ddesc
          ,case
            when wdj.start_quantity - nvl(quantity_completed,0) > 20
                 and trunc(scheduled_start_date) > trunc(sysdate) then 1
            else 0
        end
    large_job_sort
          ,decode(line_id,13,'JIT',23,'NJIT') line
          , (
        select max(wip_entity_name)
        from (
            select wip_entity_name
                  ,line_code
                  ,project_id
                  ,we2.wip_entity_id
                  ,scheduled_start_date
                  ,status_type
            from wip_discrete_jobs wdj2
                ,wip_lines wl
                ,wip_entities we2
            where wdj2.organization_id = 85
                  and wdj2.line_id = wl.line_id
                  and wdj2.organization_id = wl.organization_id
                  and line_code not like '%SUB%'
                  and line_code not in (
                'JIT'
               ,'THR'
               ,'NJIT'
               ,'CSD'
               ,'OSV'
            )
                  and status_type in (
                '1'
               ,'6'
               ,'3'
            ) -- unre, on hold. R is 3
                  and wdj2.wip_entity_id = we2.wip_entity_id
          --and wdj2.project_id     = wdj.project_id
            group by line_code
           ,project_id
           ,we2.wip_entity_id
           ,scheduled_start_date
           ,wip_entity_name
           ,status_type
            order by status_type desc
                    ,scheduled_start_date asc
        )
        where project_id = wdj.project_id
              and rownum = 1
    ) top_job
          , (
        select count(distinct primary_item_id)
        from wip_discrete_jobs wdj2
            ,wip_lines wl
        where wdj2.organization_id = 85
              and wdj2.line_id = wl.line_id
              and wdj2.organization_id = wl.organization_id
              and line_code = 'JIT'
              and project_id = pjm.project_id
    ) jit_jobs
          ,substr( (
        select max(schedule_group_name)
        from(
            select(
                select schedule_group_name
                from wip_schedule_groups ws
                where ws.schedule_group_id = wdj2.schedule_group_id
                      and organization_id = wdj2.organization_id
            ) schedule_group_name,wip_entity_name,line_code,project_id,we2.wip_entity_id,scheduled_start_date,status_type
            from wip_discrete_jobs wdj2,wip_lines wl,wip_entities we2
            where wdj2.organization_id = 85
                  and wdj2.line_id = wl.line_id
                  and wdj2.organization_id = wl.organization_id
                  and line_code not like '%SUB%'
                  and line_code not in(
                'JIT','THR','NJIT','CSD','OSV'
            )
                  and status_type in(
                '1','6','3'
            ) -- unre, on hold. R is 3
                  and wdj2.wip_entity_id = we2.wip_entity_id
          --and wdj2.project_id     = wdj.project_id
            group by line_code,project_id,we2.wip_entity_id,scheduled_start_date,wip_entity_name,status_type,schedule_group_id,wdj2.organization_id
            order by status_type desc,scheduled_start_date asc
        )
        where project_id = wdj.project_id
              and rownum = 1
    ),0,4) bore
          , (
        select decode(push_parts,0,'No','Yes')
        from (
            select (
                select count(1)
                from wip_requirement_operations wro
                where 1 = 1
                      and wro.organization_id = wdj2.organization_id
                      and wro.wip_entity_id = we2.wip_entity_id
                      and wro.wip_supply_type = '1'
            ) push_parts
                  ,wip_entity_name
                  ,line_code
                  ,project_id
                  ,we2.wip_entity_id
                  ,scheduled_start_date
                  ,status_type
            from wip_discrete_jobs wdj2
                ,wip_lines wl
                ,wip_entities we2
            where wdj2.organization_id = 85
                  and wdj2.line_id = wl.line_id
                  and wdj2.organization_id = wl.organization_id
                  and line_code not like '%SUB%'
                  and line_code not in (
                'JIT'
               ,'THR'
               ,'NJIT'
               ,'CSD'
               ,'OSV'
            )
                  and status_type in (
                '1'
               ,'6'
               ,'3'
            ) -- unre, on hold. R is 3
                  and wdj2.wip_entity_id = we2.wip_entity_id
          --and wdj2.project_id     = wdj.project_id
            group by line_code
           ,project_id
           ,we2.wip_entity_id
           ,scheduled_start_date
           ,wip_entity_name
           ,status_type
           ,wdj2.organization_id
            order by status_type desc
                    ,scheduled_start_date asc
        )
        where project_id = wdj.project_id
              and rownum = 1
    ) push_parts
          ,decode(instr( (
        select max(msic1.description)
        from mtl_system_items_b msic1,wip_requirement_operations wro1
        where 1 = 1
              and wro1.organization_id = wdj.organization_id
              and wro1.wip_entity_id = we.wip_entity_id
              and wro1.wip_supply_type = 4
              and wro1.inventory_item_id = msic1.inventory_item_id
              and wro1.organization_id = msic1.organization_id
              and msic1.segment1 not like 'D-114642%'
              and msic1.segment1 not like 'MS%'
              and exists(
            select *
            from wip_operations wo1
            where 1 = 1
                  and wo1.organization_id = 85
          --and wo1.department_id   = departmentcode --bd departmentcode(select * from bom_departments)
                  and wo1.wip_entity_id = we.wip_entity_id
        )
    ),'F'),0,0,1) f_chamf
          , ( (
        select min(department_code)
        from wip_operations wo
            ,bom_departments bd
        where 1 = 1
              and wo.organization_id = 85
              and wo.department_id = bd.department_id
              and wip_entity_id = wdj.wip_entity_id
    ) ) department
          ,trunc(wdj.scheduled_completion_date) due_date
    from mtl_system_items_b msic
        ,wip_discrete_jobs wdj
        ,wip_requirement_operations wro
        ,wip_entities we
        ,mtl_system_items_b msi
        ,pjm.pjm_seiban_numbers pjm
        , (
        select wro.inventory_item_id
        from wip_discrete_jobs wdj
            ,wip_requirement_operations wro
        where wdj.organization_id = 85
              and wdj.wip_entity_id = wro.wip_entity_id
              and wdj.organization_id = wro.organization_id
              and wro.wip_supply_type in (
            1
           ,2
        )
              and wdj.status_type = 3
              and wdj.line_id in (
            13
           ,23
        )
              and wdj.attribute4 is not null
        group by wro.inventory_item_id
    ) priority_ms
    where wdj.organization_id = 85
          and wdj.organization_id = wro.organization_id
          and wdj.wip_entity_id = wro.wip_entity_id
          and wro.wip_supply_type in (
        1
       ,2
    )
          and wro.inventory_item_id = msic.inventory_item_id
          and wro.organization_id = msic.organization_id
          and wdj.status_type = 3       -- released
          and wdj.line_id in (
        13
       ,23
    ) -- JIT NJIT
          and wdj.organization_id = we.organization_id
          and wdj.wip_entity_id = we.wip_entity_id
          and wro.inventory_item_id = priority_ms.inventory_item_id (+)
          and exists (
        select *
        from wip_operations wo
        where 1 = 1
              and wo.organization_id = 85
      --and wo.department_id   = departmentcode --bd departmentcode (select * from bom_departments)
              and wip_entity_id = wdj.wip_entity_id
    )
          and wdj.organization_id = msi.organization_id
          and wdj.primary_item_id = msi.inventory_item_id
          and wdj.project_id = pjm.project_id
  /* jobs that are still in op 1 */
          and (
        select quantity_completed
        from wip_operations wo
        where wip_entity_id = wdj.wip_entity_id
              and rownum = 1
              and exists (
            select actual_completion_date
            from wip_operations
            where wip_entity_id = wo.wip_entity_id
                  and operation_seq_num = wo.operation_seq_num
        )
    ) = 0
    order by 14 asc
   ,6 asc
   ,7 asc
   ,1 asc
   ,9 asc
   ,20 asc
   ,12 asc
)