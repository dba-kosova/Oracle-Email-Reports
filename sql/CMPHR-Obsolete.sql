select item, on_hand from (


select msi.segment1 Item
, decode(demands_bim.item_name,null,'No','Yes') BIM_Demands
, decode(demands_bmx.item_name,null,'No','Yes') BMX_Demands
, nvl(obs_cat.category_concat_segs,'No') Obs_Exception
, description 
, item_type Item_Type
, planner_code Planner
, nvl(cat.category_concat_segs,'Special') Std_Spc
, case
		when cat.category_concat_segs = 'Standard'
		then nvl(ss_cat.category_concat_segs,'Low')
		else ss_cat.category_concat_segs
	end "SS Priority"
	-- , msi.inventory_item_id
	-- , msi.organization_id
, on_hand_qty On_Hand
, date_received Date_Recieved
, item_cost Cost
, nvl (on_hand_qty * nvl (item_cost, 0), 0) Total_Cost
, nvl(v_trx_qty,0) "Transaction Qty (1yrs)"
--, round(months_between (apps.xxbim_get_calendar_date('BIM',sysdate,-1), add_months(apps.xxbim_get_calendar_date('BIM',sysdate,-1),-12*36)),1) months
, decode(nvl(v_trx_qty,0),0,0,round (abs (trx.v_trx_qty)           / round (months_between (apps.xxbim_get_calendar_date('BIM',sysdate,-1), add_months(apps.xxbim_get_calendar_date('BIM',sysdate,-1),-12)), 1), 2)) Act_Usage
, (nvl(msi.attribute7,0) + nvl((select attribute7 from mtl_system_items_b where organization_id = 90 and inventory_item_id = msi.inventory_item_id),0)) Mfg_Usage

from mtl_system_items_b msi
, cst_item_costs cic
, (
		select sum(primary_transaction_quantity) on_hand_qty
		, max(date_received) date_received
		, inventory_item_id
		, organization_id
		from mtl_onhand_quantities_detail
		group by inventory_item_id
		, organization_id
	)
	moqd
, (
		select sum (abs (mmt.transaction_quantity)) v_trx_qty
		, round (months_between (apps.xxbim_get_calendar_date('BIM',sysdate,-1), add_months(apps.xxbim_get_calendar_date('BIM',sysdate,-1),-12)), 1) v_months
		, inventory_item_id
		from mtl_material_transactions mmt
		where mmt.transaction_type_id                                                                  in (35, 33) -- SO issue and WIP issue
			and trunc (mmt.transaction_date) between add_months(apps.xxbim_get_calendar_date('BIM',sysdate,-1),-12) and apps.xxbim_get_calendar_date('BIM',sysdate,-1)
		group by  inventory_item_id
	)
	trx
, mtl_item_categories_v cat
, mtl_item_categories_v ss_cat
, mtl_item_categories_v obs_cat
, (
		select item_name
		, msc.sr_inventory_item_id inventory_item_id
		from msc_demands md
		, apps.msc_system_items_v msc
		where md.plan_id          = msc.plan_id
			and md.inventory_item_id = msc.inventory_item_id
			and md.organization_id   in ( 85)
			and md.organization_id   = msc.organization_id
			and md.plan_id           = 21
		group by item_name
		,msc.sr_inventory_item_id
	)
	demands_bim
	, (
		select item_name
		, msc.sr_inventory_item_id inventory_item_id
		from msc_demands md
		, apps.msc_system_items_v msc
		where md.plan_id          = msc.plan_id
			and md.inventory_item_id = msc.inventory_item_id
			and md.organization_id   in ( 90)
			and md.organization_id   = msc.organization_id
			and md.plan_id           = 21
		group by item_name
		,msc.sr_inventory_item_id
	)
	demands_bmx
where msi.inventory_item_id    = moqd.inventory_item_id
	and msi.organization_id       = moqd.organization_id
	and msi.inventory_item_id     = cic.inventory_item_id(+)
	and msi.organization_id       = cic.organization_id(+)
	and msi.inventory_item_id     = trx.inventory_item_id(+)
	--and msi.organization_id       = trx.organization_id(+)
	and cic.cost_type_id(+)       = 1
	and msi.organization_id       = 85
	and item_type not            in ('TOOL')
	and msi.organization_id       = cat.organization_id(+)
	and cat.category_set_id(+)    = '1100000101'
	and msi.inventory_item_id     = cat.inventory_item_id(+)
	and msi.organization_id       = obs_cat.organization_id(+)
	and obs_cat.category_set_id(+)    = '1100000161'
	and msi.inventory_item_id     = obs_cat.inventory_item_id(+)
	and ss_cat.category_set_id(+) = '1100000121'
	and msi.inventory_item_id     = ss_cat.inventory_item_id(+)
	and msi.organization_id       = ss_cat.organization_id(+)
	and msi.inventory_item_id     = demands_bmx.inventory_item_id(+)
	and msi.inventory_item_id     = demands_bim.inventory_item_id(+)
	--and msi.segment1           = '011-DPNEE0.7'

)
where bim_demands = 'No'
and bmx_demands = 'No'
and obs_exception = 'No'
and std_spc = 'Special'
and planner in ('NJIT','JIT', 'P01','P26')
and act_usage=0
and date_recieved < trunc(sysdate-180)
order by date_recieved asc