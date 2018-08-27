select * from (
select item							
, round(least(to_move, cmp_inv,ATR/2),0) qty_to_move	
,ppg_inv						
, percent percent_ppg							
, the_count/5 daily_picks							
, decode(							
	(						
		select itema from					
			(				
				select distinct msi.segment1 itema			
				from mtl_txn_request_headers toh			
				, mtl_txn_request_lines tol			
				, mtl_material_transactions_temp mmtt			
				, mtl_system_items_b msi			
				, wip_discrete_jobs_v wdj			
				where toh.header_id             = tol.header_id			
					and toh.organization_id        = tol.organization_id		
					and tol.line_id                = mmtt.move_order_line_id		
					and mmtt.organization_id       = 85		
					and mmtt.organization_id       = msi.organization_id		
					and mmtt.organization_id       = tol.organization_id		
					and tol.inventory_item_id      = msi.inventory_item_id		
					and mmtt.organization_id       = wdj.organization_id(+)		
					and mmtt.transaction_source_id = wdj.wip_entity_id(+)		
					and 'PPG HR' in nvl(mmtt.transfer_subinventory, 'asdf')		
					and tol.line_status in (3,7)		
				union all			
				select msi.segment1			
				from mtl_txn_request_lines mtl			
				, mtl_txn_request_headers mth			
				, mtl_system_items_b msi			
				where 1                    =1			
					and mtl.header_id         = mth.header_id		
					and mtl.organization_id   = mth.organization_id		
					and mtl.inventory_item_id = msi.inventory_item_id		
					and mtl.organization_id   = msi.organization_id		
					and mth.organization_id   = 85		
					and quantity_detailed     = 0		
					and mtl.line_status       = 3		
					and 'PPG HR'             in nvl(mtl.to_subinventory_code,'asdf')		
					and mtl.line_id not      in		
					(		
						select move_order_line_id	
						from mtl_material_transactions_temp	
						where organization_id = mtl.organization_id	
					)		
			)				
			where itema = item				
	)						
	,null,'No','Yes') open_mo					
	,atr
from							
	(						
		select item					
		, inventory_item_id					
		, the_count					
		, round(sum(the_count) over (order by the_count desc, item)/sum(the_count) over (),2) percent					
		, case					
				when round(eau*2/10,1)*10 = 0			
				then round(eau,0)			
				else round(eau*2/10,1)*10			
			end to_move				
		, eau					
		, xxbim_get_quantity(v.inventory_item_id, 85, 'ATR', 'CMP HR') cmp_inv	
		, xxbim_get_quantity(v.inventory_item_id, 85, 'ATR', 'CMP HR') - (select sum(wro.required_quantity - nvl(wro.quantity_issued,0))

from wip_discrete_jobs_v we
, wip_requirement_operations wro
, mtl_system_items_b msi
, mtl_system_items_b msip
where we.organization_id  = 85
	and msip.organization_id = we.organization_id
	and wro.organization_id  = we.organization_id
	and msi.organization_id  = we.organization_id
	and we.wip_entity_id       = wro.wip_entity_id
	and wro.inventory_item_id  = msi.inventory_item_id
	and msip.inventory_item_id = we.primary_item_id
    and msi.inventory_item_id = v.inventory_item_id
	and wro.wip_supply_type in( '1')
	and we.status_type_disp in ('Released', 'Unreleased', 'On Hold')
    and (select distinct count(1) from wip_discrete_jobs_v where line_code = 'JIT' and project_id = we.project_id and status_type_disp in( 'Released','Complete') )is not null
group by msi.inventory_item_id) atr
		, (					
				select sum(primary_transaction_quantity) on_hand_qty			
				from mtl_onhand_quantities_detail moqd			
				where organization_id  = 85			
					and subinventory_code = 'PPG HR'		
					and inventory_item_id = v.inventory_item_id		
				group by moqd.inventory_item_id			
			)				
			ppg_inv				
		from					
			(				
				select			
					msi.segment1 item
							
				, mmt.inventory_item_id			
				,(			
						select attribute7	
						from mtl_system_items_b	
						where organization_id  = 85	
							and inventory_item_id = mmt.inventory_item_id
					)		
					eau		
					--, subinventory_code		
				, count(1) the_count			
				from mtl_material_transactions mmt	
                , mtl_system_items_b msi
                , MTL_ITEM_CATEGORIES_V cat
				where mmt.organization_id = 85			
                and msi.inventory_item_Id = mmt.inventory_item_id
                and msi.organization_id = mmt.organization_id
					and transaction_date     > apps.xxbim_get_calendar_date(85, sysdate, -90)		
					and transaction_type_id                                             in (35)		
					and subinventory_code                                               in ('CMP HR', 'PPG HR')	
                    and msi.organization_id = cat.organization_id(+)
and nvl(msi.attribute5,'a')not like 'BIF%'
                            and cat.structure_id(+) = '50415'
                            and msi.inventory_item_id = cat.inventory_item_id(+)
                            and nvl(category_concat_segs,'Special') <> 'Special'
                              and (select distinct 1
from mtl_material_transactions mmt
where mmt.organization_id = 85
	and transaction_date     > apps.xxbim_get_calendar_date('BIM',sysdate, -3)
	and transaction_type_id in (2,41)
    and primary_quantity > 0
and subinventory_code = 'CMP HR'
and inventory_item_id = msi.inventory_item_id) is null
                     and msi.wip_supply_type = 1	
				group by mmt.inventory_item_id,msi.segment1			
					--order by 5 desc		
			)				
			v				
		--where item <> 'D-54994'			
		group by item					
		,inventory_item_id					
		, the_count					
		, eau					
		order by the_count desc	)						
where percent      <= .51							
	and nvl(ppg_inv,0) < eau/2						
	and cmp_inv       is not null						
	and least(to_move, cmp_inv, ATR/2) > 10						
) where open_mo = 'No'