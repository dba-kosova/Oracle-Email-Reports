# -*- coding: utf-8 -*-

import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from my_workbook import Workbook

me = Workbook('quickship')


print(me.tab_list())
