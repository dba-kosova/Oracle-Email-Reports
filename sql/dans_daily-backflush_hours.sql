select nvl(resource_code,'Total') "Resource"
		, round(sum(primary_quantity),1)"Backflush Hrs Yesterday"
from wip_transactions_v wv
where organization_id = 85
	and resource_code  like '%OPER%'
	and transaction_date between apps.xxbim_get_calendar_date('BIM', sysdate,-1) and trunc(sysdate)
group by rollup(resource_code)