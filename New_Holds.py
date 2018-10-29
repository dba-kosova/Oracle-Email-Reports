# -*- coding: utf-8 -*-
# New_Holds.py

"""
    @author: Christopher Pickering

    report used to send new shortage list out out to interested parties.
    When discrete jobs are placed on hold an exception is entered into oracle.
    This report is grabing any new exceptions.

"""

from functions import *

def main(reportName):

    #initialize workbook
    my_workbook = Workbook(reportName)

    # create worksheets
    my_path = my_workbook.build_workbook()

    # create database connection
    me = Database()
    me.oracle_connect()

    # run report sql statement

    cur = me.run_url(Path(__file__).parents[0].joinpath('sql','new_holds-1.sql'))

    header = ["Item", "Planner"]
    html = "<table border=\"1px solid black\" align=\"center\" cellpadding=\"3\"><tr style=\"background-color:  #b3b3b3\">"

    i=0
    for i in header:
        if i ==1:
            html = html + "<td width = \"100\" style=\"white-space: nowrap;\' width=\"10%\"><b>" + i + "</b></td>"
        else:
            html = html + "<td width = \"100\" style=\"white-space: nowrap; max-width: 200px;\"><b>" + i + "</b></td>"
    
    html = html + "</tr><tr style=\" background-color:#e6ccb3;align:center\">"

    i=0
    for i in cur:
        for n in range(len(header)):
            if n == 0 and i == 0:
                html = html + "<td style=\"white-space: nowrap; max-width: 200px;\">" + str(i[n]) + "</td>"
                
            elif n == 0:
                html = html + "</tr><tr style=\" background-color:#e6ccb3;align:center;\"><td style=\"white-space: nowrap; max-width: 200px;\">" + str(i[n]) + "</td>"
            
            elif n == 1:
                    html = html + "<td style=\"white-space: nowrap;\" width=\"10%\">"+ str(i[n])[:30] + "</td>"
            else:
                html = html + "<td style=\"white-space: nowrap; max-width: 200px;\">"+ str(i[n]) + "</td>"             
                    
    html += "</tr></table>"

    # close database conneciton
    me.close()

    # send report email
    Email(reportName, html).SendMail()

# report name is coming from file name
reportName = Path(__file__).stem

if __name__ == '__main__':
    try:
        main(reportName)
    except BaseException as e:
        print(str(e))
        Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
        pass