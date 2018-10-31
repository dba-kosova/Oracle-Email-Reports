# -*- coding: utf-8 -*-
# basic_reports.py
 
"""
    @author: Christopher Pickering

    Used to run groups of .sql statments in the /sql directory and email them to a subscription list in excel format.
    This script should run from command line $ python basic_reports.py <report_name>

    Sql scripts should be in this format: <report_name>-<tab_name>.sql

"""

from functions import *

def main(reportName):
   
    # create worksheets
    me = Workbook(reportName)
    me.build_workbook()
    
    # send emails
    Email(reportName, None).SendMail()

if __name__ == '__main__': 
    reportName = sys.argv[1]

    try:
        main(reportName)

    # if report fails then send notification to th eerror address with error message    
    except BaseException as e:
        print(e)
        Email(reportName + ' error', str(e)).SendMail()
        pass
