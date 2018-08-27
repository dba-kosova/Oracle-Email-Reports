select
item "Item"
, new_moq "New MOQ"

from (
select msi.segment1 Item,nvl(minimum_order_quantity, 0) moq, msi.attribute7
, case when  nvl(
greatest((		select safety_stock_quantity				
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
	), nvl(msi.attribute7,0)),0)			between 1 and 26 then '5' 
	when nvl(
	greatest((		select safety_stock_quantity				
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
	),nvl(msi.attribute7,0))	,0)		= 0 then '0' 	else '25' end new_moq
		
from mtl_system_items_b msi
, mtl_item_categories_v cat

where msi.organization_id = 85
	and planner_code = 'NJIT'
	and cat.category_concat_segs = 'Standard'
	and cat.structure_id        = '50415'	
	and msi.segment1 not in ('MS-1478', 'MS-1486', 'MS-1489') -- vendor has a set MOQ for cost savings					
	and msi.inventory_item_id      = cat.inventory_item_id
	and msi.organization_id = cat.organization_id
	and exists (		select safety_stock_quantity				
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
	)
	where moq <> new_moq