import requests
import json
from lxml import html
import datetime
import xlsxwriter
import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from my_database import Oracle
from build_excel import build_worksheet_from_data

requests.packages.urllib3.disable_warnings()

reportName = "ATP Check - Move Ins"

def get_current_atp(item,quantity):
    
    data = json.loads(requests.get('https://www.bimba.com/configurator/index.php?pn=' + item + '&qty=' + quantity).text)
        
    if len(data) < 1:
        return str('error')
    return(data['delivery'])
    

def get_test_info(header_id, line_id):
    
    sql = """select oha.order_number
            , line_number
            , shipment_number
            , ola.ordered_item
            , ola.user_item_description
            ,decode(
                (
                    select count(1) from ont.oe_order_lines_all where header_id = oha.header_id
                        and shippable_flag                                         = 'Y'
                        and ship_set_id                                            = ola.ship_set_id group by ship_set_id
                )
                , '1', 'No Ship Set', null ,'No Ship Set', 'Ship Set') "Ship Set"
            ,(
                    select count(1)
                    from ont.oe_order_lines_all
                    where header_id     = oha.header_id
                        and shippable_flag = 'Y'
                        and ship_set_id    = ola.ship_set_id
                        and line_id       <> ola.line_id
                    group by ship_set_id
                )
                other_lines_on_ship_set
            , nvl(
                (
                    select count(1)
                    from ont.oe_order_lines_all
                    where header_id                                                    = oha.header_id
                        and shippable_flag                                                = 'Y'
                        and ship_set_id                                                   = ola.ship_set_id
                        and line_id                                                      <> ola.line_id
                        and oe_line_status_pub.get_line_status(line_id, flow_status_code) = 'Awaiting Shipping'
                    group by ship_set_id
                )
                ,0) awaiting_shipping_lines_on_set
            ,(
                    select count(1)
                    from oe_order_headers_all oeh
                    , oe_order_lines_all oel
                    , (
                            select line_id
                            , trunc(hist_creation_date) date_changed
                            , max(promise_date) promise_date
                            ,hist_created_by
                            from oe_order_lines_history
                            where 1               =1
                                and hist_created_by in ('4422', -- MG
                                '2641',                         -- MP
                                '4219',                         -- LM
                                '2775')                         -- CP
                            group by line_id
                            ,trunc(hist_creation_date)
                            ,hist_created_by
                        )
                        hist
                    where oeh.header_id = oel.header_id
                        --AND oeh.open_flag = 'Y'
                        and oeh.header_id = oha.header_id
                        --and oel.line_number                                                      = '1'
                        and oeh.booked_flag                                                      = 'Y'
                        and nvl(hist.date_changed, greatest(oeh.booked_date, oel.creation_date)) >oeh.booked_date+2
                        --and oel.open_flag = 'Y'
                        and oel.link_to_line_id is null
                        and oel.shippable_flag   = 'Y'
                        and oel.ship_from_org_id = 85
                        and oel.line_id          = hist.line_id
                        and oel.line_id          = ola.line_id
                )
                moves
            , ola.request_date
            , ola.schedule_ship_date
            , ola.promise_date
            from oe_order_lines_all ola
            , oe_order_headers_all oha
            where 1             =1
                and oha.open_flag  = 'Y'
                and oha.org_id     = 83
                and oha.header_id  = ola.header_id
                and shippable_flag = 'Y'
                
                and oha.header_id = """ + str(int(header_id)) + """
                and ola.line_id   = """ + str(int(line_id)) + """
"""

    me = Oracle()
    me.connect()

    cur = me.cursor.execute(sql)

    header1 = [i[0] for i in cur.description]

    print("getting troubleshooting data")
    for g in cur:
        return g,header1

    me.close()



def main():
    workbook_name="atp_move_ins"
    my_path = os.path.join(os.path.dirname( __file__ ),'excel')
    my_excel_path =my_path + "\\"+ workbook_name.replace(" ","_") + '.xlsx'
    workbook = xlsxwriter.Workbook(my_excel_path)

    # get 50 top sellers, non shelving, from FP and OL
    sql = """select order_number
, line_number
, shipment_number
, user_item_description
, ordered_quantity
, ola.request_date
, ola.schedule_ship_date
, ola.promise_date
, msi.full_lead_time
, APPS.XXBIM_GET_WORKING_DAYS(85,ola.request_date, ola.schedule_ship_date) old_atp
, ' ' new_date
, ' ' determination
 ,ola.header_id, ola.line_id

from oe_order_lines_all ola
, oe_order_headers_all oha
, mtl_item_categories_v cat
, mtl_system_items_b msi
where oha.header_id        = ola.header_id
    and ola.booked_flag       = 'Y'
    and oha.open_flag         = 'Y'
    and ola.open_flag         = 'Y'
    and ola.cancelled_flag    = 'N'
    and ola.shippable_flag    = 'Y'
    and ola.ship_from_org_id  = 85
    and source_type_code     <> 'EXTERNAL'
    and ola.order_source_id  <> 10 -- internal orders
    and ola.order_source_id  <> 0  -- returns
    and oha.org_id            = 83 -- booked at bimba
    and ola.ship_from_org_id  = cat.organization_id
    and cat.structure_id      = '50415'
    and ola.inventory_item_id = cat.inventory_item_id
    and exists
    (
        select *
        from wip_entities
        where project_id = ola.project_id
    )
    and shipment_number is not null
    and promise_date    is not null
    and ola.inventory_item_id = msi.inventory_item_id
    and ola.ship_from_org_id = msi.organization_id
    and APPS.XXBIM_GET_WORKING_DAYS(85,ola.request_date, ola.schedule_ship_date) > full_lead_time
    and nvl((
                        select count(1) from ont.oe_order_lines_all where header_id =
                            (
                                select header_id
                                from oe_order_lines_all
                                where line_id = ola.line_id
                            )
                            and shippable_flag = 'Y'
                            and ship_set_id    = ola.ship_set_id group by ship_set_id
                    ),'1') = 1
    and apps.ONT_OEXOEWFR_XMLP_PKG.cf_hold_valueformula(oha.header_id, ola.line_id) = 'NO'
    and ola.shipment_priority_code = 'Standard'
    --and rownum < 5
"""
    print("getting oracle data")

    me = Oracle()
    me.connect()

    cur = me.cursor.execute(sql)

    header = [i[0] for i in cur.description]

    print("getting ATP data")
    data=[]
    test_data=[]
    dataload=[]
    sda_dataload=[]
    dataload_header =['order_number', 'ENT', '*AO', '\+{PGDN}', '\%A', '\Go', 'line_number', 'ENT', '\*{TAB}', 'ENT', '\{TAB 8}','promise_date', '*SAVE', '*AT', '\{RIGHT}', '\{DOWN 2}', 'ENT', '*AO', '*AM', '*AN', '*AV', '\F']
    sda_dataload_header =['order_number', 'ENT', '*AO', '\+{PGDN}', '\%A', '\Go', 'line_number', 'ENT', '\*{TAB}', 'ENT', '\{TAB 7}','schedule_date', '*SAVE', '*AV', '\F']
    for i in cur:
        row= list(i)
        #print("request date: "+datetime.datetime.strftime(i[5],"%m/%d/%y"))
        #print("schedule date: "+datetime.datetime.strftime(i[6],"%m/%d/%y"))
        #print("old promise date: "+datetime.datetime.strftime(i[7],"%m/%d/%y"))

        atp_date = get_current_atp(i[3],str(int(i[4])))
        
        row[10] = atp_date

        print("new promise date: " + atp_date)
        print("old promise date "+ str(row[7]))
        try:
            print("part 1 " + str( datetime.datetime.strptime(atp_date, "%m/%d/%y").date()+ datetime.timedelta(days=5)))
        except:
            print("part 1 error")
        print("today " + str(datetime.datetime.today()))
        try:
            print("part 2 " + str(datetime.datetime.strptime(atp_date, "%m/%d/%y").date()- datetime.timedelta(days=3)))
        except:
            print("part 1 error")

        try:
            test1 = row[7].date() > datetime.datetime.strptime(atp_date, "%m/%d/%y").date()+ datetime.timedelta(days=5)
            print(test1)
        except Exception as e:
            print("error on test 1" + str(e))

        try:
            test1 =datetime.datetime.today().date()<datetime.datetime.strptime(atp_date, "%m/%d/%y").date()- datetime.timedelta(days=3) 
            print(test1)
        except Exception as e:
            print("error on test 2" + str(e))
        try:            
            if row[7].date() > datetime.datetime.strptime(atp_date, "%m/%d/%y").date()+ datetime.timedelta(days=5) and datetime.datetime.today().date()<datetime.datetime.strptime(atp_date, "%m/%d/%y").date()- datetime.timedelta(days=3) :
                print("new date is better")
                row[11]="new date is better"
                data.append(row)  
                troubleshooting_data = get_test_info(row[12],row[13])
                test_data.append(troubleshooting_data[0])
                

                header1 = troubleshooting_data[1]
                
                var = [str(int(row[0])), 'ENT', '*AO', '\+{PGDN}', '\%A', '\Go', str(int(row[1])) + '.' + str(int(row[2])), 'ENT', '\*{TAB}', 'ENT', '\{TAB 8}', str(atp_date), '*SAVE', '*AT', '\{RIGHT}', '\{DOWN 2}', 'ENT', '*AO', '*AM', '*AN', '*AV', '\F']
                #print(var)
                #print({row[0], 'ENT', '*AO', '\+{PGDN}', '\%A', '\Go', row[1]+'.' + row[2], 'ENT', '\*{TAB}', 'ENT', '\{TAB 8}', row[7].date(), '*SAVE', '*AT', '\{RIGHT}', '\{DOWN 2}', 'ENT', '*AO', '*AM', '*AN', '*AV', '\F'})
                dataload.append(var)
                #dataload.append([row[0], 'ENT', '*AO', '\+{PGDN}', '\%A', '\Go', row[1]+'.' + row[2], 'ENT', '\*{TAB}', 'ENT', '\{TAB 8}', row[7].date(), '*SAVE', '*AT', '\{RIGHT}', '\{DOWN 2}', 'ENT', '*AO', '*AM', '*AN', '*AV', '\F'])
                #dataload.append(dataload_header)
                #print(dataload)
                if row[6].date() > datetime.datetime.strptime(atp_date, "%m/%d/%y").date():
                    var = [str(int(row[0])), 'ENT', '*AO', '\+{PGDN}', '\%A', '\Go', str(int(row[1])) + '.' + str(int(row[2])), 'ENT', '\*{TAB}', 'ENT', '\{TAB 8}', str(atp_date), '*SAVE', '*AV', '\F']
                    sda_dataload.append(var)

            else:
                row[11]="old date is better"

        except:
            row[11]="old date is better"            
            continue

        #data.append(row)   
    build_worksheet_from_data(workbook, "atp_move_ins_data", header, data)
    build_worksheet_from_data(workbook,"move_in_test_data", header1, test_data)
    build_worksheet_from_data(workbook,"dataload_movins_pd",dataload_header,dataload)
    build_worksheet_from_data(workbook,"dataload_movins_sd",sda_dataload_header,sda_dataload)
    workbook.close()
    me.close()

    
    
    htmlTable = """<center><h3>see attachment</h3></center><br>"""
    # send the email    
    Email(reportName, htmlTable).SendMail()

try:

    main()
except BaseException as e:
    print(str(e))
    Email(reportName + ' error', "<br><center>" + str(e) + "</center>").SendMail()
    pass

