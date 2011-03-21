<!---
	Name         : dailyemail.cfm
	Author       : Raymond Camden 
	Created      : August 5, 2007
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<!--- We begin by getting our subscriptions. It's possible no one is subscribed and we may not have to do anything. --->
<cfset dailyAllSubs = application.emailAlert.getDailyAllSubscribers()>
<cfset dailyTopSubs = application.emailAlert.getDailyTopSubscribers()>
<cfset onedayago = dateAdd("d", -1, now())>

<cfdump var="#dailyAllSubs#" label="Daily All Subs">
<cfdump var="#dailyTopSubs#" label="Daily Top Subs">

<!--- We have a method already for the top, it is used in the stats --->
<!--- but only get it if we need to --->

<cfif dailyTopSubs.recordCount>
	<cfset topentries = application.entries.getTopEntries(onedayago)>
	
	<cfoutput><p>I had #topentries.recordCount# entries for my 'top entries'. Sent to #dailyTopSubs.recordCount# people.</p></cfoutput>
	
	<cfif topEntries.recordCount>
	
		<cfmail query="dailyTopSubs" to="#email#" from="#application.adminemail#" subject="Top Entries from #application.siteName#">
Hello, #name#. This is your daily report from #application.siteName# of the top entries (by clicks) over the 
past 24 hours. If you want to disable this email, please logon to the site and update your preferences here:

http://#application.siteURL#/prefs.cfm

<cfloop query="topEntries">
Title:  #title# 
URL:    #url#
Blog:   #blog# (#blogurl#)
Clicks: #total#

</cfloop>
		</cfmail>

	</cfif>

</cfif>

<cfif dailyAllSubs.recordCount>
	<cfset dayentries = application.entries.getEntries(dateafter=onedayago,total=100)>
	<cfset results = duplicate(dayentries.entries)>

	<cfoutput><p>I had #results.recordCount# entries for my 'all entries'. Sent to #dailyAllSubs.recordCount# people.</p></cfoutput>

	<cfif results.recordCount>
	
		<cfmail query="dailyAllSubs" to="#email#" from="#application.adminemail#" subject="Daily Entries from #application.siteName#">
Hello, #name#. This is your daily report from #application.SiteName# of the entries over the 
past 24 hours. If you want to disable this email, please logon to the site and update your 
preferences here:

http://#application.siteURL#/prefs.cfm

<cfloop query="results">
Title:  #title# 
URL:    #url#
Blog:   #blog# (#blogurl#)

</cfloop>
		</cfmail>

	</cfif>

</cfif>