import cx_Oracle
import pyodbc
import xlsxwriter
import os, fnmatch
from os import listdir
from os.path import isfile, join
from os.path import basename
from settings import ora_con_str
from settings import msql_con_str

def build_workbook(workbook_name):
    my_path = os.path.join(os.path.dirname(os.path.dirname( __file__ )),'sql')
    my_excel_path =my_path.replace('sql','excel') + "\\"+ workbook_name.replace(" ","_") + '.xlsx'
    workbook = xlsxwriter.Workbook(my_excel_path)
    for i in file_name(my_path, workbook_name.replace(" ","_")):
        print(basename(i).split(".")[0].split("-")[-1].replace("_"," ") )
        build_worksheet(workbook, basename(i).split(".")[0].split("-")[-1].replace("_"," ")  , i)
    workbook.close()
    return my_excel_path

def build_workbook_quickship(workbook_name):
    my_path = os.path.join(os.path.dirname(os.path.dirname( __file__ )),'sql')
    my_excel_path =my_path.replace('sql','excel') + "\\"+ workbook_name + '.xlsx'
    workbook = xlsxwriter.Workbook(my_excel_path)
    for i in file_name(my_path, workbook_name):
        print(basename(i).split(".")[0].split("-")[-1].replace("_"," ") )
        build_print_worksheet(workbook, basename(i).split(".")[0].split("-")[-1].replace("_"," ")  , i)
    workbook.close()
    return my_excel_path

def build_print_workbook(workbook_name):
    my_path = os.path.join(os.path.dirname(os.path.dirname( __file__ )),'sql')
    my_excel_path =my_path.replace('sql','excel') + "\\"+ workbook_name + '.xlsx'
    workbook = xlsxwriter.Workbook(my_excel_path)
    for i in file_name(my_path, workbook_name):
        print(basename(i).split(".")[0].split("-")[-1].replace("_"," ") )
        build_print_worksheet(workbook, basename(i).split(".")[0].split("-")[-1].replace("_"," ")  , i)
    workbook.close()
    return my_excel_path

def build_worksheet(workbook, sheet, stmt):
    
    try:
        con = cx_Oracle.connect(ora_con_str['UserName'],ora_con_str['Password'],ora_con_str['TNS'])
        cur = con.cursor()
        cur.execute(getFileStmt(stmt))
    except:
        con = pyodbc.connect('DSN='+msql_con_str['TNS']+';UID='+msql_con_str['UserName']+';PWD='+msql_con_str['Password'])
        cur = con.cursor()
        cur.execute(getFileStmt(stmt))


    headerFormat = workbook.add_format()
    headerFormat.set_bold()
    headerFormat.set_align('center')
    bodyFormat = workbook.add_format()
    bodyFormat.set_align('left')  
    dateFormat = workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})
    header = [i[0] for i in cur.description]
    sheet = workbook.add_worksheet(sheet)
    sheet.freeze_panes(1,0)
    sheet.set_column(0,len(header),18)
    
    i=0
    col = 0
    for i in header:
        sheet.write(0, col, i, headerFormat)
        col += 1       
    row = 1
    col = 0
    
    i=0
    n=0
    row=1
    col = 0
    for i in cur:
        #print(row)
        for n in range(len(header)):
            #print(n)
            try:
                sheet.write_number(row, col + n , float(i[n]), bodyFormat)
            except:
                try:
                    sheet.write_datetime(row, col + n , i[n], dateFormat)
                except:
                    sheet.write_string(row, col + n , str(i[n]), bodyFormat)
        row += 1  
    if row <= 1: sheet.hide()


    cur.close()
    con.close()

def build_worksheet_from_data(workbook, sheet, header, cur):
    
    headerFormat = workbook.add_format()
    headerFormat.set_bold()
    headerFormat.set_align('center')
    bodyFormat = workbook.add_format()
    bodyFormat.set_align('left')  
    dateFormat = workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})

    sheet = workbook.add_worksheet(sheet)
    sheet.freeze_panes(1,0)
    sheet.set_column(0,len(header),18)
    
    i=0
    col = 0
    for i in header:
        sheet.write(0, col, i, headerFormat)
        col += 1       
    row = 1
    col = 0
    
    i=0
    n=0
    row=1
    col = 0
    for i in cur:
        #print(row)
        for n in range(len(header)):
            #print(n)
            try:
                sheet.write_number(row, col + n , float(i[n]), bodyFormat)
            except:
                try:
                    sheet.write_datetime(row, col + n , i[n], dateFormat)
                except:
                    sheet.write_string(row, col + n , str(i[n]), bodyFormat)
        row += 1  
    

   

def build_print_worksheet(workbook, sheet, stmt):
    
    con = cx_Oracle.connect('apps_ro','app5_ro','BMCCORE')
    cur = con.cursor()
    cur.execute(getFileStmt(stmt))
    headerFormat = workbook.add_format()
    headerFormat.set_bold()
    headerFormat.set_border(2)
    headerFormat.set_align('center')

    bodyFormat = workbook.add_format()
    bodyFormat.set_align('left')  
    bodyFormat.set_border(1)

    bodyFormatBold = workbook.add_format()
    bodyFormatBold.set_align('left')  
    bodyFormatBold.set_border(1)
    bodyFormatBold.set_bold()
    bodyFormatBold.set_bg_color('yellow')

    dateFormat = workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})
    dateFormat.set_border(1)

    dateFormatBold = workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})
    dateFormatBold.set_border(1)
    dateFormatBold.set_bold()
    dateFormatBold.set_bg_color('yellow')

    header = [i[0] for i in cur.description]
    sheet = workbook.add_worksheet(sheet)
    sheet.freeze_panes(1,0)
    sheet.set_column(0,0,6.3)
    sheet.set_column(1,1,3.67)
    sheet.set_column(2,2,10)
    sheet.set_column(3,3,8)
    sheet.set_column(4,4,3.67)
    sheet.set_column(5,5,19)
    sheet.set_column(6,6,7.5)  
    sheet.set_column(7,len(header),10)
    sheet.fit_to_pages(1, 0) 
    sheet.set_landscape()
    #sheet.set_margins([left=0.2,] [right=0.2, top=0.75, bottom=0.75])
    #sheet.set_column(0,len(header),18)
    
    i=0
    col = 0
    for i in header:
        sheet.write(0, col, i, headerFormat)
        col += 1       
    row = 1
    col = 0
    
    i=0
    n=0
    row=1
    col = 0
    for i in cur:
        if i[4]!='JIT':
            for n in range(len(header)):
                #print(n)
                try:
                    sheet.write_number(row, col + n , float(i[n]), bodyFormatBold)
                except:
                    try:
                        sheet.write_datetime(row, col + n , i[n], dateFormatBold)
                    except:
                        sheet.write_string(row, col + n , str(i[n]), bodyFormatBold)
            row += 1  
        
        else:

        #print(row)
            for n in range(len(header)):
                #print(n)
                try:
                    sheet.write_number(row, col + n , float(i[n]), bodyFormat)
                except:
                    try:
                        sheet.write_datetime(row, col + n , i[n], dateFormat)
                    except:
                        sheet.write_string(row, col + n , str(i[n]), bodyFormat)
            row += 1  
    if row <= 1: sheet.hide()
    sheet.autofilter(0,0,row,len(header)-1)
    cur.close()
    con.close()

def getFileStmt(fStmt):
    f = open(fStmt,'r')
    stmt = f.read()
    f.close()
    return stmt

def file_name(path, name):
    result = []
    pattern = name + '-*.sql'
    for root, dirs, files in os.walk(path):
        #print(sorted(files))
        for name in sorted(files, key=str.lower):
            if fnmatch.fnmatch(name, pattern) == True:
                result.append(os.path.join(root, name))
    return result