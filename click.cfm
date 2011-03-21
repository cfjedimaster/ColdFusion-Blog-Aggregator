<!---
	Name         : click.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Handle click tracking.
--->

<!--- Lotsa validation --->
<cfif not structKeyExists(url, "entry") or not len(trim(url.entry)) or not isNumeric(url.entry) or url.entry lte 0 or round(url.entry) neq url.entry>
	<cflocation url="index.cfm" addToken="false">
</cfif>
<!--- This was removed to handle shorter urls for twittering --->
<!---
<cfif not structKeyExists(url, "entryurl") or not len(trim(url.entryurl))>
	<cflocation url="index.cfm" addToken="false">
</cfif>
--->

<!--- Log the click --->
<cfset theurl = application.entries.logclick(url.entry)>

<!--- push em along --->
<cflocation url="#theurl#" addToken="false">
