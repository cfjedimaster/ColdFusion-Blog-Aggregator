<!---
	Name         : email.cfm
	Author       : Raymond Camden 
	Created      : August 5, 2007
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<cfset doneFlag = false>
<cfset errors = "">

<cfif structKeyExists(form, "selected") and form.selected is "email">

	<cfif not structKeyExists(form, "dailyall")>
		<cfset application.emailalert.removeDailyAll(session.user.getID())>
	<cfelse>
		<cfset application.emailalert.addDailyAll(session.user.getID())>	
	</cfif>

	<cfif not structKeyExists(form, "dailytop")>
		<cfset application.emailalert.removeDailyTop(session.user.getID())>
	<cfelse>
		<cfset application.emailalert.addDailyTop(session.user.getID())>	
	</cfif>
	
	<cfif len(trim(form.newalert))>
		<cfset application.emailalert.addAlert(session.user.getID(), trim(left(form.newalert,255)))>
	</cfif>
	
	<cfset doneFlag = true>

</cfif>

<cfif structKeyExists(url, "deletealert") and isNumeric(url.deletealert) and url.deletealert gte 1 and round(url.deletealert) is url.deletealert>
	<cfset application.emailalert.deleteAlert(url.deletealert, session.user.getID())>
</cfif>

<cfset subtodailyall = application.emailalert.subscribedToDailyAll(session.user.getID())>
<cfset subtodailytop = application.emailalert.subscribedToDailyTop(session.user.getID())>
<cfset emailalerts = application.emailalert.getAlertsForUser(session.user.getID())>

<cfif doneFlag>
	<p>
	<b>Email preferences updated.</b>
	</p>
</cfif>

<cfoutput>
	
<cfif len(errors)>
	<p>
	<b>Please correct these errors:<br/>#errors#</b>
	</p>
</cfif>
	
<cfform action="email.cfm" method="post">		
<p>				
<label>Subscribe to daily email (all entries):</label>
<input name="dailyall" value="" type="checkbox" <cfif subtodailyall>checked</cfif> /> Yes
<label>Subscribe to daily email (top 10 entries):</label>
<input name="dailytop" value="" type="checkbox"  <cfif subtodailytop>checked</cfif> /> Yes
</p>

<p>
<b>Email Alerts:</b><br />
The following lists your email alerts. When #application.siteName# finds a blog entry
that matches your keyword, an email will be sent. #application.siteName# will check your
alerts once an hour.
</p>

<p>
<cfif emailalerts.recordCount is 0>

	You do not have any alerts yet.<br />

<cfelse>

	<cfloop query="emailalerts">
	<a href="#ajaxLink('email.cfm?deletealert=#id#')#">[Delete]</a> #keywords#<br />
	</cfloop>

</cfif>
<label>New Alert:</label>
<input name="newalert">
</p>

<p>
<input class="button" type="submit" value="Update"/>	
<input type="hidden" name="selected" value="email">	
</p>		
</cfform>		
</cfoutput>	
