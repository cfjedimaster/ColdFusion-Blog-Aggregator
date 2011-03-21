<cfcomponent displayname="proxy for the entries component (for ajaxy goodness)">
	<cffunction name="getComponent" access="private" returntype="components.entries" output="false">
		<cfreturn application.entries />
	</cffunction>
	
	<cffunction name="getFeeds" access="remote" output="false" returntype="struct">
		<cfargument name="cfgridpage">
		<cfargument name="cfgridpageSize">
		<cfargument name="cfgridsortcolumn" default="" />
		<cfargument name="cfgridsortdirection" default="" />
		<cfargument name="filter" default="" />
		<cfset var q = getComponent().getFeeds() />
		<cfset var qofq = "" />
		
		<cfquery name="qofq" dbtype="query">
		select	id, name, description, url, rssurl, status, 
		'<a href="javascript:getFeedWin('+cast(id as varchar)+');">Edit</a>&nbsp;&bull;&nbsp;<a href="javascript:delFeed('+cast(id as varchar)+');">Delete</a>' as feedAction
		from	q
		where 1 = 1
		<cfif len(trim(arguments.filter))>
		and (name like <cfqueryparam value="%#arguments.filter#%" cfsqltype="cf_sql_varchar" />
		or description like <cfqueryparam value="%#arguments.filter#%" cfsqltype="cf_sql_varchar" />
		or url like <cfqueryparam value="%#arguments.filter#%" cfsqltype="cf_sql_varchar" />
		or rssurl like <cfqueryparam value="%#arguments.filter#%" cfsqltype="cf_sql_varchar" />)
		</cfif>

		<cfif len(arguments.cfgridsortcolumn) and len(arguments.cfgridsortdirection)>
		order by #arguments.cfgridsortcolumn# #arguments.cfgridsortdirection#
		</cfif>
		</cfquery>
		
		<cfreturn queryConvertForGrid(qofq, cfgridpage, cfgridpageSize) />
	</cffunction>
	
	<cffunction name="deleteFeed" access="remote" output="false" returntype="void">
		<cfargument name="id" required="true" />
		<cfset getComponent().deleteFeed(arguments.id) />
	</cffunction>
	
</cfcomponent>