import cx_Oracle
import time
import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from my_settings import ora_con_str
from my_workbook import build_workbook

global reportName 
reportName = "BRDR"

def main(reportName):
    my_path = build_workbook(reportName)
    header1 = ["Item", "Description","EAU", "Planner", "Buyer", "Order Type", 
               "Days Late"]
    
    con = cx_Oracle.connect(ora_con_str['UserName'],ora_con_str['Password'],ora_con_str['TNS'])
    cur1b = con.cursor()
         
    stmt = getFileStmt('\\\\wikiserv\\pickering\\DailyEmail\\sql' + '\\' + "brdr-BRDR.sql")
    cur1b.execute(stmt)
              
    htmlHeader = "<table border=\"1px solid black\" align=\"center\" cellpadding=\"3\"><tr style=\"background-color:  #b3b3b3\">"
    
    for i in header1:
        if i ==1:
            htmlHeader = htmlHeader + "<td width = \"100\" style=\"white-space: nowrap;\' width=\"10%\"><b>" + i + "</b></td>"
        else:
            htmlHeader = htmlHeader + "<td width = \"100\" style=\"white-space: nowrap; max-width: 200px;\"><b>" + i + "</b></td>"
    
    htmlHeader = htmlHeader + "</tr><tr style=\" background-color:#e6ccb3;align:center\">"

    htmlContent = ""
    
    for i in cur1b:
        for n in range(len(header1)):
            if n == 0 and i == 0:
                htmlContent = htmlContent + "<td style=\"white-space: nowrap; max-width: 200px;\">" + str(i[n]) + "</td>"
                
            elif n == 0:
                htmlContent = htmlContent + "</tr><tr style=\" background-color:#e6ccb3;align:center;\"><td style=\"white-space: nowrap; max-width: 200px;\">" + str(i[n]) + "</td>"
            
            elif n == 1:
                    htmlContent = htmlContent + "<td style=\"white-space: nowrap;\" width=\"10%\">"+ str(i[n])[:30] + "</td>"
            else:
                htmlContent = htmlContent + "<td style=\"white-space: nowrap; max-width: 200px;\">"+ str(i[n]) + "</td>"
                
                    
    htmlTable = htmlHeader + htmlContent + "</tr></table>"
    
    # Close conneciton & Cursor & Workbook
    cur1b.close()
    con.close()
        
    Email(reportName, htmlTable).SendMail()

def getFileStmt(fStmt):
    f = open(fStmt,'r')
    stmt = f.read()
    f.close()
    return stmt

try:
    main(reportName)
except BaseException as e:
    print(str(e))
    Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
    pass