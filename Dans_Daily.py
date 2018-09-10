# Dans_Daily.py

"""
    @author: Christopher Pickering
    
    The intent of this report is to merge several reports and datasets into one report
    for boss man, without rewriting, creating dups, or changing other reports.

"""

import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from my_workbook import Workbook
from shutil import copyfile
import os

def make_dq_files(source, filename, sql):

    home_path = os.path.join(os.path.dirname( __file__ ),'sql')
    new_file = os.path.join(home_path, filename)
    old_file = os.path.join(home_path, source)
    copyfile(old_file, new_file)
    
    # get contents of sql file
    f = open(new_file,"r")
    contents = f.readlines()
    f.close()

    # add new stuff to the end of it
    contents.insert(sum(1 for line in contents)-1,sql + "\n")

    contents = "".join(contents)

    # send stuff back to file
    f = open(new_file, "w")
    f.write(contents)
    f.close()

def delete_dq_files(filename):
    if os.path.exists(os.path.join(home_path, filename)):
        os.remove(os.path.join(home_path, filename))

def main(reportName):

    dq_all = "dans_daily-DQ_All.sql"
    dq_holds = "dans_daily-DQ_Holds.sql"
    dq_ship_set = "dans_daily-DQ_Ship_Set.sql"
    dq_picked_not_shipped = "dans_daily-DQ_Picked_N_Shipped.sql"
    dq_assembly = "dans_daily-DQ_Assembly.sql"
    dq_JIT = "dans_daily-DQ_JIT.sql"
    dq_Assy_Hold = "dans_daily-DQ_Assy_Hold.sql"
    dq_Partial = "dans_daily-DQ_Partial_In_Stock.sql"
    dq_Shipped = "dans_daily-DQ_Shipped.sql"
    dq_Shortage = "dans_daily-DQ_Shortage.sql"
    dq_RMA = "dans_daily-DQ_RMA.sql"
    dq_Waiting_Supply = "dans_daily-DQ_Awaiting_Supply.sql"
    dq_New_Bookings = "dans_daily-DQ_New_Orders.sql"
    dq_Awaiting_Shipping = "dans_daiy-DQ_Awaiting_Shipping.sql"
    Future_Orders = "dans_daily-Future_Orders.sql"
    NonShippable = "dans_daily-OnHand_NonShippable.sql"

    make_dq_files("onhand_nonshippable_locations-1.sql",NonShippable,"")
    make_dq_files("orders-1_Open_Orders.sql", dq_all,"""    and greatest(ola.request_date, nvl((select promise_date
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

    make_dq_files(dq_all,dq_holds,""" and  apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) = 'YES'
        and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code)  = 'Awaiting Shipping'""")

    make_dq_files(dq_all,dq_ship_set, """and decode(
                            (
                                select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
                                    and shippable_flag                                         = 'Y'
                                    and ship_set_id                                            = ola.ship_set_id group by ship_set_id
                            )
                            , '1', 'No', null ,'No', 'Ship Set') = 'Ship Set'
                            and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code)  = 'Awaiting Shipping'""")

    make_dq_files(dq_all, dq_picked_not_shipped,"""and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code)  = 'Picked'""")

    make_dq_files(dq_all, dq_assembly,"""and wdj.status_type_disp = 'Released'""")

    make_dq_files(dq_all, dq_JIT,"""    and wdj.status_type_disp = 'Unreleased'
        and wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 = '.0.0'""")

    make_dq_files(dq_all, dq_Assy_Hold, """and wdj.status_type_disp = 'On Hold'""")

    make_dq_files(dq_all, dq_Shipped, """    and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Shipped'""")

    make_dq_files(dq_all, dq_Shortage, """and wdj.status_type_disp = 'Unreleased'
        and wdj.attribute1 ||'.'|| wdj.attribute2 ||'.'|| wdj.attribute3 <> '.0.0'""")

    make_dq_files(dq_all, dq_Partial, """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) in ('Production Partial','Picked Partial')""")

    make_dq_files(dq_all, dq_RMA, """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Fulfillment'""")

    make_dq_files(dq_all, dq_Waiting_Supply,"""and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Supply'""")

    make_dq_files(dq_all, dq_New_Bookings, """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) in ('Booked','Supply Eligible')""")

    make_dq_files(dq_all, dq_Awaiting_Shipping, """and OE_LINE_STATUS_PUB.Get_Line_Status(ola.line_id, ola.flow_status_code) = 'Awaiting Shipping'
    and  apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) = 'NO'
    and decode(
                            (
                                select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
                                    and shippable_flag                                         = 'Y'
                                    and ship_set_id                                            = ola.ship_set_id group by ship_set_id
                            )
                            , '1', 'No', null ,'No', 'Ship Set') = 'No'
        """)

    make_dq_files("orders-1_Open_Orders.sql",Future_Orders,"""  and ola.request_date > apps.xxbim_get_calendar_date('BIM', sysdate, 30)""")

    #initialize workbook
    my_workbook = Workbook(reportName)

    # create worksheets
    my_path = my_workbook.build_workbook()

    htmlTable = None

    Email(reportName, htmlTable).SendMail()

reportName = os.path.basename(__file__ ).split('.')[0]

try:
    main(reportName)
except BaseException as e:
    print(str(e))
    Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
    pass