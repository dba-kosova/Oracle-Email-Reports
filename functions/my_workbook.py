# my_workbook.py

"""
    @author: Christopher Pickering

    functions used to create formated excel files
    
    usage:

    #initialize workbook
    me = Workbook(reportName)

    # create worksheets
    my_path = me.build_workbook()

"""

import xlsxwriter
import fnmatch
from functions.my_database import Database
from pathlib import Path

class Workbook:
    def __init__(self,workbook_name):
        
        # define paths
        self.my_sql_path = Path(__file__).parents[1].joinpath('sql')
        self.my_excel_path = Path(__file__).parents[1].joinpath('excel',workbook_name.replace(" ","_")).with_suffix('.xlsx')

        # define workbook
        self.workbook_name = workbook_name.lower()
        self.workbook = xlsxwriter.Workbook(str(self.my_excel_path))
        self.workbook_tab_list = self.tab_list()

    def tab_list(self):
        result = []
        for file in self.my_sql_path.glob('*.sql'):        
            if fnmatch.fnmatch(file.stem.split('-')[0].lower(), self.workbook_name) == True:
                result.append(str(file))

        return result

    def build_workbook(self):

        if self.workbook_name.lower() == 'quickship':
            return self.create_print_worksheets()

        else:
            return self.create_worksheets()

    def create_worksheets(self):

        me = Database()
        me.oracle_connect()

        # create worksheet formats
        headerFormat = self.workbook.add_format()
        headerFormat.set_bold()
        headerFormat.set_align('center')
        bodyFormat = self.workbook.add_format()
        bodyFormat.set_align('left')  
        dateFormat = self.workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})

        # create a tab for each sql query
        for url in self.tab_list():

            # try to run in oracele database
            try:       
                cur = me.run_url(url)

            # if statment will not run in oracle try in mssql
            except:
                try:
                    me.mssql_connect()
                    cur = me.run_url(url)

                # if statement will not run in mssql try oracle
                # in some cases we will run several oracle queries, then run a mssql, then several more oracle queries.
                except:
                    me.oracle_connect()
                    cur = me.run_url(url)

            header = [i[0] for i in cur.description]
            sheet = self.workbook.add_worksheet(str(Path(url).stem.split('-')[-1].replace('_',' ')))
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

            # don't show emtpy sheets
            if row <= 1: sheet.hide()

        me.close()  
        self.close()   
        return str(self.my_excel_path)

    def create_print_worksheets(self):

        # connect to database
        me = Database()
        me.oracle_connect()

        # create workbook formats
        headerFormat = self.workbook.add_format()
        headerFormat.set_bold()
        headerFormat.set_border(2)
        headerFormat.set_align('center')

        bodyFormat = self.workbook.add_format()
        bodyFormat.set_align('left')  
        bodyFormat.set_border(1)

        bodyFormatBold = self.workbook.add_format()
        bodyFormatBold.set_align('left')  
        bodyFormatBold.set_border(1)
        bodyFormatBold.set_bold()
        bodyFormatBold.set_bg_color('yellow')

        dateFormat = self.workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})
        dateFormat.set_border(1)

        dateFormatBold = self.workbook.add_format({'num_format': 'd-mmm-yy', 'align':'left'})
        dateFormatBold.set_border(1)
        dateFormatBold.set_bold()
        dateFormatBold.set_bg_color('yellow')

        # create a tab for each sql query
        for url in self.tab_list():
            try:       
                cur = me.run_url(url)

            # if statment will not run in oracle try in mssql
            except:
                try:
                    me.mssql_connect()
                    cur = me.run_url(url)

                # if statement will not run in mssql try oracle
                except:
                    me.oracle_connect()
                    cur = me.run_url(url)

            
            # set sheet formats. add header
            header = [i[0] for i in cur.description]
            sheet = self.workbook.add_worksheet(str(Path(url).stem.split('-')[-1].replace('_',' ')))
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

            # don't show empty sheets
            if row <= 1: sheet.hide()
            sheet.autofilter(0,0,row,len(header)-1)
    
        me.close()
        self.close()
        return str(self.my_excel_path)

    def close(self):
        self.workbook.close()