<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : stats.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : The stats page.
--->

<cfset topsearches = application.entries.getTopSearches()>
<!---
Removed because people are stupid freaking idiots.
<cfset lastsearches = application.entries.getLastSearches()>
--->
<cfset onedayago = dateAdd("d", -1, now())>
<cfset topentries = application.entries.getTopEntries(onedayago)>

<cfif structKeyExists(url, "format") and url.format eq "json">
	<cfset packet = [] />
	<cfloop query="topentries">
		<cfset arrayAppend(packet, {
			title = topentries.title,
			url = topentries.blogurl,
			clicks = numberformat(topentries.total)
		}) />
	</cfloop>
	<cfcontent type="application/json" reset="true" /><cfoutput>#serializeJson(packet)#</cfoutput><cfabort/>
</cfif>

<cf_layout title="#application.siteTitle# - Stats">

<h2>Stats</h2>

<cflayout type="tab" style="margin-left: 10px;" align="center">

	<cflayoutarea title="Top Entries">
		<p>
		These are the top entries by click throughs over the past 24 hours. 
		</p>
		<p>
		<table border="1" width="90%">
			<tr>
				<th>Entry</th><th>Blog</th><th>Total</th>
			</tr>
			<cfoutput query="topentries">
			<tr>
				<td width="45%"><a href="#topentries.url#">#title#</a></td>
				<td width="45%"><a href="#blogurl#">#blog#</a></td>
				<td width="10%" align="center">#numberFormat(total)#</td>
			</tr>
			</cfoutput>
		</table>
		</p>
		<br />
	</cflayoutarea>	

	<!---
	<cflayoutarea title="Top Searches">
		<p>
		These are the top ten searches on ColdFusionBloggers.org.
		</p>
		<p>
		<table border="1" width="90%">
			<tr>
				<th>Search Term</th><th>Total</th>
			</tr>
			<cfoutput query="topsearches">
			<tr>
				<td width="90%"><a href="index.cfm?search_query=#urlEncodedFormat(searchterm)#">#searchterm#</a></td>
				<td width="10%" align="center">#numberFormat(total)#</td>
			</tr>
			</cfoutput>
		</table>
		</p>
		<br />
	</cflayoutarea>	
	--->
	
	<!---
	<cflayoutarea title="Last Searches">
		<p>
		These are the last ten searches on ColdFusionBloggers.org.
		</p>
		<p>
		<table border="1" width="90%">
			<tr>
				<th>Search Term</th>
			</tr>
			<cfoutput query="lastsearches">
			<tr>
				<td width="100%"><a href="index.cfm?search_query=#urlEncodedFormat(searchterm)#">#searchterm#</a></td>
			</tr>
			</cfoutput>
		</table>
		</p>
		<br />
	</cflayoutarea>	
	--->
	
</cflayout>

<p />

</cf_layout>