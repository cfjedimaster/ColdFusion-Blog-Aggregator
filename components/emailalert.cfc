<cfcomponent output="false">

<cfset variables.dsn = "">
<cfset variables.lockname = "coldfusionbloggers_emailalert">

<cffunction name="init" access="public" returnType="emailalert" output="false">
	<cfargument name="dsn" type="string" required="true">
	<cfset variables.dsn = arguments.dsn>
	
	<cfreturn this>
</cffunction>

<cffunction name="addAlert" access="public" returnType="void" output="false" hint="I add an alert.">
	<cfargument name="userid" type="numeric" required="true">
	<cfargument name="alert" type="string" required="true">
	
	<cfquery datasource="#variables.dsn#">
	insert into alerts(useridfk,keywords)
	values(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.alert#" maxlength="255">)
	</cfquery>
	
</cffunction >

<cffunction name="addDailyAll" access="public" returnType="void" output="false" hint="I add a user to the 'get All entries' listserv.">
	<cfargument name="userid" type="numeric" required="true">
	
	<!--- add if new --->
	<cflock name="#variables.lockname#" type="exclusive" timeout="30">
		
		<cfif not subscribedToDailyAll(arguments.userid)>
		
			<cfquery datasource="#variables.dsn#">
			insert into dailyall(useridfk)
			values(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">)
			</cfquery>
		
		</cfif>
		
	</cflock>
	
</cffunction>

<cffunction name="addDailyTop" access="public" returnType="void" output="false" hint="I add a user to the 'get Top entries' listserv.">
	<cfargument name="userid" type="numeric" required="true">
	
	<!--- add if new --->
	<cflock name="#variables.lockname#" type="exclusive" timeout="30">
		
		<cfif not subscribedToDailyTop(arguments.userid)>
		
			<cfquery datasource="#variables.dsn#">
			insert into dailytop(useridfk)
			values(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">)
			</cfquery>
		
		</cfif>
		
	</cflock>
	
</cffunction>

<cffunction name="deleteAlert" access="public" returnType="void" output="false" hint="I delete an alert.">
	<cfargument name="alert" type="numeric" required="true">
	<cfargument name="userid" type="numeric" required="true">
	
	<cfquery datasource="#variables.dsn#">
	delete from alerts
	where	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.alert#">
	and		useridfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>
	
</cffunction>

<cffunction name="getAlerts" access="public" returnType="query" output="false" hint="I get all email alerts. I also get related user info.">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	a.id, a.useridfk, a.keywords, u.email, u.name
	from	alerts a, users u
	where	a.useridfk = u.id
	</cfquery>

	<cfreturn q>
</cffunction>

<cffunction name="getAlertsForUser" access="public" returnType="query" output="false" hint="I get email alerts for a user.">
	<cfargument name="userid" type="numeric" required="true">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	id, useridfk, keywords
	from	alerts
	where	useridfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>

	<cfreturn q>
</cffunction>

<cffunction name="getDailyAllSubscribers" access="public" returnType="query" output="false" hint="I get all users on the 'get All entries' listserv.">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	u.name, u.email, da.useridfk
	from	dailyall da, users u
	where	da.useridfk = u.id
	</cfquery>
	
	<cfreturn q>
</cffunction>

<cffunction name="getDailyTopSubscribers" access="public" returnType="query" output="false" hint="I get all users on the 'get Top entries' listserv.">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	u.name, u.email, dt.useridfk
	from	dailytop dt, users u
	where	dt.useridfk = u.id
	</cfquery>
	
	<cfreturn q>
</cffunction>

<cffunction name="removeDailyAll" access="public" returnType="void" output="false" hint="I remove a user from the 'get All entries' listserv.">
	<cfargument name="userid" type="numeric" required="true">
	
	<cfquery datasource="#variables.dsn#">
		delete from dailyall
		where useridfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>
	
</cffunction>

<cffunction name="removeDailyTop" access="public" returnType="void" output="false" hint="I remove a user from the 'get Top entries' listserv.">
	<cfargument name="userid" type="numeric" required="true">
	
	<cfquery datasource="#variables.dsn#">
		delete from dailytop
		where useridfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>
	
</cffunction>

<cffunction name="subscribedToDailyAll" access="public" returnType="boolean" output="false" hint="I check a user's setting for  the 'get All entries' listserv.">
	<cfargument name="userid" type="numeric" required="true">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	useridfk
	from	dailyall
	where	useridfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>

	<cfreturn q.recordCount is 1>
</cffunction>

<cffunction name="subscribedToDailyTop" access="public" returnType="boolean" output="false" hint="I check a user's setting for  the 'get Top entries' listserv.">
	<cfargument name="userid" type="numeric" required="true">
	<cfset var q = "">
	
	<cfquery name="q" datasource="#variables.dsn#">
	select	useridfk
	from	dailytop
	where	useridfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
	</cfquery>

	<cfreturn q.recordCount is 1>
</cffunction>

</cfcomponent>