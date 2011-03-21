<!---
	Name         : searchhelpproxy.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Handle autosuggest for search bx.
--->

<cfif structKeyExists(url, "term") and len(trim(url.term))>
	<cfinvoke component="#application.entries#" method="getSearchHelp" term="#url.term#" returnVariable="result">
	<cfoutput>#serializeJSON(result)#</cfoutput><cfabort>
</cfif>
