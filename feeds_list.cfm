<!---
	Name         : feeds_list.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Handles showing a section of feeds.
--->

<cfparam name="url.r" default="a-e">

<cfif not listLen(url.r,"-") is 2>
	<cfset url.r = "a-e">
</cfif>

<cfset first = listFirst(url.r,"-")>
<cfset last = listLast(url.r,"-")>

<cfset key = "#first#_#last#">
<cfset content = cacheGet("feedlist_#key#")>
<cfif isNull(content) or structKeyExists(url,"clearcache")>

	<cfsavecontent variable="content">
	<cfset blogs = application.entries.getFeeds()>
	<cfquery name="blogs" dbtype="query">
	select	*
	from	blogs
	where	
	<cfloop index="x" from="#asc(first)#" to="#asc(last)#">
	lower(name) like '#lcase(chr(x))#%'
		<cfif x is not asc(last)>
		or
		</cfif>
	</cfloop>
	<cfif first is "a">
		or	lower(name) not like '[a-z]%'
	</cfif>
	</cfquery>
	
	<div id="feedList">
	<cfif blogs.recordCount gte 1>
	
		<cfoutput query="blogs">
			<cfset stats = application.entries.getFeedStats(id)>
		<p>
		<a href="#blogs.url#">#name#</a><br />
		#description#
		</p>
		<p>
		Total entries aggregated: <cfif stats.totalentries is "">0<cfelse>#numberFormat(stats.totalentries)#</cfif><br />
		Total number of clicks: <cfif stats.totalclicks is "">0<cfelse>#numberFormat(stats.totalclicks)#</cfif><br />
		Average clicks per entry: 
			<cfif stats.totalentries neq "" and stats.totalclicks neq "" and stats.totalentries gt 0>
				<cfset average = stats.totalclicks/stats.totalentries>
				#numberFormat(average, "9999.99")#
			<cfelse>
			0
			</cfif>
		</p>	
		</cfoutput>
	<cfelse>
	
	<cfoutput>
	<p>
	Sorry, but I ain't got nothing to show...
	</p>
	</cfoutput>
	</div>
	</cfif>
	</cfsavecontent>
	
	<cfset cachePut("feedlist_#key#", content)>
</cfif>

<cfoutput>#content#</cfoutput>
