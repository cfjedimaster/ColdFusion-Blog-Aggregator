<!---
	Name         : statspod.cfm
	Author       : Raymond Camden
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      :
	Purpose		 : Stats pod.
--->

<cfset stats = cacheGet("stats")>
<cfif isNull(stats)>
	<cfset stats = application.entries.getStats()>
</cfif>

<cfoutput>
<p>
Currently aggregating #stats.totalblogs# feeds, of which #randRange(1,100)#% are really groovy.
Currently storing #stats.totalentries# entries, of which #randRange(1,100)#% are #randRange(1,100)#% on topic.
Currently #application.usercount# users are wasting time instead of working.
</p>
</cfoutput>