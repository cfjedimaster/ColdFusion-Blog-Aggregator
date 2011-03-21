<cfcomponent output="false">

<cfset variables.dsn = "">
<cfset variables.lockname = "coldfusionbloggers_user">

<cffunction name="init" access="public" returnType="user" output="false">
	<cfargument name="dsn" type="string" required="true">
	<cfset variables.dsn = arguments.dsn>
	
	<cfreturn this>
</cffunction>

<cffunction name="authenticate" access="public" returnType="boolean" output="false">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">

	<cfquery name="q" datasource="#variables.dsn#">
	select	id
	from	users
	where	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#" maxlength="255">	
	and		password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.password)#" maxlength="255">
	</cfquery>

	<cfreturn q.recordCount is 1>
	
</cffunction>

<cffunction name="getUser" access="public" returnType="userbean" output="false">
	<cfargument name="userid" type="numeric" required="true">
	<cfset var q = "">
	<cfset var bean = createObject("component", "userbean")>
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	id, username, password, name, email
	from	users
	where	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">	
	</cfquery>

	<cfset bean.setid(id=q.id)>
	<cfset bean.setusername(username=q.username)>
	<cfset bean.setpassword(password=q.password)>
	<cfset bean.setname(name=q.name)>
	<cfset bean.setemail(email=q.email)>
	<cfreturn bean>
		
</cffunction>

<cffunction name="getUserByUsername" access="public" returnType="userbean" output="false">
	<cfargument name="username" type="string" required="true">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	id
	from	users
	where	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#" maxlength="255">	
	</cfquery>

	<cfif q.recordCount is 1>
		<cfreturn getUser(q.id)>
	<cfelse>
		<cfthrow message="User doesn't exist.">
	</cfif>
		
</cffunction>

<cffunction name="registerUser" access="public" returnType="numeric" output="false">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfset var result = "">
	
	<!--- ensure new user --->
	<cflock name="#variables.lockname#" type="exclusive" timeout="30">
		<cfif userExists(arguments.username)>
			<cfthrow message="This user already exists.">
		</cfif>	
		
		<cfquery datasource="#variables.dsn#" result="result">
		insert into users(username,password,name,email)
		values(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#" maxlength="255">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.password)#" maxlength="255">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" maxlength="255">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#" maxlength="255">
		)
		</cfquery>
		<cfreturn result.generated_key>
	</cflock>
</cffunction>

<cffunction name="updateUserPreferences" access="public" returnType="void" output="false" hint="Public side to update a user.">
	<cfargument name="userid" type="numeric" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfargument name="password" type="string" required="false">
	
	<cfquery datasource="#variables.dsn#">
	update	users
	set		name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" maxlength="255">,
			email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#" maxlength="255">
	<cfif structKeyExists(arguments, "password") and len(arguments.password)>
			,password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.password)#" maxlength="255">
	</cfif>
	where	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>
	
</cffunction>

<cffunction name="userExists" access="private" returnType="boolean" output="false">
	<cfargument name="username" type="string" required="true">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	id
	from	users
	where	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#" maxlength="255">
	</cfquery>
	
	<cfreturn q.recordCount is 1>
</cffunction>

</cfcomponent>