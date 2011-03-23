<cfif structKeyExists(url, "page") and isNumeric(url.page)>
	<cfset url.start = (url.page-1) * request.perpage + 1>
</cfif>

<cfparam name="url.start" default="1">

<cfif not isNumeric(url.start) or url.start lte 0 or url.start neq round(url.start)>
	<cfset url.start = 1>
</cfif>
<!--- to do - support search on mobile
<cfif structKeyExists(url, "search_query")>
	<cfset form.search_query = url.search_query>
</cfif>
<cfif structKeyExists(form, "search_query") and len(trim(form.search_query))>
	<cfset form.search_query = left(trim(htmlEditFormat(form.search_query)),255)>
	<!--- was it a search we want to log? --->
	<cfif structKeyExists(url, "log")>
		<cfset log = true>
	<cfelse>
		<cfset log = false>
	</cfif>
	<cfset data = application.entries.getEntries(url.start,request.perpage,form.search_query,log)>
<cfelse>
	<cfset data = application.entries.getEntries(url.start,request.perpage)>
</cfif>
--->
<cfset data = application.entries.getEntries(url.start,request.perpage)>
<cfset entries = data.entries>
<!DOCTYPE html>
<html>

<head>
<cfoutput><title>#application.siteTitle# Mobile</title></cfoutput>
<link rel="stylesheet" href="http://code.jquery.com/mobile/1.0a3/jquery.mobile-1.0a3.min.css" />
<script src="http://code.jquery.com/jquery-1.5.min.js"></script>
<script src="http://code.jquery.com/mobile/1.0a3/jquery.mobile-1.0a3.min.js"></script>
</head>

<body>

<div data-role="page" id="intro">

	<div data-role="header">
	<cfoutput><h1>#application.siteTitle# Mobile</h1></cfoutput>
	</div>

	<div data-role="content">
		<ul data-role="listview" data-split-icon="gear">
		<cfoutput query="entries">
			<cfset myurl = listFirst(entries.url)>
			<li>
			<a href="display.cfm?entry=#id#">#title#</a>
			<a href="/click.cfm?entry=#id#&entryurl=#urlEncodedFormat(myurl)#" data-rel="dialog" rel="external">View Full Entry</a>
			</li>
		</cfoutput>
		</ul>
	</div>

	<div data-role="footer">
		<h4>Created by Raymond Camden, coldfusionjedi.com</h4>
	</div>

</div>

<cfif not application.dev>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-70863-11");
pageTracker._initData();
pageTracker._trackPageview();
</script>
</cfif>
</body>
</html>