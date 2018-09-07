# database.py

""" 
	Database conneciton wrapper
	@author: Christopher Pickering

"""

import cx_Oracle
import pyodbc

from settings import ora_con_str
from settings import msql_con_str

class Oracle:

	"""
		how to use:
		me = Oracle()
		me.connect()
		me.cursor.execute()
		me.close()

	"""

	def __init__(self):
		self.connection = None
		self.cursor = None
		self.sql = None

	def connect(self):
		self.connection = cx_Oracle.connect(ora_con_str['UserName'],ora_con_str['Password'],ora_con_str['TNS'])
		self.cursor = self.connection.cursor()

	def close(self):
		self.cursor.close()
		self.connection.close()


class Mysql:

	"""
		how to use:
		me = Mysql()
		me.connect()
		me.cursor.execute()
		me.close()

	"""

	def __init__(self):
		self.connection = None
		self.cursor = None
		self.sql = None

	def connect(self):
		self.connection = pyodbc.connect('DSN='+msql_con_str['TNS']+';UID='+msql_con_str['UserName']+';PWD='+msql_con_str['Password'])
		self.cursor = self.connection.cursor()

	def close(self):
		self.cursor.close()
		self.connection.cursor()
