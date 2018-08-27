select msi.organization_id "Org", msi.segment1 "Item"						
, msi.planner_code						"Planner"
, msi.cumulative_total_lead_time "Lead Time"
, msi.full_lead_time	"Full Lead Time"
,inventory_item_status_code "Status"
, nvl(round(msi.attribute7,1),0) "EAU"
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
	"Safety Stock"					
from mtl_system_items_b msi						
, mtl_item_categories_v cat
where msi.organization_id       in ( 85			, 90)
	and cat.structure_id(+)        = '50415'						
	and msi.inventory_item_id      = cat.inventory_item_id(+)
	and msi.organization_id = cat.organization_id(+)
	--and inventory_item_status_code = 'Active'					
	--and	msi.planner_code          = 'NJIT'								
	--and item_type not       in ('RAD', 'REF', 'OP', 'TOOL', 'EX')					
	and nvl(cat.category_concat_segs, 'Special') <> 'Standard'		
	and nvl((						
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
	),0)	 <> 0