<cfquery name="totalusers">
select 	count(username) as total
from	users
</cfquery>

<cfquery name="totalalerts">
select 	count(id) as total
from	alerts
</cfquery>

<cfquery name="totalall">
select 	count(useridfk) as total
from	dailyall
</cfquery>
<cfquery name="totaltop">
select 	count(useridfk) as total
from	dailytop
</cfquery>

<cfoutput>
Total ## of users: #totalusers.total#<br/>
Total ## of alerts: #totalalerts.total#<br/>
Total subscribed to ALL: #totalall.total#<br/>
Total subscribed to TOP: #totaltop.total#<br/>
</cfoutput>