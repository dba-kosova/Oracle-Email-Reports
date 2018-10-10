

import sys
from pathlib import Path
import basic_reports
import time

def timeit(method):
    def timed(*args, **kw):
        ts = time.time()
        print('starting ' + method.__name__)
        try:
            result = method(*args, **kw)
            te = time.time()
            print ('success running %r in %2.2f sec' % (method.__name__,  te-ts))

        except Exception as e:
            te = time.time()
            print ('error running %r. Message %r' % (method.__name__, str(e)))

    return timed

# get sql prefix
sql_report_list = set([x.stem.split('-')[0] for x in Path(__file__).parents[0].joinpath('sql').glob('*.sql') ])

# get non basic reports
non_basic_report_list = set([x.stem for x in Path(__file__).parents[0].glob('*.py') if x.stem not in ['basic_reports','test']])

# basic reports
basic_report_list = list(sql_report_list - non_basic_report_list)


# test basic reports
for report in basic_report_list:
    if str(report) == 'test1':
        timeit(basic_reports.main)(report)

# for static reports
for report in non_basic_report_list:
    if str(report) == 'test2':

        my_module = __import__(report, ['main']) 
        timeit(my_module.main)()
