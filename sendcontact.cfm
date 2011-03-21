<cfsetting enablecfoutputonly="true">
<!---
	Name         : sendcontact.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : Sends contact information.
--->

<!--- Process form submission --->
<cfparam name="form.dname" default="">
<cfparam name="form.demail" default="">
<cfparam name="form.comments" default="">

<cfif len(trim(form.dname)) and len(trim(form.demail)) and len(trim(form.comments))>
	<cfmail to="#application.adminemail#" from="#form.demail#" subject="#application.siteTitle# Comments">
#form.comments#
	</cfmail>
<cfelse>
	<!--- Think about what to do here --->
</cfif>
