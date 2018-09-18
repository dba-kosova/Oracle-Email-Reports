# Scheduled Emails
This code set is used to automate some reporting from Oracle E Business suite. Oracle canned reports are rough and can be time consuming to setup and tweak. This project is setup to sit on a windows server and used scheduled tasks to run the various reports.

## Prereqs
- oracle instant client

## Development Setup
1. Create a local project diretory and pull code.
```bash
$ mkdir DailyEmail
$ cd DailyEmail
$ git init
$ git add remote origin https://github.com/christopherpickering/Bim_Daily_Mail.git
# or clone a copy for your purposes
# git clone https://github.com/christopherpickering/Bim_Daily_Mail.git
$ git pull
```
2. Create a my_settings.py file /functions/. The format should be as follows:
```python

# default email sender info
email_settings = {
	'address':'ip_address:port',
	'default_sender':'default@email.com',
	'reply_to':'reply@to.com'
}

# oracle database connection
# the tns name must match what is in tnsnames.ora in your oracle instant client installation.
ora_con_str = {
	'UserName':'username',
  'Password':'password',
  'TNS':'tns'
}

# mssql database connection
msql_con_str = {
	'UserName':'username',
   'Password':'password',
   'TNS':'MSSQL'
}

# email subscription list
subscriptions = {
	"report1":"email@1.com,email@2.com,email@3.com",
  "report2":"email@1.com,email@2.com,email@3.com"
}
```
3. Add reports. This is done by dropping sql files into the /sql/ folder. The naming convention must be: report_name-excel_tab_name.sql

## Server Setup
This package is current setup for windows IIS server using the task scheduler.
1. Create a new task in task scheduler.
- Application: python
- Add arguments: basic_reports.py Report_Name
- Start in: path/to/basic_reports.py

