import requests
from requests import session
from lxml import etree
from lxml import html
import re
import xml.etree.ElementTree as ET
import time
import os
import subprocess
from .my_settings import AGILE_PROD_URL,AGILE_PROD_URL_ITEMS,AGILE_CREDENTIALS,AGILE_HOST_NAME,AGILE_LOGIN_URL
import html as parser

def er_status(item):

    item = item.lower().strip()
    part_number = item
      
    with session() as s:

        if login(s) == "no agile": return "no agile" 

        search_page_props = search_page(s.get(AGILE_PROD_URL + '?&ajaxRequest=true&forwardToPage=true&module=QuickSearchHandler&opcode=executeQuickSearch&quickSearchSelectionObject=931&baseClassId=931&ThumbnailSearchViewMode=&QUICKSEARCH_STRING=' + part_number + '/&needAttachmentSearch=false&isLastSearchSingleObject=false&persistLastSearch=false&parentClassId=931&containerWidth=1239&objid=-1&classid=901&rnd=1508440113500'))
        print(search_page_props.status())
        return search_page_props.status()


def login(session):
    
    try:
        
        login = {'j_username': AGILE_CREDENTIALS['username']
                ,'j_password':   AGILE_CREDENTIALS['password']
                }
    
        headers = {'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
                ,'Accept-Encoding':'gzip, deflate'
                ,'Accept-Language':'en-US,en;q=0.5'
                ,'Connection':'keep-alive'
                ,'Content-Length':'1781'
                ,'Content-Type':'application/x-www-form-urlencoded'
                ,'Host':AGILE_HOST_NAME
                ,'Referer':AGILE_PROD_URL
                ,'Upgrade-Insecure-Requests':'1'
                ,'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:56.0) Gecko/20100101 Firefox/57.0'}

        timeout = 5 # seconds

        session.post(AGILE_LOGIN_URL, data = login, headers = headers,timeout=timeout)

        # open agile window
        session.get(AGILE_PROD_URL)

    except requests.exceptions.Timeout:
        return "no agile"
        pass

    except:
        return "no agile"
        pass

class search_page(object):
    def __init__(self,search):
        self.text = search.text
        self.tree=html.fromstring(search.content)   
        
    def status(self):
        try:
            return self.tree.xpath('.//dd[@id="col_1030"]/text()')[0]
        except:
            return 'error'




#er_status('ER-B-37317')
