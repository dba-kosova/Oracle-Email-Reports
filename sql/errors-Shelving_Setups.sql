select msi.segment1 "Item"
, planner_code "Planner"
, decode(planning_make_buy_code,2,'Buy','Make') "Make Buy"
, default_shipping_org "Default Shipping Org"
, sourcing_rule_name "Sourcing Rule"
, (
		select rule_name
		from mtl_atp_rules
		where rule_id = atp_rule_id
	)
	"ATP Rule"
from mrp_sr_assignments_v mis
, mtl_system_items msi
where 1                    =1
	and msi.organization_id   = mis.organization_id(+)
	and msi.inventory_item_id = mis.inventory_item_id(+)
	--and msi.planner_code not like '%SHV-M'
	and msi.organization_id = 85
	and planner_code not   in ('TOL', 'MWS', 'NJIT', 'THR','FO Buy Obs', 'MAT', 'REF')
	and planner_code not like 'P__'
	and
	(
		(
			msi.planner_code not like '%SHV-M'
			and
			(
				(
					planning_make_buy_code             = 1
					and nvl(sourcing_rule_name,'asdf') = 'BIM Transfer from BMX'
				)
				or
				(
					default_shipping_org               = 90
					and nvl(sourcing_rule_name,'asdf') = 'BIM Transfer from BMX'
				)
			)
		)
		or
		(
			msi.planner_code like '%SHV-M'
			and
			(
				planning_make_buy_code             = 1
				or default_shipping_org            = 90
				or nvl(sourcing_rule_name,'asdf') <> 'BIM Transfer from BMX'
			)
		)
		or
		(
			nvl(
			(
				select rule_name
				from mtl_atp_rules
				where rule_id = atp_rule_id
			)
			,'a')                             <> 'Bimba SFG Transferred'
			and nvl(sourcing_rule_name,'asdf') = 'BIM Transfer from BMX'
		)
	)