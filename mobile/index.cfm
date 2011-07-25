<cfparam name="url.start" default="1">

<cfif not isNumeric(url.start) or url.start lte 0 or url.start neq round(url.start)>
	<cfset url.start = 1>
</cfif>

<cfset data = application.entries.getEntries(url.start,request.perpage)>
<cfset entries = data.entries>
<!DOCTYPE html>
<html>

<head>
<meta name="viewport" content="width=device-width, initial-scale=1">	
<cfoutput><title>#application.siteTitle# Mobile</title></cfoutput>
<link rel="stylesheet" href="http://code.jquery.com/mobile/1.0b1/jquery.mobile-1.0b1.min.css" />
<script src="http://code.jquery.com/jquery-1.6.1.min.js"></script>
<script src="http://code.jquery.com/mobile/1.0b1/jquery.mobile-1.0b1.min.js"></script>
<style>
.ui-icon-blogger-leave {
	background: url("/images/iconExternal.png") no-repeat rgba(0, 0, 0, 0.4);
}
</style>
</head>

<body>

<div data-role="page" id="intro">

	<div data-role="header" data-backbtn="false">
	<a href="http://#application.siteUrl#/index.cfm?nomobile=1" class="ui-btn-right" rel="external" data-icon="blogger-leave" data-iconpos="notext">Leave Mobile</a>		
	<cfoutput><h1>#application.siteTitle#  Mobile [#url.start#-#url.start+request.perpage-1#]</h1></cfoutput>
	</div>

	<div data-role="content">
		<ul data-role="listview" data-split-icon="gear">
		<cfoutput query="entries" >
			<cfset myurl = listFirst(entries.url)>
			<li>
			<a href="display.cfm?entry=#id#">#title#</a>
			<a href="/click.cfm?entry=#id#&entryurl=#urlEncodedFormat(myurl)#" data-rel="dialog" rel="external">View Full Entry</a>
			</li>
		</cfoutput>
		</ul>
	</div>
		<div data-role="controlgroup" data-type="horizontal" align="center">
			<cfoutput>
			<cfif url.start gt 1>
			<a href="index.cfm?start=#max(url.start-request.perpage,1)#" data-role="button" data-theme="b">Previous</a> 
			<cfelse>
			<a href="" data-role="button">Previous</a>
			</cfif>
			<cfif url.start + request.perpage lt data.total>
			<a href="index.cfm?start=#url.start+request.perpage#" data-role="button" data-theme="b">Next</a>
			<cfelse>
			<a href="" data-role="button">Next</a>
			</cfif>
			</cfoutput>
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