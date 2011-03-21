<!---
	Name         : user.cfm
	Author       : Raymond Camden 
	Created      : August 5, 2007
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<cfset doneflag = false>
<cfset errors = "">

<cfparam name="form.name" default="#session.user.getName()#">
<cfparam name="form.email" default="#session.user.getEmail()#">

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
	
<cfform action="user.cfm" method="post">	
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
<br /><br />
<input class="button" type="submit" name="userprefs" value="Update User Details"/>		
</p>
</cfoutput>		
</cfform>		
	