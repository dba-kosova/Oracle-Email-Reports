import sys
import os.path
sys.path.append(os.path.join(os.path.dirname( __file__ ),'functions'))
from my_email import Email
from my_oracle import Oracle


me = Oracle()
me.connect()
data = me.cursor.execute('select sysdate from dual')
header1 = [i[0] for i in data.description]


print(header1)
    
for g in data:
    print(g,header1)

print(data )
me.close()