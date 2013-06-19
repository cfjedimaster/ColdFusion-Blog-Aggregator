<cfcomponent output="false">

	<cfset this.name = "myaggregator">
	<cfset this.sessionManagement = "true">
	<cfset this.scriptProtect = "false">
	<cfset this.datasource = "myaggregator">
	<cfsetting showdebugoutput="false">

	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<!--- config info --->
		<cfset application.dsn = "myaggregator">
		<cfset application.siteName = "ColdFusionBloggers.org" />
		<cfset application.siteTitle = "ColdFusionBloggers" />
		<cfset application.siteURL = "www.coldfusionbloggers.org" />
		<cfset application.alternateSiteNames = "cfbloggers.org, www.cfbloggers.org" />
		<cfset application.RSSFeedURL = "http://feedproxy.google.com/ColdfusionbloggersorgFeed" />
		<cfset application.twitterUser = "cfbloggers" />
		<cfset application.perpage = 10>
		<cfset application.adminemail = "test@test.com.com">
		<cfset application.processkey = "changeme">
		<cfset application.slogans = ["PHP is free - but so are farts","because coldfusion bloggers can't shut up","because coldfusion bloggers love to blog","because coldfusion bloggers aren't paranoid... really","because a phpbloggers site would be silly","this slogan for rent","building sites better and faster","coldfusion - the best dead language","visit the wishlist or the site dies!"] />
		<cfset application.dev = false>
		
		<cfset application.twitterNotification = true />
		<cfset application.oAuth = {consumerKey = 'changeme', 
									consumerSecret = 'oriwontwork', 
									accessToken = "hopeyoureadthis",
									accessTokenSecret = "ditto"} />
		
		<!--- end config info --->
		
		<!--- used to see if we are local. Yes, I have dev above. Going to keep this anyway.  --->
		<cfif findNoCase("dev", cgi.server_name)>
			<cfset application.localserver = true>
		<cfelse>
			<cfset application.localserver = false>
		</cfif>	
		
		<cfset application.aggregator = createObject("component", "components.aggregator")>
		<cfset application.emailalert = createObject("component", "components.emailalert").init(application.dsn)>
		<cfset application.entries = createObject("component", "components.entries").init(application.dsn)>
		<cfset application.user = createObject("component", "components.user").init(application.dsn)>
		<cfset application.toxml = createObject("component", "components.toxml")>
		<cfset application.rss = createObject("component", "components.rss")>

		<cfset var root = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfif application.twitterNotification>
			<cfscript>
				application.objMonkehTweet = createObject('component', 'components.coldfumonkeh.monkehTweet').init(
				consumerKey = '#application.oAuth.consumerKey#',
				consumerSecret = '#application.oAuth.consumerSecret#',
				oauthToken			=	'#application.oAuth.accessToken#',
				oauthTokenSecret	=	'#application.oAuth.accessTokenSecret#',
				userAccountName		=	'#application.twitterUser#',
				parseResults = true
				);
				return true;
			</cfscript>		
		</cfif>
		<cfset application.utils = createObject("component", "components.utils")>
				
		<cfset application.usercount = 0>
				
		<cfset application.rsscache = structNew()>
		<cfset application.opmlcache = "">
		
		<!--- clear cache --->
		<cfset var ids = cacheGetAllIds()>
		<cfset var id = "">
		<cfloop index="id" array="#ids#">
			<cfif findNoCase("feedlist", id)>
				<cfset cacheRemove(id)>
			</cfif>
		</cfloop>
		<cfreturn true>
	</cffunction>

	<cffunction name="onApplicationEnd" returnType="void" output="false">
		<cfargument name="applicationScope" required="true">
	</cffunction>

	<cffunction name="onMissingTemplate" returnType="boolean" output="false">
		<cfargument name="thePage" type="string" required="true">
		<cflocation url="/404.cfm?thepage=#urlEncodedFormat(arguments.thePage)#" addToken="false" statusCode="301">
	</cffunction>

	<cffunction name="onRequestStart" returnType="boolean" output="false">
		<cfargument name="thePage" type="string" required="true">

		<cfif structKeyExists(url,"reinit")>
			<cfset onApplicationStart()>
		</cfif>

		<cfif structKeyExists(url, "logout")>
			<cfset session.loggedin = false>
			<cfset structDelete(session, "user")>
			<cflocation url="index.cfm" addToken="false">
		</cfif>

		<!--- support ?c=X urls for shorter click.cfm requests --->
		<cfif structKeyExists(url, "c") and isNumeric(url.c)>
			<cflocation url="http://#application.siteUrl#/click.cfm?entry=#url.c#" addToken="false">
		</cfif>

		<cfif listFindNoCase(application.alternateSiteNames,cgi.SERVER_NAME)>
			<cflocation url="http://#application.siteURL##arguments.thepage#" statuscode="301" addToken="false">
		</cfif>

		<!--- check for key in scheduled folder --->
		<cfif findNoCase("/scheduled/", arguments.thePage)>
			<cfif not structKeyExists(url, "processkey") or url.processkey neq application.processkey>
				<cfoutput>
				<h2>Access Denied</h2>
				</cfoutput>
				<cfabort>
			</cfif>
		</cfif>

		<cfif structKeyExists(form, "adminlogin") and form.adminpassword is application.processkey>
			<cfset session.adminlogin = true>
		</cfif>

		<cfif findNoCase("/admin/", arguments.thePage) and (not structKeyExists(session, "adminlogin") OR NOT session.adminLogin)>
			<cfinclude template="/admin/login.cfm">
			<cfabort>
		</cfif>

		<cfif structKeyExists(url, "perpage") and isNumeric(url.perpage) and url.perpage gte 1 and url.perpage lte 100>
			<cfcookie name="perpage" value="#round(url.perpage)#" expires="never">
		</cfif>

		<!--- check/set cookie for perpage --->
		<cfif structKeyExists(cookie, "perpage") and isNumeric(cookie.perpage) and cookie.perpage gte 1 and cookie.perpage lte 100>
			<cfset request.perpage = round(cookie.perpage)>
		<cfelse>
			<cfset request.perpage = application.perpage>
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="onError" returnType="void" output="false">
		<cfargument name="exception" required="true">
		<cfargument name="eventname" type="string" required="true">

		<!--- if adminemail does not exist, consider this a NOT loaded app --->
		<cfif not structKeyExists(application,"adminemail") or (structKeyExists(application, "localserver") and application.localserver)>
			<cfdump var="#arguments#" label="Error"><cfabort>
		<cfelse>
			<cfmail to="#application.adminemail#" from="#application.adminemail#" subject="#application.sitename# error" type="html">
			<cfdump var="#arguments#" label="ERROR!!">
			</cfmail>
			<cflocation url="/error.cfm" addToken="false">
		</cfif>
	</cffunction>

	<cffunction name="onSessionStart" returnType="void" output="false">
		<cflock name="MyAppLock" type="exclusive" timeout="30">
			<cfset application.usercount++>
		</cflock>
		<cfset session.loggedin = false>
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void" output="false">
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" type="struct" required="false">

		<cflock name="MyAppLock" type="exclusive" timeout="30">
			<cfset arguments.appScope.usercount-->
			<cfif arguments.appScope.userCount lt 0>
				<cfset arguments.appScope.userCount = 0>
			</cfif>
		</cflock>
	</cffunction>

</cfcomponent>