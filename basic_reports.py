import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from build_excel import build_workbook
from build_excel import build_workbook_quickship

from my_email import Email



def main(reportName):

    if reportName == 'Quickship':
        my_path = build_workbook_quickship(reportName)

    else:
        my_path = build_workbook(reportName)

    htmlTable = """<center><h3>see attachment</h3></center><br>"""

    Email(reportName, htmlTable).SendMail()


if __name__ == '__main__':
    
    reportName = sys.argv[1]

    try:
        main(reportName)
    except BaseException as e:
        Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
        pass
