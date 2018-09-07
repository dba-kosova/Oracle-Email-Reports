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
	"ASCP":"wangj@bimba.com,naoomp@bimba.com,mcauliffem@bimba.com,SowatzkeK@bimba.com,haysg@bimba.com,makenasl@bimba.com,pottsm@bimba.com,dan.diaz@imi-precision.com",
	"ATP Check":"pottsm@bimba.com,pickeringc@bimba.com",
	"ATP Check - Move Ins":"pickeringc@bimba.com,pottsm@bimba.com,makenasl@bimba.com,lanzendorfl@bimba.com,kristin.smith@imi-precision.com",
	"BMXOrders":"""pickeringc@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com,oletae@bimba.com,martinezi@bimba.com,silvam@bimba.com,
					quirinoi@bimba.com,sowatzkek@bimba.com,david.ivan@imi-precision.com""",
	"BRDR":"""wangj@bimba.com,wehlingj@bimba.com,ScherzingerJ@bimba.com,klinea@bimba.com,nemethd@bimba.com,mcauliffem@bimba.com,maziurm@bimba.com,
					Pottsm@bimba.com,makenasl@bimba.com,haynesk@bimba.com,Roggemanns@bimba.com,HaysG@bimba.com,SowatzkeK@bimba.com,pickeringc@bimba.com,
					Shaultsb@bimba.com,LewisM@bimba.com,goldenc@bimba.com,smithm@bimba.com,carlsonn@bimba.com,fanellom@bimba.com,learn@bimba.com,
					millerb@bimba.com,qareceiving@bimba.com,smitha@bimba.com,woodt@bimba.com,meldeaus@bimba.com,LanzendorfL@bimba.com,mathisb@bimba.com,
					dan.diaz@imi-precision.com,Jasibe.alarid@imi-precision.com,maritza.gallegos@imi-precision.com, mario.ramirez@imi-precision.com""",
	"CMPHR":"pickeringc@bimba.com,haynesk@bimba.com,roggemanns@bimba.com,garciac@bimba.com,frank.salazar@imi-precision.com",
	"Cost":"churchillc@bimba.com,scheibenreifs@bimba.com,David.Harry@imi-precision.com",
	"CSD":"pickeringc@bimba.com,pottsm@bimba.com,makenasl@bimba.com,maziurm@bimba.com,bruce.mathis@imi-precision.com",
	"Errors":"pickeringc@bimba.com,gallegosm@bimba.com,jeff.buzzo@imi-precision.com",
	"Failed Pick":"pickeringc@bimba.com,smitha@bimba.com,haynesk@bimba.com,frank.salazar@imi-precision.com",
	"Inventory":"""pickeringc@bimba.com,silvam@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com,quirinoi@bimba.com,pottsm@bimba.com,
					makenasl@bimba.com,jeff.buzzo@imi-precision.com,dan.diaz@imi-precision.com,frank.salazar@imi-precision.com,david.ivan@imi-precision.com""",
	"Minmax":"makenasl@bimba.com,pottsm@bimba.com",
	"New Holds":"""pickeringc@bimba.com,pottsm@bimba.com,makenasl@bimba.com,roggemanns@bimba.com,garciac@bimba.com,mcauliffem@bimba.com,maziurm@bimba.com,
					klinea@bimba.com,nemethd@bimba.com,mathisb@bimba.com,Shaultsb@bimba.com,LewisM@bimba.com,goldenc@bimba.com,dan.diaz@imi-precision.com""",
	"Onhand_Nonshippable_Locations":"haynesk@bimba.com,pickeringc@bimba.com,welchd@bimba.com,frank.salazar@imi-precision.com,jeff.buzzo@imi-precision.com",
	"On Hold":"pickeringc@bimba.com,roggemanns@bimba.com,garciac@bimba.com",
	"Orders":"""pickeringc@bimba.com,meldeaus@bimba.com,lanzendorfl@bimba.com,haysg@bimba.com,nittim@bimba.com,doranr@bimba.com,makenasl@bimba.com,
					roggemanns@bimba.com,pottsm@bimba.com,fanellom@bimba.com,smitha@bimba.com,schippitsk@bimba.com,sowatzkek@bimba.com,wehlingj@bimba.com,
					maziurm@bimba.com,raij@bimba.com,greenquiste@bimba.com,douglask@bimba.com,carlsonn@bimba.com,norderp@bimba.com,pavlickm@bimba.com,
					manuels@bimba.com,gallegosm@bimba.com,tervow@bimba.com,schranka@bimba.com,ramirezm@bimba.com,cornejor@bimba.com,evansj@bimba.com,
					belcikm@bimba.com,basilea@bimba.com,banerjeea@bimba.com,smithk@bimba.com,garciac@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com,
					haynesk@bimba.com,dan.diaz@imi-precision.com,jeff.buzzo@imi-precision.com,david.ivan@imi-precision.com,bryan.smith@imi-precision.com,
					frank.salazar@imi-precision.com,theresa.claffy@imi-precision.com,dale.welch@imi-precision.com,brad.saxsma@imi-precision.com,ashia.sprouse@imi-precision.com""",
	"Planning":"pickeringc@bimba.com",
	"PPG":"pickeringc@bimba.com,frank.salazar@imi-precision.com",
	"Production_Planning":"pickeringc@bimba.com,patinoy@bimba.com,Jasibe.alarid@imi-precision.com",
	"Putaway":"haynesk@bimba.com,pickeringc@bimba.com,frank.salazar@imi-precision.com",
	"Quickship":"""pickeringc@bimba.com,
					christopher.pickering@imi-precision.com""",
	"aQuickship":"""roggemanns@bimba.com,greenquiste@bimba.com,pottsm@bimba.com,makenasl@bimba.com,maziurm@bimba.com,fryet@bimba.com,fanellom@bimba.com,
					haynesk@bimba.com,LewisM@bimba.com,luehrsj@bimba.com,murphyj@bimba.com,garciac@bimba.com,schippitsk@bimba.com,smitha@bimba.com,
					pickeringc@bimba.com,ramirezm@bimba.com,gallegosm@bimba.com,mathisb@bimba.com,frank.salazar@imi-precision.com""",
	"QuickshipPM":"mario.ramirez@imi-precision.com",
	"Restock":"pickeringc@bimba.com,frank.salazar@imi-precision.com",
	"Scheduling":"""pickeringc@bimba.com,gallegosm@bimba.com,lanzendorfl@bimba.com,haysg@bimba.com,pottsm@bimba.com,makenasl@bimba.com,
					schranka@bimba.com,wehlingj@bimba.com,dan.diaz@imi-precision.com,kristin.smith@imi-precision.com,jeff.buzzo@imi-precision.com""",
	"Shipments":"sowatzkek@bimba.com,lanzendorfl@bimba.com,kristin.smith@imi-precision.com,dan.diaz@imi-precision.com,christopher.pickering@imi-precision.com,frank.salazar@imi-precision.com",
	"Silkscreen":"Shaultsb@bimba.com,smitha@bimba.com,roggemanns@bimba.com,greenquiste@bimba.com,joseph.stewart@imi-precision.com",
	"Transactions":"""pickeringc@bimba.com,haynesk@bimba.com,mcauliffem@bimba.com,maziurm@bimba.com,Shaultsb@bimba.com,
					scheibenreifs@bimba.com,haysg@bimba.com,kingt@bimba.com,dan.diaz@imi-precision.com,david.harry@imi-precision.com,
					david.ivan@imi-precision.com,bryan.smith@imi-precision.com,frank.salazar@imi-precision.com,jeff.buzzo@imi-precision.com""",
	"Warroom":"pickeringc@bimba.com,haysg@bimba.com,raij@bimba.com,fanellom@bimba.com,maziurm@bimba.com,dan.diaz@imi-precision.com,murphyj@bimba.com,mathisb@bimba.com",
	"Dans_Daily":"""christopher.pickering@imi-precision.com,dan.diaz@imi-precision.com,michael.fanello@imi-precision.com,michael.maziur@imi-precision.com,
					robert.legon@imi-precision.com,jeff.buzzo@imi-precision.com,kristin.smith@imi-precision.com,mcauliffem@bimba.com,
					frank.salazar@imi-precision.com,michelle.potts@imi-precision.com,makenasl@bimba.com,raij@bimba.com,smitha@bimba.com,
					murphyj@bimba.com,mathisb@bimba.com,Mario.Ramirez@imi-precision.com,Maritza.Gallegos@imi-precision.com""",
	"test":"christopher.pickering@imi-precision.com",
	"SingleLineJobs":"christopher.pickering@imi-precision.com",
	"ErrorAddress":"christopher.pickering@imi-precision.com,gallegosm@bimba.com"
}
