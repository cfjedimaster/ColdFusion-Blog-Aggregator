<!--- First off, assume we have alerts. I could check and abort, but just get them and start looping. --->
<cfset alerts = application.emailalert.getAlerts()>

<!--- one hour ago --->
<cfset onehourago = dateAdd("h", -1, now())>

<!--- this cache stores results, in case we have N feeds with the same keyword --->
<cfset resultsCache = structNew()>

<cfloop query="alerts">
	<cfoutput>
	For #name#, I have keyword <b>#keywords#</b>.<br />
	</cfoutput>

	<cfif structKeyExists(resultsCache, keywords)>
		This exists in the cache.<br/>
		<cfset results = resultsCache[keywords]>
	<cfelse>
		<cfset results = application.entries.getEntries(total=99,search=keywords,dateafter=onehourago).entries>
		<cfset resultsCache[keywords] = results>
	</cfif>
	
	<cfif results.recordCount>
		<cfoutput>
		I found #results.recordCount# results.<br>
		</cfoutput>
		
		<cfmail to="#email#" from="#application.adminemail#" subject="#application.siteName# Email Alert [#keywords#]">
Hello, #name#. Blog entries that match your keywords, #keywords#, have been found.
If you want to disable this email, please logon to the site and update your preferences here:

http://#application.siteURL#/prefs.cfm

<cfloop query="results">
Title:  #title# 
URL:    #url#
Blog:   #blog# (#blogurl#)
</cfloop>
		</cfmail>
		
	<cfelse>
		I found no results.<br>
	</cfif>
		
</cfloop>