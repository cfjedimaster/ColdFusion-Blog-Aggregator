<!---
	Name         : rss.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Generate RSS.
--->
<cfprocessingdirective pageencoding="utf-8">
	
<!--- allow for maxentries in url --->
<cfparam name="url.max" default="10">

<cfif not isNumeric(url.max) or url.max lte 0 or round(url.max) neq url.max or url.max gt 100>
	<cfset url.max = 10>
</cfif>
<!---
<cfset data = application.entries.getEntries(url.start,application.perpage,form.search_query,log)>
--->
<!--- allow for searches --->
<cfparam name="url.search" default="">
<cfif len(url.search)>
	<cfset url.search = trim(htmleditformat(url.search))>
</cfif>

<cfset title = "#application.siteName# Feed">

<cfinvoke component="#application.entries#" method="getEntries" returnVariable="items">
	<cfinvokeargument name="start" value="1">
	<cfinvokeargument name="total" value="#url.max#">
	<cfif len(url.search)>
		<cfinvokeargument name="search" value="#url.search#">
		<cfset title &= " (Search for #url.search#)">
	</cfif>
</cfinvoke>

<cfset props = {version="rss_2.0",title=title,link="http://#application.siteURL#",description="Feed of the latest items aggregated."}>
<cfset cmap = {publisheddate = "CREATED", rsslink = "URL",  authoremail="BLOG", comments="BLOGURL" }>

<cfset items = items.entries>

<!--- clean up bad stuff --->
<!--- TODO - this is BAD code, need to use code from toXML later. --->
<cfscript>
function fixXML(s) {
	var fixedcontent = replaceList(s, "#chr(25)#,#chr(212)#,#chr(248)#,#chr(937)#,#chr(8211)#", "");
	fixedcontent = replaceList(fixedcontent,chr(8216) & "," & chr(8217) & "," & chr(8220) & "," & chr(8221) & "," & chr(8212) & "," & chr(8213) & "," & chr(8230),"',',"","",--,--,...");
	return fixedcontent;
}
</cfscript>

<cfloop query="items">
	<!---
	<cfset fixedcontent = replaceList(content, "#chr(25)#,#chr(212)#,#chr(248)#,#chr(937)#,#chr(8211)#", "")>
	<cfset fixedcontent = replaceList(fixedcontent,chr(8216) & "," & chr(8217) & "," & chr(8220) & "," & chr(8221) & "," & chr(8212) & "," & chr(8213) & "," & chr(8230),"',',"","",--,--,...")>	
	<cfset fixedtitle = replaceList(title, "#chr(25)#,#chr(212)#,#chr(248)#,#chr(937)#,#chr(8211)#", "")>
	<cfset fixedtitle = replaceList(fixedtitle,chr(8216) & "," & chr(8217) & "," & chr(8220) & "," & chr(8221) & "," & chr(8212) & "," & chr(8213) & "," & chr(8230),"',',"","",--,--,...")>
	--->	
	<cfset querySetCell(items, "content", fixXML(content), currentRow)>
	<cfset querySetCell(items, "title", fixXML(title), currentRow)>
</cfloop>

<cffeed action="create" properties="#props#" columnMap="#cmap#" query="#items#" xmlVar="result">

<cfcontent type="text/xml; charset=utf-8" reset="true"><cfoutput>#result#</cfoutput>
