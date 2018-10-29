# my_database.py

""" 
    @author: Christopher Pickering
    
    Database connection wrapper. 

    how to use:

    # create obj
    me = Database()
    
    # option 1. connect to oracle database
    me.oracle_connect()
    # option 2. connect to microsoft database
    me.mssql_connect()
    
    # option 1. run sql in script
    me.cursor.execute()
    # option 2. run sql statement through function
    me.run_stmt('select sysdate from dual')
    # option 3. run sql statement in file system
    me.run_url('file.sql')

    # close connection and cursor
    me.close()
    
"""

import cx_Oracle
import pyodbc

from functions.my_settings import ora_con_str
from functions.my_settings import msql_con_str

class Database:
    def __init__(self):
        self.connection = None
        self.cursor = None
        self.sql = None

    # for Oracle SQL database
    def oracle_connect(self):
        self.connection = cx_Oracle.connect(ora_con_str['UserName'],ora_con_str['Password'],ora_con_str['TNS'])
        self.cursor = self.connection.cursor()

    # for Microsoft SQL database
    def mssql_connect(self):
        self.connection = pyodbc.connect('DSN='+msql_con_str['TNS']+';UID='+msql_con_str['UserName']+';PWD='+msql_con_str['Password'])
        self.cursor = self.connection.cursor()

    def run_stmt(self, sql):
        return self.cursor.execute(sql)

    def run_url(self, url):
        f = open(url,'r')
        stmt = f.read()
        f.close()

        return self.cursor.execute(stmt)

    def close(self):
        self.cursor.close()
        self.connection.close()

