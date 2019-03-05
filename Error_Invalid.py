
from functions import *

def main(reportName):
   
    data = run_sql_statement('summary')

    new_data = []

    for x in data:

        this = [q for q in x]
        if x[-1] != 'NONE':
            this.append(er_status(x[-1]))
            new_data.append(this)
        else:
            this.append('None')
            new_data.append(this)


    # create worksheets
    me = Workbook(reportName)

    header = ['Order Number',
            'Order Line No',
            'Item No',
            'User Item Description',
            'Order Status',
            'Header Creation Date',
            'Header Creation TIme',
            'Line Creation Date',
            'Line Creation Time',
            'Ordered Date',
            'Request Date',
            'Agile ER Number',
            'ER Status']

    me.create_worksheet_from_data(header, new_data)
    
    # send emails
    Email(reportName, None).SendMail()

if __name__ == '__main__': 
    reportName = 'error_invalid'

    try:
        main(reportName)

    # if report fails then send notification to th eerror address with error message    
    except BaseException as e:
        print(e)
        Email(reportName + ' error', str(e)).SendMail()
        pass
