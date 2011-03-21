<!---
	Name         : login.cfm
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

<cfif structKeyExists(form, "selected") and form.selected is "login">

	<cfif len(trim(form.username)) and len(trim(form.password))>
		<cfif application.user.authenticate(form.username,form.password)>
			<cfset session.loggedin = true>
			<cfset session.user = application.user.getUserByUsername(form.username)>
			<cfoutput>1</cfoutput><cfabort>
		<cfelse>
			<cfoutput>0</cfoutput><cfabort>
		</cfif>
	<cfelse>
		<cfoutput>0</cfoutput><cfabort>
	</cfif>			

</cfif>

<script>
$(document).ready(function() {
	$("#loginForm").submit(function(e) {
		$.post("login.cfm", {
			username:$("#username").val(),
			password:$("#password").val(),
			selected:"login"}, 
			function(data,status) { 
				data = $.trim(data)
				if(data == 0) $("#errors").html("<p><b>Your username and password did not work.</b></p>")
				if(data == 1) $("#content").load("loginsuccess.cfm")
			})
			e.preventDefault()
		

	})

})
</script>
<cfoutput>

<div id="content">
	<div id="errors"></div>

	<form id="loginForm" action="login.cfm" method="post">		
	<p>			
	<label>Username</label>
	<input id="username" name="username" value="" type="text" size="30" />
	<label>Password</label>
	<input id="password" name="password" value="" type="password" size="30" />
	<br /><br />
	<input class="button" type="submit" value="Login"/>	
	<input type="hidden" name="selected" value="login">	
	</p>		
	</form>		
</div>

</cfoutput>