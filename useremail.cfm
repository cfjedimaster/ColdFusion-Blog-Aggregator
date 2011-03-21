<!---
	Name         : useremail.cfm
	Author       : Raymond Camden 
	Created      : August 5, 2007
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<cfajaximport tags="cfform">

<cfoutput>
<p>
Welcome, #session.user.getName()#. You can use the form below to edit your settings
or select email subscriptions.
</p>
</cfoutput>

<cfparam name="form.name" default="#session.user.getName()#">
<cfparam name="form.email" default="#session.user.getEmail()#">
<cfset doneflag = false>
<cfset errors = "">

<cfif structKeyExists(form, "userprefs")>

	<cfif not len(trim(form.name))>
		<cfset errors = errors & "You must enter a name.<br />">
	<cfelse>
		<cfset form.name = htmlEditFormat(form.name)>
	</cfif>

	<cfif not len(trim(form.email)) or not isValid("email", form.email)>
		<cfset errors = errors & "You must enter a valid email address.<br />">
	</cfif>

	<cfif len(trim(form.newpassword)) and form.newpassword neq form.password2>
		<cfset errors = errors & "If you want to change your password, the confirm password must match.<br />">
	</cfif>

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
			
	<cfif errors is "">
		<cftry>
			<cfinvoke component="#application.user#" method="updateUserPreferences">
				<cfinvokeargument name="userid" value="#session.user.getID()#">
				<cfinvokeargument name="name" value="#form.name#">
				<cfinvokeargument name="email" value="#form.email#">
				<cfif len(trim(form.newpassword))>
					<cfinvokeargument name="password" value="#form.newpassword#">
				</cfif>
			</cfinvoke>
			<!--- reget the bean --->
			<cfset session.user = application.user.getUser(session.user.getID())>
			<cfset doneFlag = true>
			<cfcatch>
				<cfset errors = cfcatch.message & "<br />">
			</cfcatch>
		</cftry>
	</cfif>

</cfif>

<cfif structKeyExists(url, "deletealert") and isNumeric(url.deletealert) and url.deletealert gte 1 and round(url.deletealert) is url.deletealert>
	<cfset application.emailalert.deleteAlert(url.deletealert, session.user.getID())>
</cfif>

<cfset subtodailyall = application.emailalert.subscribedToDailyAll(session.user.getID())>
<cfset subtodailytop = application.emailalert.subscribedToDailyTop(session.user.getID())>
<cfset emailalerts = application.emailalert.getAlertsForUser(session.user.getID())>

<cfif doneFlag>
	<p>
	<b>User details updated.</b>
	</p>
</cfif>
	
<cfif len(errors)>
	<cfoutput>
	<p>
	<b>Please correct these errors:<br/>#errors#</b>
	</p>
	</cfoutput>
</cfif>
	
<form method="post">	
<cfoutput>	
<p>				
<label>Update Password</label>
<input name="newpassword" type="password" size="30" />
<label>Confirm New Password</label>
<input name="password2" type="password" size="30" />
<label>Name</label>
<input name="name" type="text" size="30" value="#form.name#" />
<label>Email Address</label>
<input name="email" type="text" size="30" value="#form.email#" />
</p>

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
	<a href="?deletealert=#id#">[Delete]</a> #keywords#<br />
	</cfloop>

</cfif>
<label>New Alert:</label>
<input name="newalert">
<br /><br />
<input class="button" type="submit" name="userprefs" value="Update User Details"/>		
</p>

</cfoutput>		
</form>		

<!---
<cflayout type="tab" style="margin-left: 10px;">

	<cflayoutarea title="User Details" source="user.cfm" />

	<cflayoutarea title="Email Subscriptions" source="email.cfm" />

</cflayout>
--->

