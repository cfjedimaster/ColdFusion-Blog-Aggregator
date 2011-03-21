<!---
	Name         : prefs.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Preferences page. To be developed.
--->

<cf_layout title="#application.siteTitle# - Preferences">

	<h2>Preferences</h2>

<cfif not session.loggedin>

	<cfinclude template="loginregister.cfm">

<cfelse>

	<cfinclude template="useremail.cfm">
	
</cfif>

</cf_layout>