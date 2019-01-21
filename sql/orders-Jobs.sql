select decode(msi.organization_id, 85, 'BIM', 90, 'BMX') "Org"
, project_name "Project"
, wip_entity_name "Job"
, msi.segment1 "Item"
, substr(msi.description,0,20) "Description"
, status_type_disp "Status"
, wdj.attribute1
	||'.'
	|| wdj.attribute2
	||'.'
	|| wdj.attribute3 "DFF"
, line_code "Line"
, decode(nvl(to_char(demand_source_header_id), 'None'), 'None', 'None', 'Yes') "Sales Order"
, start_quantity "Start QTY"
, to_number(quantity_remaining) "Open QTY"
, wdj.creation_date "Date Created"
 , decode(decode(wdj.status_type_disp,'Released','1','Unreleased','1','On Hold','1','0'),'1', nvl((select
    max((
        select
            min(old_schedule_date)
        from
            msc_supplies ord, msc.msc_system_items msc
        where
            ord.organization_id = 85
            and order_type in(
                1, 2, 3
            ) --1:po, 2:purchase req, 3:wo, 4:null, 5:plannedOrder
            and item_name = msi2.segment1
            and ord.plan_id = msc.plan_id
            and msc.plan_id = 21
            and ord.organization_id = msc.organization_id
            and ord.inventory_item_id = msc.inventory_item_id
            --and old_schedule_date > apps.xxbim_get_calendar_date('BIM', sysdate, - 5)
    )) supply_date
from
    wip_requirement_operations wro,
    mtl_system_items_b msi2,
    mfg_lookups wip_supply
where
    1 = 1
    and wro.wip_entity_id = wdj.wip_entity_id
    and wro.organization_id = wdj.organization_id
    and wro.inventory_item_id = msi2.inventory_item_id
    and wro.organization_id = msi2.organization_id
    and wro.attribute2 is not null
    and wro.attribute2 not like '0%'
    and wro.wip_supply_type = wip_supply.lookup_code
    and wip_supply.lookup_type = 'WIP_SUPPLY'
    ), scheduled_start_date),null) "Planned Start Date"
, scheduled_start_date "Schedule Start"
, scheduled_completion_date "Schedule Completion"
, date_released "Released"
, nvl((select cat.category_concat_segs
from  mtl_item_categories_v cat
where cat.organization_id = wdj.organization_Id
	and cat.structure_id    = '50415'
	and cat.inventory_item_id = wdj.primary_item_Id), 'Special') "Category"
, completion_subinventory "Completion Subinv"
, inv_project.get_pjm_locsegs(b.concatenated_segments) "Locator"
, schedule_group_name "Schedule Group"
, ml.meaning "Exception Type"
, ml2.meaning "Exception Status"
, comp.segment1 "Exception Item"
, we.note "Exception Note"
from wip_discrete_jobs_v wdj
, apps.mtl_item_locations_kfv b
, mtl_system_items_b msi
, mtl_reservations mr
, wip_exceptions we
, mtl_system_items_b comp
, mfg_lookups ml2
, (
		select lookup_code
		, meaning
		from mfg_lookups
		where enabled_flag                    = 'Y'
			and nvl(start_date_active, sysdate) <= sysdate
			and nvl(end_date_active, sysdate)   >= sysdate
			and lookup_type                      = 'WIP_EXCEPTION_TYPE'
	)
	ml
where wdj.organization_id     in ( 85, 90)
	and status_type_disp         in ('Released', 'Unreleased', 'On Hold')
	and wdj.organization_id       = b.organization_id(+)
	and wdj.completion_locator_id = b.inventory_location_id(+)
	and wdj.organization_id       = msi.organization_id
	and wdj.primary_item_id       = msi.inventory_item_id
	and wdj.wip_entity_id         = mr.supply_source_header_id(+)
	and wdj.wip_entity_id         = we.wip_entity_id(+)
	and wdj.organization_id       = we.organization_id(+)
	and we.component_item_id      = comp.inventory_item_id(+)
	and we.organization_id        = comp.organization_id(+)
	and we.exception_type         = ml.lookup_code(+)
	and ml2.lookup_type(+)        = 'WIP_EXCEPTION_STATUS'
	and we.status_type            = ml2.lookup_code(+)
order by scheduled_completion_date asc