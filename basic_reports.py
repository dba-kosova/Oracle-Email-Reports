# basic_reports.py
 
"""
    @author: Christopher Pickering

    Used to run groups of .sql statments in the /sql directory and email them to a subscription list in excel format.
    This script should run from command line $ python basic_reports.py <report_name>

    Sql scripts should be in this format: <report_name>-<tab_name>.sql

"""

import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_workbook import build_workbook
from my_email import Email

def main(reportName):

    my_path = build_workbook(reportName)
    htmlTable = """<center><h3>see attachment</h3></center><br>"""
    Email(reportName, htmlTable).SendMail()

if __name__ == '__main__': 
    reportName = sys.argv[1]

    try:
        main(reportName)

    # if report fails then send notification to th eerror address with error message    
    except BaseException as e:
        Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
        pass
