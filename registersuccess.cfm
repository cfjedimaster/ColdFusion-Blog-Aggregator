
<cfif session.loggedin>

	<cfoutput>
	<p>
	Thank you for registering, #session.user.getName()#. You 
	may now <a href="prefs.cfm" style="text-decoration:underline">update your preferences</a>.
	</p>
	</cfoutput>
	
</cfif>