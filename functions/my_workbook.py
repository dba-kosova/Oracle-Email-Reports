# my_workbook.py

"""
    @author Christopher Pickering

    functions used to create formated excel files

"""

import xlsxwriter
import os
import fnmatch
from os import listdir
from os.path import isfile, join
from os.path import basename
from my_database import Database

class Workbook:
    def __init__(self,workbook_name):
        
        # define paths
        self.my_sql_path = os.path.abspath(os.path.join(os.path.dirname(os.path.dirname( __file__ )),'sql'))
        self.my_excel_path =os.path.join(self.my_sql_path.replace('sql','excel'),workbook_name.replace(" ","_") + '.xlsx')

        # define workbook
        self.workbook_name = workbook_name.lower()
        self.workbook = xlsxwriter.Workbook(self.my_excel_path)
        self.workbook_tab_list = self.tab_list()

    def tab_list(self):
        result = []
        for root, dirs, files in os.walk(self.my_sql_path):
            for file in sorted(files, key=str.lower):
                if fnmatch.fnmatch(file, self.workbook_name + '-*.sql') == True:
                    result.append(os.path.join(root, file))
        return result

    def worksheet(self):
        

        return None        


    def print_worksheet(self):
        return None

    def close_workbook(self):
        self.workbook.close()


def build_workbook(workbook_name):

    my_sql_path = os.path.abspath(os.path.join(os.path.dirname(os.path.dirname( __file__ )),'sql'))
    my_excel_path =os.path.join(my_sql_path.replace('sql','excel'),workbook_name.replace(" ","_") + '.xlsx')
    
    workbook = xlsxwriter.Workbook(my_excel_path)
    
    for i in file_name(my_sql_path, workbook_name.replace(" ","_")):
        if workbook_name == 'Quickship':
            build_print_worksheet(workbook, basename(i).split(".")[0].split("-")[-1].replace("_"," ")  , i)

        else:
            build_worksheet(workbook, basename(i).split(".")[0].split("-")[-1].replace("_"," ")  , i)

    workbook.close()

    return my_excel_path


def build_worksheet(workbook, sheet, stmt):
    
    me = Database()
    
    try:       
        me.oracle_connect()
        cur = me.run_stmt(stmt)

    except:
        me.mssql_connect()
        cur = me.run_stmt(stmt)


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
        for n in range(len(header)):
            try:
                sheet.write_number(row, col + n , float(i[n]), bodyFormat)
            except:
                try:
                    sheet.write_datetime(row, col + n , i[n], dateFormat)
                except:
                    sheet.write_string(row, col + n , str(i[n]), bodyFormat)
        row += 1  
    if row <= 1: sheet.hide()

    me.close()



def build_print_worksheet(workbook, sheet, stmt):
    
    me = Database()
    me.oracle_connect()
    cur = me.run_stmt(stmt)
    
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

            for n in range(len(header)):
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
    
    me.close()

def file_name(path, name):
    result = []
    for root, dirs, files in os.walk(path):
        for name in sorted(files, key=str.lower):
            if fnmatch.fnmatch(name, name + '-*.sql') == True:
                result.append(os.path.join(root, name))
    return result
