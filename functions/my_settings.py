# my_settings.py

"""
	.gitignore
	@author: Christopher Pickering
	used to store password and sensitive info

"""

email_settings = {
	'address':'10.100.16.16:25',
	'default_sender':'mail.relay@imi-precision.com',
	'reply_to':'scheduling@imi-precision.com'
}

ora_con_str = {
	'UserName':'apps_ro',
    'Password':'app5_ro',
    'TNS':'BMCCORE'
}

msql_con_str = {
	'UserName':'PPG',
    'Password':'P@w3rP!ck',
    'TNS':'MSSQL'
}

subscriptions = {
	"orders":"christopher.pickering@imi-precision.com",
	"ascp":"wangj@bimba.com,naoomp@bimba.com,mcauliffem@bimba.com,SowatzkeK@bimba.com,haysg@bimba.com,makenasl@bimba.com,pottsm@bimba.com,dan.diaz@imi-precision.com",
	"atp check":"pottsm@bimba.com,pickeringc@bimba.com",
	"atp check - move ins":"pickeringc@bimba.com,pottsm@bimba.com,makenasl@bimba.com,lanzendorfl@bimba.com,kristin.smith@imi-precision.com",
	"bmxorders":"""pickeringc@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com,oletae@bimba.com,martinezi@bimba.com,silvam@bimba.com,
					quirinoi@bimba.com,sowatzkek@bimba.com,david.ivan@imi-precision.com""",
	"brdr":"""wangj@bimba.com,wehlingj@bimba.com,ScherzingerJ@bimba.com,klinea@bimba.com,nemethd@bimba.com,mcauliffem@bimba.com,maziurm@bimba.com,
					Pottsm@bimba.com,makenasl@bimba.com,haynesk@bimba.com,Roggemanns@bimba.com,HaysG@bimba.com,SowatzkeK@bimba.com,pickeringc@bimba.com,
					Shaultsb@bimba.com,LewisM@bimba.com,goldenc@bimba.com,smithm@bimba.com,carlsonn@bimba.com,fanellom@bimba.com,learn@bimba.com,
					millerb@bimba.com,qareceiving@bimba.com,smitha@bimba.com,woodt@bimba.com,meldeaus@bimba.com,LanzendorfL@bimba.com,mathisb@bimba.com,
					dan.diaz@imi-precision.com,Jasibe.alarid@imi-precision.com,maritza.gallegos@imi-precision.com, mario.ramirez@imi-precision.com""",
	"cmphr":"pickeringc@bimba.com,haynesk@bimba.com,roggemanns@bimba.com,garciac@bimba.com,frank.salazar@imi-precision.com",
	"cost":"churchillc@bimba.com,scheibenreifs@bimba.com,David.Harry@imi-precision.com",
	"csd":"pickeringc@bimba.com,pottsm@bimba.com,makenasl@bimba.com,maziurm@bimba.com,bruce.mathis@imi-precision.com",
	"errors":"pickeringc@bimba.com,gallegosm@bimba.com,jeff.buzzo@imi-precision.com",
	"failed pick":"pickeringc@bimba.com,smitha@bimba.com,haynesk@bimba.com,frank.salazar@imi-precision.com",
	"inventory":"""pickeringc@bimba.com,silvam@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com,quirinoi@bimba.com,pottsm@bimba.com,
					makenasl@bimba.com,jeff.buzzo@imi-precision.com,dan.diaz@imi-precision.com,frank.salazar@imi-precision.com,david.ivan@imi-precision.com""",
	"minmax":"makenasl@bimba.com,pottsm@bimba.com",
	"new holds":"""pickeringc@bimba.com,pottsm@bimba.com,makenasl@bimba.com,roggemanns@bimba.com,garciac@bimba.com,mcauliffem@bimba.com,maziurm@bimba.com,
					klinea@bimba.com,nemethd@bimba.com,mathisb@bimba.com,Shaultsb@bimba.com,LewisM@bimba.com,goldenc@bimba.com,dan.diaz@imi-precision.com""",
	"onhand nonshippable locations":"haynesk@bimba.com,pickeringc@bimba.com,welchd@bimba.com,frank.salazar@imi-precision.com,jeff.buzzo@imi-precision.com",
	"on hold":"pickeringc@bimba.com,roggemanns@bimba.com,garciac@bimba.com",
	"aorders":"""pickeringc@bimba.com,meldeaus@bimba.com,lanzendorfl@bimba.com,haysg@bimba.com,nittim@bimba.com,doranr@bimba.com,makenasl@bimba.com,
					roggemanns@bimba.com,pottsm@bimba.com,fanellom@bimba.com,smitha@bimba.com,schippitsk@bimba.com,sowatzkek@bimba.com,wehlingj@bimba.com,
					maziurm@bimba.com,raij@bimba.com,greenquiste@bimba.com,douglask@bimba.com,carlsonn@bimba.com,norderp@bimba.com,pavlickm@bimba.com,
					manuels@bimba.com,gallegosm@bimba.com,tervow@bimba.com,schranka@bimba.com,ramirezm@bimba.com,cornejor@bimba.com,evansj@bimba.com,
					belcikm@bimba.com,basilea@bimba.com,banerjeea@bimba.com,smithk@bimba.com,garciac@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com,
					haynesk@bimba.com,dan.diaz@imi-precision.com,jeff.buzzo@imi-precision.com,david.ivan@imi-precision.com,bryan.smith@imi-precision.com,
					frank.salazar@imi-precision.com,theresa.claffy@imi-precision.com,dale.welch@imi-precision.com,brad.saxsma@imi-precision.com,ashia.sprouse@imi-precision.com""",
	"planning":"pickeringc@bimba.com",
	"ppg":"pickeringc@bimba.com,frank.salazar@imi-precision.com",
	"production planning":"pickeringc@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com",
	"putaway":"haynesk@bimba.com,pickeringc@bimba.com,frank.salazar@imi-precision.com",
	"quickship":"""roggemanns@bimba.com,greenquiste@bimba.com,pottsm@bimba.com,makenasl@bimba.com,maziurm@bimba.com,fryet@bimba.com,fanellom@bimba.com,
					haynesk@bimba.com,LewisM@bimba.com,luehrsj@bimba.com,murphyj@bimba.com,garciac@bimba.com,schippitsk@bimba.com,smitha@bimba.com,
					pickeringc@bimba.com,ramirezm@bimba.com,gallegosm@bimba.com,mathisb@bimba.com,frank.salazar@imi-precision.com""",
	"quickshippm":"mario.ramirez@imi-precision.com",
	"restock":"pickeringc@bimba.com,frank.salazar@imi-precision.com",
	"scheduling":"""pickeringc@bimba.com,gallegosm@bimba.com,lanzendorfl@bimba.com,haysg@bimba.com,pottsm@bimba.com,makenasl@bimba.com,
					schranka@bimba.com,wehlingj@bimba.com,dan.diaz@imi-precision.com,kristin.smith@imi-precision.com,jeff.buzzo@imi-precision.com""",
	"shipments":"sowatzkek@bimba.com,lanzendorfl@bimba.com,kristin.smith@imi-precision.com,dan.diaz@imi-precision.com,christopher.pickering@imi-precision.com,frank.salazar@imi-precision.com",
	"silkscreen":"Shaultsb@bimba.com,smitha@bimba.com,roggemanns@bimba.com,greenquiste@bimba.com,joseph.stewart@imi-precision.com",
	"transactions":"""pickeringc@bimba.com,haynesk@bimba.com,mcauliffem@bimba.com,maziurm@bimba.com,Shaultsb@bimba.com,
					scheibenreifs@bimba.com,haysg@bimba.com,kingt@bimba.com,dan.diaz@imi-precision.com,david.harry@imi-precision.com,
					david.ivan@imi-precision.com,bryan.smith@imi-precision.com,frank.salazar@imi-precision.com,jeff.buzzo@imi-precision.com""",
	"warroom":"pickeringc@bimba.com,haysg@bimba.com,raij@bimba.com,fanellom@bimba.com,maziurm@bimba.com,dan.diaz@imi-precision.com,murphyj@bimba.com,mathisb@bimba.com",
	"dans daily":"""christopher.pickering@imi-precision.com,dan.diaz@imi-precision.com,michael.fanello@imi-precision.com,michael.maziur@imi-precision.com,
					robert.legon@imi-precision.com,jeff.buzzo@imi-precision.com,kristin.smith@imi-precision.com,mcauliffem@bimba.com,
					frank.salazar@imi-precision.com,michelle.potts@imi-precision.com,makenasl@bimba.com,raij@bimba.com,smitha@bimba.com,
					murphyj@bimba.com,mathisb@bimba.com,Mario.Ramirez@imi-precision.com,Maritza.Gallegos@imi-precision.com""",
	"test":"christopher.pickering@imi-precision.com",
	"singlelinejobs":"christopher.pickering@imi-precision.com",
	"ErrorAddress":"christopher.pickering@imi-precision.com,gallegosm@bimba.com"
}
