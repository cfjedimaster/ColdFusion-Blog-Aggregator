<cfcomponent>

<cffunction name="getFeeds" access="remote" returnType="struct" output="false">
	<cfargument name="page" type="numeric" required="false">
	<cfargument name="pagesize" type="numeric" required="false">
	<cfargument name="sortcol" type="string" required="false">
	<cfargument name="sortdir" type="string" required="false">
	<cfargument name="filter" type="string" required="false">
	
	<cfset results = application.entries.getFeeds()>
	
	<cfquery name="results" dbtype="query">
	select	*
	from	results
	<cfif len(trim(arguments.filter))>
	where	upper(name) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(arguments.filter)#%">
	or		upper(description) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(arguments.filter)#%">
	</cfif>
	<cfif len(arguments.sortdir) and len(arguments.sortcol)>
	order by #arguments.sortcol# #arguments.sortdir#
	</cfif>
	</cfquery>
	
	<cfreturn queryConvertForGrid(results,arguments.page,arguments.pagesize)>

</cffunction>

</cfcomponent>