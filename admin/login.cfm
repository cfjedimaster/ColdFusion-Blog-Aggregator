<cfimport taglib="tags" prefix="ui" />
<ui:adminLayout>
<cfoutput>
	<form action="index.cfm" method="post">
	Enter the secret password of the day: <input type="password" name="adminpassword"> <input type="submit" name="adminlogin" value="Authenticate!">
	</form>
</cfoutput>
</ui:adminLayout>
