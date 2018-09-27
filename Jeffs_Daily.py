# Jeffs_Daily.py

"""
    @author: Christopher Pickering
    
    The intent of this report is to create a filtered view of one file for testing purposes.

"""

import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from my_workbook import Workbook
from shutil import copyfile
import os

def make_sql_files(source, filename, sql):

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

    make_sql_files("orders-1_Open_Orders.sql", "Jeffs_Daily-orders.sql","""and wdj.status_type_disp = 'Released'
    and ola.ship_from_org_id = 85
    and nvl((select promise_date
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
    and line_id   = ola.line_id),promise_date) <= apps.xxbim_get_calendar_date('BIM', sysdate,5)""")

    make_sql_files("transactions-Yesterday.sql", "Jeffs_Daily-WIP_Completion.sql","""    and transaction_type_id = 44
""")

  
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