# -*- coding: utf-8 -*-
# Jeffs_Daily.py

"""
    @author: Christopher Pickering
    
    The intent of this report is to create a filtered view of one file for testing purposes.

"""

from functions import *

def main(reportName): 
    make_sql_file("transactions-Yesterday.sql", "Jeffs_Daily-WIP_Completion.sql","""    and transaction_type_id = 44
""")
  
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