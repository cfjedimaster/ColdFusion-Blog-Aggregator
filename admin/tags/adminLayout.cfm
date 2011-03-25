<!---
	Name         : adminLayout.cfm
	Author       : Scott Stroz
	Created      : March 23, 2011
	Last Updated : March 23, 2011
	History      : Created (sfs 8/3/07)
	Purpose		 : Layout custom tag for admin.
--->

<cfparam name="attributes.title" default="Welcome!">

<cfif thisTag.executionMode is "start">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="includes/admin.css" media="screen" />
<script src="/js/jquery.min.js"></script>
<script src="/js/jqueryui.js"></script>
<link rel="stylesheet" href="/js/css/smoothness/jquery-ui-1.8.custom.css" type="text/css" />

<cfif NOT structKeyExists(session, "adminlogin") OR NOT session.adminLogin>
  <style type="text/css">
    body{background:none;}
  </style>
</cfif>
<title>#application.siteTitle# Admin</title>
</head>

<body>

<!--- TODO: Switch to request scope --->

<div id="menu">
<cfif structKeyExists(session, "adminlogin") AND session.adminLogin>
<ul>
<li><a href="index.cfm">Home</a></li>
<li><a href="list.cfm">Feeds</a></li>
<li><a href="userreport.cfm">User Report</a></li>
</ul>
</cfif>
</div>
<div id="content">
<div id="header">#application.siteName# Admin</div>
<div id="pageTitle">#attributes.title#</div>


</cfoutput>

<cfelse>

<cfoutput>
</div>
</body>
</html>
</cfoutput>

</cfif>

<cfsetting enablecfoutputonly=false>