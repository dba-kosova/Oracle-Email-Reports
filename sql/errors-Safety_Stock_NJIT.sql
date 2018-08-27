select * from (
select part_number, planner_code, ssv,efd
, case when priority = 'Low' and max_eau > 0 then ceil(max_eau * full_lead_time/30.4/5)*5
			when priority = 'High' and max_eau > 0 then ceil(max_eau * lead_time/30.4/5)*5
			when priority = 'Manual' then 999999 else 0 end new_ssv

,max_eau

from 
(
select msi.segment1 part_number						
, msi.planner_code						
, msi.full_lead_time						
, msi.cumulative_total_lead_time lead_time						
, greatest(nvl(round(msi.attribute7,1),0), nvl(round(abs(						
	(					
		select avg(quantity)				
		from				
			(			
				select ord.item_segments		
				, round(sum(ord.quantity) ,2) quantity		
				, trunc( new_due_date, 'MM')		
				from msc_orders_v ord		
				where ord.organization_code = 'BIM:BIM'		
					and ord.compile_designator = 'BIM'	
					and ord.order_type         = 29	
					and category_id           in	
					(	
						select category_id
						from mtl_item_categories_v
						where category_set_id = 1
					)	
				group by trunc( new_due_date, 'MM')		
				,ord.item_segments		
			)			
		where item_segments = msi.segment1				
	)					
	),1),0)) max_eau
, (						
		select safety_stock_quantity				
		from				
			(			
				select inventory_item_id		
				, effectivity_date		
				, safety_stock_quantity		
				from mtl_safety_stocks		
				where organization_id = 85		
				order by effectivity_date desc		
			)			
		where rownum           = 1				
			and inventory_item_id =msi.inventory_item_id			
	)					
	ssv
	, (						
		select effectivity_date				
		from				
			(			
				select inventory_item_id		
				, effectivity_date		
				, safety_stock_quantity		
				from mtl_safety_stocks		
				where organization_id = 85		
				order by effectivity_date desc		
			)			
		where rownum           = 1				
			and inventory_item_id =msi.inventory_item_id			
	)					
	efd
			, nvl(priority.category_concat_segs, 'Low') priority			
from mtl_system_items_b msi						
, mtl_item_categories_v cat
, mtl_item_categories_v priority
where msi.organization_id       = 85			
and priority.category_set_name(+) = 'BIM Safety Stock Priority'
and priority.organization_id(+) = msi.organization_id					
	and priority.inventory_item_id(+) = msi.inventory_item_id
	and cat.structure_id        = '50415'						
	and msi.inventory_item_id      = cat.inventory_item_id
	and msi.organization_id = cat.organization_id
	and inventory_item_status_code = 'Active'					
	and	msi.planner_code          = 'NJIT'			
	and nvl((						
		select effectivity_date				
		from				
			(			
				select inventory_item_id		
				, effectivity_date		
				, safety_stock_quantity		
				from mtl_safety_stocks		
				where organization_id = 85		
				order by effectivity_date desc		
			)			
		where rownum           = 1				
			and inventory_item_id =msi.inventory_item_id			
	)	,sysdate-100) < APPS.XXBIM_GET_CALENDAR_DATE('BIM', sysdate, -30)
	and item_type not       in ('RAD', 'REF', 'OP', 'TOOL', 'EX')	
	and attribute5 not like 'BIF Caps%'				
	and cat.category_concat_segs = 'Standard'				
	)
where priority <> 'Manual'
)
where nvl(ssv,0) <> new_ssv