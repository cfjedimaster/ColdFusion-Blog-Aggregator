<!---
	Name         : 404.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Handles missing templates.
--->

<cfparam name="url.thePage" default="">

<cfif not len(trim(url.thePage))>
	<cflocation url="index.cfm" addToken="false">
</cfif>

<cf_layout title="File Not Found">

<h2>These are not the droids you are looking for...</h2>

<p>
Sorry, but the page you requested, <cfoutput>#htmlEditFormat(url.thePage)#</cfoutput>, was not
found on this site. I'm sure you really wanted to find the page. I'm sure it was
really important. But unfortunately that page doesn't mean anything to us. Such is
life, eh? But it is ok. I'm sure everything will work out fine in the end. 
</p>

</cf_layout>