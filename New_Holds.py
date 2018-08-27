import cx_Oracle
import xlsxwriter
import time
import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from build_excel import build_workbook
from settings import ora_con_str

def daily1Report():

    #make excel
    my_path = build_workbook('new holds')

    # Create Connection & Get Cursor
    con = cx_Oracle.connect(ora_con_str['UserName'],ora_con_str['Password'],ora_con_str['TNS'])
    cur = con.cursor()

    # Load SQL statement into curson
    stmt = getFileStmt(os.path.join(os.path.dirname( __file__ ),'sql') + "new_holds-1.sql")
    cur.execute(stmt)

    t = getDate()

    header = ["Item", "Planner"]

    htmlHeader = "<table border=\"1px solid black\" align=\"center\" cellpadding=\"3\"><tr style=\"background-color:  #b3b3b3\">"
    i=0
    for i in header:
        if i ==1:
            htmlHeader = htmlHeader + "<td width = \"100\" style=\"white-space: nowrap;\' width=\"10%\"><b>" + i + "</b></td>"
        else:
            htmlHeader = htmlHeader + "<td width = \"100\" style=\"white-space: nowrap; max-width: 200px;\"><b>" + i + "</b></td>"
    
    htmlHeader = htmlHeader + "</tr><tr style=\" background-color:#e6ccb3;align:center\">"

    htmlContent = ""
    i=0
    for i in cur:
        for n in range(len(header)):
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

    cur.close()
    con.close()

    #htmlTable = "<center><h3>see attachment</h3></center>"
    t = getDate()


    reportName = "New On Hold Exception " + t
    Email(reportName, htmlTable).SendMail()



def getDate():
    return time.strftime("%d-%b-%y")

def getFileStmt(fStmt):
    f = open(fStmt,'r')
    stmt = f.read()
    f.close()
    return stmt


    server.close()

daily1Report()
