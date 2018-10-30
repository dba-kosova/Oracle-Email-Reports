# -*- coding: utf-8 -*-
# Dans_Daily.py

"""
    @author: Christopher Pickering
    
    The intent of this report is to merge several reports and datasets into one report
    for boss man, without rewriting, creating dups, or changing other reports.

"""

from functions import *

def main(reportName):
    dq_all = "dans_daily-DQ_All.sql"
    make_sql_file("onhand_nonshippable_locations-1.sql","dans_daily-OnHand_NonShippable.sql","")
    make_sql_file("orders-Orders.sql", "dans_daily-DQ_All.sql","""    and greatest(ola.request_date, nvl((select promise_date
    from
        (
            select hist_creation_date
            , promise_date
            ,header_id
            ,line_id
            from oe_order_lines_history h
            where 1            =1
                and promise_date is not null
            order by hist_creation_date asc
        )
    where rownum   = 1
        and line_id   = ola.line_id),promise_date)) < trunc(sysdate)""")

    make_sql_file(dq_all,"dans_daily-DQ_Holds.sql",""" and  apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) = 'YES'
        and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code)  = 'Awaiting Shipping'""")

    make_sql_file(dq_all,"dans_daily-DQ_Ship_Set.sql", """and decode(
                            (
                                select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
                                    and shippable_flag                                         = 'Y'
                                    and ship_set_id                                            = ola.ship_set_id group by ship_set_id
                            )
                            , '1', 'No', null ,'No', 'Ship Set') = 'Ship Set'
                            and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code)  = 'Awaiting Shipping'""")

    make_sql_file(dq_all, "dans_daily-DQ_Picked_N_Shipped.sql","""and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code)  = 'Picked'""")

    make_sql_file(dq_all, "dans_daily-DQ_Assembly.sql","""and wdj.status_type_disp = 'Released'""")

    make_sql_file(dq_all, "dans_daily-DQ_JIT.sql","""    and wdj.status_type_disp = 'Unreleased'
        and wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 = '.0.0'""")

    make_sql_file(dq_all, "dans_daily-DQ_Assy_Hold.sql", """and wdj.status_type_disp = 'On Hold'""")

    make_sql_file(dq_all, "dans_daily-DQ_Shipped.sql", """    and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Shipped'""")

    make_sql_file(dq_all, "dans_daily-DQ_Shortage.sql", """and wdj.status_type_disp = 'Unreleased'
        and wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 <> '.0.0'""")

    make_sql_file(dq_all, "dans_daily-DQ_Partial_In_Stock.sql", """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) in ('Production Partial','Picked Partial')""")

    make_sql_file(dq_all, "dans_daily-DQ_RMA.sql", """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Fulfillment'""")

    make_sql_file(dq_all, "dans_daily-DQ_Awaiting_Supply.sql","""and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Supply'""")

    make_sql_file(dq_all, "dans_daily-DQ_New_Orders.sql", """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) in ('Booked','Supply Eligible')""")

    make_sql_file(dq_all, "dans_daiy-DQ_Awaiting_Shipping.sql", """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Shipping'
    and  apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) = 'NO'
    and decode(
                            (
                                select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
                                    and shippable_flag                                         = 'Y'
                                    and ship_set_id                                            = ola.ship_set_id group by ship_set_id
                            )
                            , '1', 'No', null ,'No', 'Ship Set') = 'No'
        """)

    make_sql_file("orders-Orders.sql","dans_daily-Future_Orders.sql","""  and ola.request_date > apps.xxbim_get_calendar_date('BIM', sysdate, 30)""")

    #initialize workbook
    my_workbook = Workbook(reportName)

    # create worksheets
    my_workbook.build_workbook()

    htmlTable = None

    Email(reportName, htmlTable).SendMail()

reportName = Path(__file__).stem

if __name__ == '__main__':
    try:
        main(reportName)
    except BaseException as e:
        print(str(e))
        Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
        pass