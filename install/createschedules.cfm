<cfschedule task="#application.dsn#_processalerts" action="update" URL="http://65.223.171.209/scheduled/alerts.cfm?processkey=#application.processkey#" interval="3600" operation="httprequest" startdate="#now()#" starttime="12:01 AM">

<cfschedule task="#application.dsn#_processdailyemail" action="update" URL="http://65.223.171.209/scheduled/dailyemail.cfm?processkey=#application.processkey#" interval="daily" operation="httprequest" startdate="#now()#" starttime="12:01 AM">

<cfschedule task="#application.dsn#_processprocess" action="update" URL="http://65.223.171.209/scheduled/process.cfm?processkey=#application.processkey#" interval="1800" operation="httprequest" startdate="#now()#" starttime="12:01 AM">
