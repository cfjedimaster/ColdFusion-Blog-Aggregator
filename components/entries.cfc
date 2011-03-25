<cfcomponent output="false">

<cfset variables.dsn = "">

<cffunction name="init" access="public" returnType="entries" output="false">
	<cfargument name="dsn" type="string" required="true">
	<cfset variables.dsn = arguments.dsn>

	<cfreturn this>
</cffunction>

<cffunction name="addEntryIfNew" access="public" returnType="numeric" output="false">
	<cfargument name="blogidfk" type="numeric" required="true">
	<cfargument name="title" type="string" required="true">
	<cfargument name="entryurl" type="string" required="true">
	<cfargument name="posted" type="date" required="true">
	<cfargument name="content" type="string" required="true">
	<cfargument name="categories" type="string" required="true">

	<cfset var check = "">
	<cfset var insert = "">

	<cfquery name="check" datasource="#variables.dsn#">
	select	id
	from	entries
	where	blogidfk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.blogidfk#">
	and		url = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="500" value="#arguments.entryurl#">
	</cfquery>

	<cfif check.recordCount is 0>
		<cfquery datasource="#variables.dsn#" result="insert">
		insert into entries(blogidfk,title,url,posted,content,categories)
		values(
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.blogidfk#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.title,500)#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.entryurl,500)#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.posted#">,
		<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.content#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.categories,500)#">
		)
		</cfquery>
		<cfset var ids = cacheGetAllIds()>
		<cfset var id = "">
		<cfloop index="id" array="#ids#">
			<cfset cacheRemove(id, false)>
		</cfloop>
		<cfreturn insert.generated_key>
	<cfelse>
		<cfreturn 0>
	</cfif>

</cffunction>

<cffunction name="getEntry" access="public" returnType="query" output="false">
	<cfargument name="id" type="numeric" required="true">
	<cfset var q = "">
	<cfquery name="q" datasource="#variables.dsn#">
	select	id, blogidfk, title, url, posted, content, categories, created, clicks 
	from	entries
	where	id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
	</cfquery>
	<cfreturn q>
</cffunction>

<cffunction name="getEntries" access="public" returnType="struct" output="false">
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="total" type="numeric" required="false" default="10">
	<cfargument name="search" type="string" required="false" default="">
	<cfargument name="log" type="boolean" required="false" default="false">
	<cfargument name="dateafter" type="date" required="false">

	<cfset var s = structNew()>
	<cfset var q = "">
	<cfset var k = "">

	<cfset var key = "#arguments.start#_#arguments.total#_#arguments.search#">
	<cfif structKeyExists(arguments, "dateafter")>
		<cfset key &= "_#arguments.dateafter#">
	</cfif>

	<cfset var s = cacheGet(key)>
	<cfif isNull(s)>
		<cfquery name="q" datasource="#variables.dsn#">
		select	SQL_CALC_FOUND_ROWS e.url, e.title, e.posted, e.created, e.content, e.id, b.name as blog, e.categories, b.description as blogdescription, b.url as blogurl
		from	entries e, blogs b
		where	e.blogidfk = b.id
		<cfif len(trim(arguments.search))>
			and (1=0
			<cfloop index="k" list="#arguments.search#">
				or
				(
				e.title like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#k#%">
				or
				e.content like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#k#%">
				or
				e.categories like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#k#%">
				)
			</cfloop>
			)
		</cfif>
		<cfif structKeyExists(arguments,"dateafter")>
		and 	e.created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateafter#">
		</cfif>

		order by e.created desc
		limit	#arguments.start-1#,#arguments.total#
		</cfquery>
		<cfset s.entries = q>

		<cfquery name="q" datasource="#variables.dsn#">
		select found_rows() as total
		</cfquery>

		<cfset s.total = q.total>
		<cfset cachePut(key, s)>
	</cfif>

	<!--- log search --->
	<cfif len(trim(arguments.search)) and arguments.log>
		<cfset logSearch(arguments.search)>
	</cfif>

	<cfreturn s>
</cffunction>


<cffunction name="getFeedStats" access="public" returnType="struct" output="false">
	<cfargument name="id" required="false" default="" />
	<cfset var stats = structNew()>
	<cfset var q = "">
	<cfset var getentries = "">
	
	<!--- get clicks first --->
	<cfquery name="q" datasource="#variables.dsn#">	
	select sum(clicks) as totalclicks
	from entries e 
	where e.blogidfk = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />
	</cfquery>

			
	<cfset stats.totalclicks = q.totalclicks>

	<!--- get entries --->
	<cfquery name="q" datasource="#variables.dsn#">
	select	count(id) as totalentries
	from	entries
	where blogidfk = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />
	</cfquery>

	<cfset stats.totalentries = q.totalentries>
	<cfreturn stats>
</cffunction>

<cffunction name="getFeeds" access="public" returnType="query" output="false">
	<cfargument name="id" required="false" default="" />
	<cfargument name="url" required="false" default="" />
	<cfargument name="sidx" default="name" />
	<cfargument name="sord" default="asc" />
	<cfargument name="filter" default="" />
	<cfset var q = "">

	<cfquery name="q" datasource="#variables.dsn#">
	select	id, name, description, url, rssurl, status
	from	blogs
	where 1 =1
	<cfif len(trim(arguments.id))>
	and id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />
	<cfelseif len(trim(arguments.url))>
	and	url = <cfqueryparam value="#arguments.url#" cfsqltype="cf_sql_varchar" />
	</cfif>
	<cfif len(trim(arguments.filter))>
		and (lcase(name) like <cfqueryparam value="%#lcase(arguments.filter)#%" cfsqltype="cf_sql_varchar" />
		or lcase(description) like <cfqueryparam value="%#lcase(arguments.filter)#%" cfsqltype="cf_sql_varchar" />
		or lcase(url) like <cfqueryparam value="%#lcase(arguments.filter)#%" cfsqltype="cf_sql_varchar" />
		or lcase(rssurl) like <cfqueryparam value="%#lcase(arguments.filter)#%" cfsqltype="cf_sql_varchar" />)
	</cfif>
	
	order by #arguments.sidx# #arguments.sord#
	</cfquery>

	<cfreturn q>
</cffunction>

<cffunction name="createFeed" access="public" returntype="boolean" output="false">
	<cfargument name="name" required="true" />
	<cfargument name="description" required="true" />
	<cfargument name="url" required="true" />
	<cfargument name="rssurl" required="true" />
	<cfset var ins = "" />
	<cfquery name="ins" datasource="#variables.dsn#">
	insert into blogs (name,description,url,rssurl)
	values(
	<cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" />,
	<cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar" />,
	<cfqueryparam value="#arguments.url#" cfsqltype="cf_sql_varchar" />,
	<cfqueryparam value="#arguments.rssurl#" cfsqltype="cf_sql_varchar" />
	)
	</cfquery>
	<cfreturn true />
</cffunction>

<cffunction name="setStatus" access="public" returnType="void" output="false">
	<cfargument name="id" required="true">
	<cfargument name="status" required="true">

	<!--- prepend date/time --->
	<cfset arguments.status = dateFormat(now(),"short") & " " & timeFormat(now(), "short") & " " & arguments.status>

	<cfquery datasource="#variables.dsn#">
	update 	blogs
	set		status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.status,500)#">
	where	id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
	</cfquery>
</cffunction>


<cffunction name="updateFeed" access="public" returntype="boolean" output="false">
	<cfargument name="id" required="true" />
	<cfargument name="name" required="true" />
	<cfargument name="description" required="true" />
	<cfargument name="url" required="true" />
	<cfargument name="rssurl" required="true" />
	<cfset var upd = "" />
	<cfquery name="upd" datasource="#variables.dsn#">
	update blogs
	set
	name =	<cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" />,
	description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar" />,
	url = <cfqueryparam value="#arguments.url#" cfsqltype="cf_sql_varchar" />,
	rssurl = <cfqueryparam value="#arguments.rssurl#" cfsqltype="cf_sql_varchar" />
	where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />
	</cfquery>
	<cfreturn true />
</cffunction>

<cffunction name="deleteFeed" access="public" returntype="void" output="false">
	<cfargument name="id" required="true" />

	<cfquery datasource="#variables.dsn#">
	delete
	from	click_log
	where entryidfk in (select id from entries where blogidfk = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />)
	</cfquery>

	<!--- clean up entries --->
	<cfquery datasource="#variables.dsn#">
	delete from entries
	where blogidfk = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />
	</cfquery>

	<cfquery datasource="#variables.dsn#">
	delete from blogs
	where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer" />
	</cfquery>

</cffunction>

<cffunction name="getLastSearches" access="public" returnType="query" output="false">
	<cfset var q = "">

	<cfquery name="q" datasource="#variables.dsn#">
	select	searchterm
	from	search_log
	order by timestamp desc
	limit 0,10
	</cfquery>

	<cfreturn q>
</cffunction>


<cffunction name="getSearchHelp" access="remote" returnType="array" output="false">
	<cfargument name="term" type="string" required="true">

	<cfquery name="q" datasource="#variables.dsn#">
	select	distinct searchterm
	from	search_log
	where	searchterm like <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.term,255)#%">
	limit 0,10
	</cfquery>

	<cfreturn listToArray(valueList(q.searchTerm))>

</cffunction>

<cffunction name="getStats" access="public" returnType="struct" output="false">
	<cfset var q = "">
	<cfset var s = structNew()>

	<cfquery name="q" datasource="#variables.dsn#">
	select	count(id) as total
	from	blogs
	</cfquery>

	<cfset s.totalblogs = q.total>

	<cfquery name="q" datasource="#variables.dsn#">
	select	count(id) as total
	from	entries
	</cfquery>

	<cfset s.totalentries = q.total>

	<cfquery name="q" datasource="#variables.dsn#">
	select	searchterm
	from	search_log
	order by timestamp desc
	limit 0,1
	</cfquery>

	<cfset s.lastsearch = q.searchterm>

	<cfreturn s>
</cffunction>

<cffunction name="getTopEntries" access="public" returnType="query" output="false">
	<cfargument name="dateafter" type="date" required="false" hint="If passed, clicks must be after.">
	<cfset var q = "">

	<cfquery name="q" datasource="#variables.dsn#">
	select	cl.entryidfk, count(cl.entryidfk) as total,
			e.title, e.url, b.name as blog, b.url as blogurl
	from	click_log cl, entries e, blogs b
	where	cl.entryidfk = e.id
	and		e.blogidfk = b.id
	<cfif structKeyExists(arguments,"dateafter")>
	and 	e.created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateafter#">
	</cfif>
	group by entryidfk
	order by total desc
	limit 0,10
	</cfquery>

	<cfreturn q>
</cffunction>

<cffunction name="getTopSearches" access="public" returnType="query" output="false">
	<cfset var q = "">

	<cfquery name="q" datasource="#variables.dsn#">
	select	searchterm, count(searchterm) as total
	from	search_log
	group by searchterm
	order by total desc
	limit 0,10
	</cfquery>

	<cfreturn q>
</cffunction>

<cffunction name="logclick" access="public" returnType="string" output="false">
	<cfargument name="entryid" type="numeric" required="true">
	<cfset var q = "">
	<!--- ensure valid entry id --->
	<cfquery name="q" datasource="#variables.dsn#">
	select	id, url
	from	entries
	where	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.entryid#">
	</cfquery>

	<cfif q.recordCount is 1>
		<cfquery datasource="#variables.dsn#">
		insert into click_log(entryidfk)
		values(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.entryid#">)
		</cfquery>
		<cfquery datasource="#variables.dsn#">
		update entries
		set clicks = clicks+1
		where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.entryid#">
		</cfquery>
	</cfif>
	<cfreturn q.url>
</cffunction>

<cffunction name="logsearch" access="public" returnType="void" output="false">
	<cfargument name="term" type="string" required="true">

	<cfquery datasource="#variables.dsn#">
	insert into search_log(searchterm)
	values(<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.term,255)#">)
	</cfquery>

</cffunction>

</cfcomponent>