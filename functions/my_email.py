# my_email.py

"""
    @author Christopher Pickering

    used to create email message for sending daily reports.
    will send with attachments or html body

"""

from my_settings import subscriptions, email_settings
import time
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders
import smtplib
import os.path

class Email:
    
    def __init__(self,report,message):


        # send error emails
        if report.endswith('error'):
            self.subscriptions = [x.strip() for x in subscriptions['ErrorAddress'].split(',')]
            self.recipients = subscriptions['ErrorAddress']
            
        # send normal emails
        else:
            self.subscriptions = [x.strip() for x in subscriptions[report].split(',')]
            self.recipients = subscriptions[report]
        
        
        self.subject = report + " " + time.strftime("%d-%b-%y")
        self.file_location = os.path.abspath(os.path.join(os.path.dirname(os.path.dirname( __file__ )),'excel',report + '.xlsx'))
        self.report = report
        self.message = message
        self.htmlmessage = self.htmlMessage()

    def SendMail(self):

        # creat message
        msg = MIMEMultipart()

        # email headers
        msg['Subject'] = self.subject
        msg['To'] =  self.recipients
        msg['From'] = email_settings['default_sender']
        msg['Reply-To'] = email_settings['reply_to']

        # email message
        msg.attach(MIMEText(self.htmlmessage, 'html'))

        # add attachment
        if os.path.isfile(self.file_location):

            part = MIMEBase('application', "octet-stream")
            part.set_payload(open(self.file_location, "rb").read())
            part.add_header('Content-Disposition', 'attachment; filename='+self.subject.replace(' ','_') + '.xlsx')
            encoders.encode_base64(part)
            msg.attach(part)

        # send mail
        server = smtplib.SMTP(email_settings['address'])
        server.ehlo()
        server.sendmail(msg['From'], self.subscriptions, msg.as_string())
        server.close()


    def htmlMessage(self):
        return """<style> .content-loader tr td {
        white-space: nowrap;
        max-width: 200;
        }</style><h1><center>""" + self.report + """</center></h1><br><br>""" + self.message + """<br><br><tbody><tr style="vertical-align: top">
                      <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top" width="100%">
                        <!--[if gte mso 9]>
                        <table id="outlookholder" border="0" cellspacing="0" cellpadding="0" align="center"><tr><td>
                        <![endif]-->
                        <!--[if (IE)]>
                        <table width='100%' align="center" cellpadding="0" cellspacing="0" border="0">
                            <tr>
                                <td>
                        <![endif]-->
                        <table class="container" style="border-spacing: 0;border-collapse: collapse;vertical-align: top;margin: 0 auto;text-align: inherit" align="center" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr style="vertical-align: top"><td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top" width="100%">
                            <table class="block-grid" style="border-spacing: 0;border-collapse: collapse;vertical-align: top;width: 100;color: #333;background-color: transparent" bgcolor="transparent" cellpadding="0" cellspacing="0" width="100%"><tbody><tr style="vertical-align: top"><td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;text-align: center;font-size: 0"><!--[if (gte mso 9)|(IE)]><table width="100%" align="center" cellpadding="0" cellspacing="0" border="0"><tr><![endif]-->

                                    <!--[if (gte mso 9)|(IE)]><td class='' valign="top" width='100%'><![endif]--><div class="col num12" style="display: inline-block;vertical-align: top;width: 500px"><table style="border-spacing: 0;border-collapse: collapse;vertical-align: top" align="center" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr style="vertical-align: top"><td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;background-color: transparent;padding-top: 30px;padding-right: 0px;padding-bottom: 30px;padding-left: 0px;border-top: 0px solid transparent;border-right: 0px solid transparent;border-bottom: 0px solid transparent;border-left: 0px solid transparent">

    <table style="border-spacing: 0;border-collapse: collapse;vertical-align: top" cellpadding="0" cellspacing="0" width="100%">
      <tbody><tr style="vertical-align: top">
        <td style="word-break: break-word;border-collapse: collapse !important;vertical-align: top;padding-top: 15px;padding-right: 10px;padding-bottom: 10px;padding-left: 10px">
            <div style="color:#959595;line-height:150%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;">            
                <div style="font-size:14px;line-height:21px;text-align:center;color:#959595;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;"><p style="margin: 0;font-size: 14px;line-height: 21px;text-align: center">This is an automated email message from Christopher Pickering<strong>.</strong></p></div><div style="font-size:14px;line-height:21px;text-align:center;color:#959595;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;"><p style="margin: 0;font-size: 14px;line-height: 21px;text-align: center">please <a style="font-size: 14px; line-height: 21px; text-align: center;;color:#C7702E" href="mailto:pickeringc@bimba.com">email </a>me if there is a problem</p></div>
            </div>
        </td>
      </tr>
    </tbody></table>
                            </td></tr></tbody></table></div>
                             <!--[if (gte mso 9)|(IE)]></td><![endif]-->
                        <!--[if (gte mso 9)|(IE)]></td></tr></table><![endif]--></td></tr></tbody></table></td></tr></tbody></table>
                        <!--[if mso]>
                        </td></tr></table>
                        <![endif]-->
                        <!--[if (IE)]>
                        </td></tr></table>
                        <![endif]-->
                      </td>
                    </tr>
                  </tbody>"""

