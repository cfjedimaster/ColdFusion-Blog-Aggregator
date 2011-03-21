<!---
	Name         : layout.cfm
	Author       : Raymond Camden
	Created      : July 29, 2007
	Last Updated : August 3, 2007
	History      : Added log url param (rkc 8/3/07)
	Purpose		 : Layout custom tag.
--->

<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.title" default="">

<cfif thisTag.executionMode is "start">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta name="Description" content="A ColdFusion Blog Aggregator" />
<meta name="Keywords" content="coldfusion,blogging,coldfusion bloggers" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta name="Distribution" content="Global" />
<meta name="Robots" content="index,follow" />
<link rel="alternate" type="application/rss+xml" title="RSS" href="#application.RSSFeedURL#" />
<link rel="stylesheet" href="images/Techmania.css" type="text/css" />
<link rel="shortcut icon" href="/images/icon_016.png">
<title>#attributes.title#</title>
<script src="/js/jquery.min.js"></script>
<script src="/js/jqueryui.js"></script>
<link rel="stylesheet" href="/js/css/smoothness/jquery-ui-1.8.custom.css" type="text/css" />
<script>
function loadContent() {
	var baseurl = 'content.cfm?<cfif structKeyExists(url,"search_query")>search_query=#urlEncodedFormat(url.search_query)#</cfif>';
	if(document.location.hash != '') baseurl+= 'page='+document.location.hash.substr(1,document.location.hash.length);
	loadDiv(baseurl)
}

$(document).ready(function() {
	<cfif cgi.script_name is "/index.cfm">loadContent();</cfif>

	var dialogOpts = {
		title: "Contact",
		modal: true,
		autoOpen: false,
		position: ['center', 5],
		width: 500,
		open: function() {
			$("##contact").load("/contact.cfm");}
		};
	$("##contact").dialog(dialogOpts); 
	$("##contactLink").click(function(e) {
		$("##contact").dialog("open")
		e.preventDefault()
	})
})

function doSearch() {
	var searchvalue = $("##search_query").val();
	if(searchvalue == '') return false;
	$("##loadingmsg").show();
	//New logic:
	//If on main page, just navigate
	//Else if anywhere else, go to home with right value
	//Need to also switch to no page number
	if(document.getElementById("content") != null) {
		document.location.href = '##';
		loadDiv('content.cfm?log=1&search_query='+escape(searchvalue))
	} else document.location.href = 'index.cfm?log=1&search_query='+escape(searchvalue);
	return false;
}

function loadDiv(theurl) {
	$("##content").load(theurl,function() {
		<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>
		$("##loadingmsg").hide();
		</cfif>
		<cfif not application.dev>
		pageTracker._trackPageview(theurl);
		</cfif>
	});
}
</script>
<script src="/js/AC_OETags.js"></script>
</head>

<body>

<div id="contact"></div>

<!-- wrap starts here -->
<div id="wrap">

		<div id="header">
			<cfif cgi.script_name is "/index.cfm"><div id="loadingmsg" style="position:absolute;top:30px;left:15px;float:left;"><img src="/images/new-ajax-loader.gif" style="border:none"></div></cfif>
			<h1 id="logo-text">#application.siteTitle#</h1>
			<h2 id="slogan">#application.slogans[randRange(1,arrayLen(application.slogans))]#</h2>

			<div id="header-tabs">
				<ul>
					<li <cfif findNoCase("index.cfm",cgi.script_name)>id="current"</cfif>><a href="index.cfm"><span>Home</span></a></li>
					<li <cfif findNoCase("feeds.cfm",cgi.script_name)>id="current"</cfif>><a href="feeds.cfm"><span>Feeds</span></a></li>
					<li <cfif findNoCase("prefs.cfm",cgi.script_name)>id="current"</cfif>><a href="prefs.cfm"><span>Preferences</span></a></li>
					<li><a href="##" id="contactLink"><span>Contact</span></a></li>
					<li <cfif findNoCase("faq.cfm",cgi.script_name)>id="current"</cfif>><a href="faq.cfm"><span>FAQ</span></a></li>
					<li <cfif findNoCase("stats.cfm",cgi.script_name)>id="current"</cfif>><a href="stats.cfm"><span>Stats</span></a></li>
				</ul>
			</div>

		</div>

	  <!-- content-wrap starts here -->
	  <div id="content-wrap">

	  		<div id="main">
</cfoutput>
<cfelse>
<cfoutput>
	  		</div>

	  		<div id="sidebar">


				<h1>Search</h1>
				<form method="post" id="search" action="index.cfm" onSubmit="return doSearch()">
					<p>
					<input type="text" id="search_query" class="textbox">
					<input name="search" class="searchbutton" value="Search" type="submit" />
					</p>
				</form>

<cfif application.twitterNotification>
<p align="center">
<a href="http://twitter.com/#application.twitterUser#"><img src="/images/twitterbutton.jpg" title="Follow @#application.twitterUser#" width="150" height="150" border="0" style="border:none"/></a>
</p>
</cfif>

				<h1>About</h1>
				<p>
				<a href="index.cfm">#application.siteName#</a> runs on ColdFusion 9 with MySQL and Windows 2003
				on the back end. Depressed PHP developers are used to parse and organize
				RSS feeds into the database while Ruby coders handle the layout.
				</p>


				<h1>Stats</h1>
				<cfinclude template="statspod.cfm">


			</div>

		<!-- content-wrap ends here -->
		</div>

		<div id="footer">

			<span id="footer-left">
				Created by <strong><a href="http://www.coldfusionjedi.com">Raymond Camden</a></strong> |
				Design by: <strong><a href="http://www.styleshout.com/">styleshout</a></strong>
			</span>

			<span id="footer-right">
				<a href="index.cfm">Home</a> |  <a href="#application.RSSFeedURL#">RSS Feed</a>
			</span>

		</div>

<!-- wrap ends here -->
</div>

</body>
</html>
</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">
