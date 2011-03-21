<!---
	Name         : register.cfm
	Author       : Raymond Camden 
	Created      : August 5, 2007
	Last Updated : 
	History      : 
	Purpose		 : 
--->

<cfset errors = "">
<cfparam name="form.username" default="">
<cfparam name="form.name" default="">
<cfparam name="form.email" default="">

<cfif structKeyExists(form, "selected") and form.selected is "register">

	<cfif not len(trim(form.username))>
		<cfset errors = errors & "You must enter a username.<br />">
	<cfelseif reFind("[^a-zA-Z0-9]", form.username)>
		<cfset errors = errors & "Usernames can contain only numbers and letters.<br />">
	</cfif>	

	<cfif not len(trim(form.password))>
		<cfset errors = errors & "You must enter a password.<br />">
	</cfif>

	<cfif not len(trim(form.name))>
		<cfset errors = errors & "You must enter a name.<br />">
	<cfelse>
		<cfset form.name = htmlEditFormat(form.name)>
	</cfif>

	<cfif not len(trim(form.email)) or not isValid("email", form.email)>
		<cfset errors = errors & "You must enter a valid email address.<br />">
	</cfif>
	
	<cfif errors is "">
		<cftry>
			<cfset id = application.user.registerUser(form.username, form.password, form.name, form.email)>
			<cfset session.loggedin = true>
			<cfset session.user = application.user.getUser(id)>
			<cfoutput>1</cfoutput><cfabort>
			<cfcatch>
				<cfset errors = cfcatch.message & "<br />">
			</cfcatch>
		</cftry>
	</cfif>
	<cfif len(errors)>
		<cfoutput>#errors#</cfoutput><cfabort>
	</cfif>

</cfif>

<script>
$(document).ready(function() {
	$("#registerForm").submit(function(e) {
		$.post("register.cfm", {
			username:$("#username_r").val(),
			password:$("#password_r").val(),
			name:$("#name").val(),
			email:$("#email").val(),
			selected:"register"}, 
			function(data,status) { 
				data = $.trim(data)
				if(data == 1) $("#content_r").load("registersuccess.cfm")
				else $("#errors_r").html("<p><b>"+data+"</b></p>")
			})
			e.preventDefault()
		

	})

})
</script>

<cfoutput>

<div id="content_r">
	<div id="errors_r"></div>

	<p>
	Note that all form fields are required.
	</p>

	
	<form action="register.cfm" method="post" id="registerForm">		
	<p>				
	<label>Username</label>
	<input id="username_r" name="username" type="text" size="30"  value="#form.username#"/>
	<label>Password</label>
	<input id="password_r" name="password" type="password" size="30" />
	<label>Name</label>
	<input id="name" name="name" type="text" size="30" value="#form.name#" />
	<label>Email Address</label>
	<input id="email" name="email" type="text" size="30" value="#form.email#" />
	<br /><br />
	<input class="button" type="submit" value="Register"/>		
	<input type="hidden" name="selected" value="register">	
	</p>		
	</form>		
</div>
</cfoutput>
