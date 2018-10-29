# -*- coding: utf-8 -*-
# onhold.py

"""
    @author: Christopher Pickering

    This report is used to send a list of on hold jobs with no shortages to the appropriate parties.

"""

from functions import *

def main(reportName):

    # create database connection
    me = Database()
    me.oracle_connect()

    # run report sql statement
    cur = me.run_url(Path(__file__).parents[0].joinpath('sql','onhold-1.sql'))

    header = ["Line", "Project", "Job", "DFF","Date Released", "Assembly", "Item", "Qty ATT", "Job Qty"]
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

    # close database
    me.close()

    # send email report
    Email(reportName, html).SendMail()

reportName = "On Hold"


if __name__ == '__main__':
    try:
        main(reportName)
    except BaseException as e:
        print(str(e))
        Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
        pass