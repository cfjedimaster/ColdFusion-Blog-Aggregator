<!---
	Name         : process.cfm
	Author       : Raymond Camden
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      :
	Purpose		 : Main processor. Does the hard work of getting feeds.
--->
<cfprocessingdirective pageencoding="utf-8">

<cfif structKeyExists(url,"ray")>
	<cfset application.urlcache = structNew()>
	<cfset application.rsscache = structNew()>
</cfif>

<cfif not structKeyExists(application, "urlcache")>
	<cfset application.urlcache = structNew()>
</cfif>



<cffunction name="isValidXML" returnType="boolean" output="false">
	<cfargument name="s" type="string" required="true">
	<cfset var foo = "">

	<cftry>
		<cfset foo = xmlParse(arguments.s)>
		<cfreturn true>
		<cfcatch>
			<cfreturn false>
		</cfcatch>
	</cftry>
</cffunction>

<cfset variables.requestkey = "AggregatorCFCThread">
<cffunction name="getCounter" returnType="numeric" output="false">
	<cfset var needInit = false>

	<cflock scope="request" type="readOnly" timeout="30">
		<cfif not structKeyExists(request, variables.requestkey)>
			<cfset needInit = true>
		</cfif>
	</cflock>

	<cfif needInit>
		<cflock scope="request" type="exclusive" timeout="30">
			<cfif not structKeyExists(request, variables.requestkey)>
				<cfset request[variables.requestkey] = 0>
			</cfif>
		</cflock>
	</cfif>

	<cflock scope="request" type="exclusive" timeout="30">
		<cfset request[variables.requestkey]++>
		<cfreturn request[variables.requestkey]>
	</cflock>

</cffunction>


<cfset feeds = application.entries.getFeeds()>

<!--- temp --->
<!---
<cfquery name="feeds" dbtype="query" maxrows="25">
select * from feeds
</cfquery>
--->

<cfif feeds.recordCount is 0>
	No feeds, aborting.
	<cfabort>
</cfif>

<cfoutput>
Aggregating #feeds.recordCount# feeds.
<p>
</cfoutput>

<cfloop query="feeds">

	<cfset tname = "thread_#getCounter()#">
	<cfthread action="run" url="#rssurl#" name="#tname#" feed="#name#" feedid="#id#">

		<cftry>

			<cfset stopWork = false>
			<cfset status = "#attributes.feed#: ">

			<!--- the first thing we do is see if we have this in URL cache. --->
			<cfif structKeyExists(application.urlcache, attributes.url)>
				<cfoutput>#attributes.url# - yes to etag cache<p></cfoutput>
				<!--- do a conditional get --->
				<cfhttp url="#attributes.url#" method="get" result="result" timeout="10" charset="utf-8">
					<cfhttpparam type="header" name="If-None-Match" value="#application.urlcache[attributes.url].etag#">
					<cfhttpparam type="header" name="If-Modified-Since" value="#application.urlcache[attributes.url].lastmodified#">
				</cfhttp>

				<cfif not structKeyExists(result.responseheader, "Status_Code")>
					<cfoutput>#attributes.url# - no status code</cfoutput>
					<cfset stopwork = true>
					<cfset status &= "Stopped work because no status code returned from the hit.">
				<cfelseif result.responseheader.status_code neq 304>
					<cfoutput>#attributes.url# - etag changed<p></cfoutput>

					<!--- ok, use the xml --->
					<cfset xml = result.filecontent>
					<cfif isValidXml(xml)>
						<!--- unfortunately we have to store to file system --->
						<cfset myfile = expandPath("./temp") & "/" & replace(createUUID(), "-", "-", "all") & ".xml">
						<cffile action="write" file="#myfile#" output="#xml#" charset="utf-8">
						<cfoutput>
							#attributes.url# - i updated #result.responseheader.etag#, #result.responseheader["Last-Modified"]#, status was #result.responseheader.status_code#
							<br>
							old vals were #application.urlcache[attributes.url].etag#/#application.urlcache[attributes.url].lastmodified#
							<p>
						</cfoutput>
						<!--- and update values --->
						<cfset application.urlcache[attributes.url].etag = result.responseheader.etag>
						<cfset application.urlcache[attributes.url].lastmodified = result.responseheader["Last-Modified"]>
						<cfset status &= "The etag had changed. Downloaded new XML">
					<cfelse>
						<cfoutput>#attributes.url# was not xml #result.responseheader.status_code#</cfoutput>
						<cfset stopWork = true>
						<cfset status &= "The XML was invalid.">
					</cfif>
				<cfelse>
					<cfoutput>#attributes.url# - etag not changed<p></cfoutput>
					<cfset stopWork = true>
					<cfset status &= "ETag had not changed. No need to reprocess.">
				</cfif>

			<cfelse>

				<cfhttp url="#attributes.url#" method="get" result="result" timeout="10" charset="utf-8">
				<cfoutput>#attributes.url# - no to etag in cache<p></cfoutput>

				<cfset xml = result.filecontent>

				<cfif isValidXml(xml)>
					<!--- unfortunately we have to store to file system --->
					<cfset myfile = expandPath("./temp") & "/" & replace(createUUID(), "-", "-", "all") & ".xml">
					<cffile action="write" file="#myfile#" output="#xml#" charset="utf-8">

					<cfif structKeyExists(result.responseheader, "etag") and structKeyExists(result.responseheader, "Last-Modified")>
						<cflog file="cfbloggers" text="#attributes.url# - set a new etag for it">
						<cfset application.urlcache[attributes.url] = structNew()>
						<cfset application.urlcache[attributes.url].etag = result.responseheader.etag>
						<cfset application.urlcache[attributes.url].lastmodified = result.responseheader["Last-Modified"]>
						<cfset status &= "Got XML, and got etag">
					</cfif>
				<cfelse>
					<cfset stopWork = true>
					<cfset status &= "Invalid XML">
					<cfoutput>Invalid XML, so I stopped.</cfoutput>
				</cfif>

			</cfif>

			<cfif not stopWork>
				<cffeed source="#myfile#" query="entries" properties="metadata" timeout="10">
				<cffile action="delete" file="#myfile#">
			</cfif>

			<cfcatch>
				<cfset stopWork = true>
				<cflog file="cfbloggers" text="#attributes.url# - error - #cfcatch.message#">
				<cfset status &= " error #cfcatch.message#">
				<cfoutput>Error: #cfcatch.message#<p></cfoutput>
				<cfif isDefined("myfile") and fileExists(myfile)>
					<cffile action="delete" file="#myfile#">
				</cfif>
			</cfcatch>

		</cftry>

		<cfif not stopWork>
			<!--- Examine the top entry and see if it is new --->
			<cfif entries.recordCount>
				<cfif not structKeyExists(application.rsscache, attributes.url) or application.rsscache[attributes.url] is not entries.rsslink[1]>
					<cfoutput>Feed #attributes.feed# has been updated. It has #entries.recordCount# entries.<br /></cfoutput>
					<!--- The top entry was new, so we have new stuff. Time to massage the data. --->
					<cfset entries = application.rss.massage(entries,metadata)>
					<!--- now loop and add crap where necessary --->
					<cfloop query="entries">
						<cftry>
						<cfif date neq "" and dateDiff("d",date,now()) lte 30>
							<cflog file="cfb_process" text="may add #attributes.feed# #title#">
							<cfset newContent = application.utils.CleanHighAscii(content)>
							<cfset res = application.entries.addEntryIfNew(attributes.feedid,title,link,date,newcontent,categorylabel)>
							<cflog file="cfb_process" text="result for #title# is  #res#">
							<cfif application.twitterNotification AND res neq 0 and not application.localserver>
								<!--- do a Twit --->
								<!--- shorter url --->
								<cfset thisurl = "http://#application.siteURL#/click.cfm?entry=#res#">
								<cfset shorturl = application.utils.googleUrlShorten(thisurl)>
								<cfset thisurl = " - #shorturl#">
								<cfset avail = 140 - len(thisurl)>
								<cfset message = left(title, avail) & thisurl>
								<cfset application.twitter.updateStatus(message)>
							</cfif>
						<cfelse>
							<cfoutput>ignoring feed #attributes.feed# item because it had no date. or date > 30. date was #date#<br></cfoutput>
						</cfif>
						<cfcatch>
							<cflog file="cfb_process" text="error: #attributes.feed# #attributes.url# #cfcatch.message# / #cfcatch.detail#">
							<cfdump var="#cfcatch#">
						</cfcatch>
						</cftry>
					</cfloop>
					<cfset application.rsscache[attributes.url] = entries.rsslink[1]>
					<cfset status &= " Tried to add #entries.recordCount# entries.">
				<cfelse>
					<cfoutput>Feed #attributes.feed# has NOT been updated. It had #entries.recordCount# entries. ske=#structKeyExists(application.rsscache, attributes.url)#, and comp #application.rsscache[attributes.url]# versus #entries.rsslink[1]# <br /></cfoutput>
				</cfif>
			<cfelse>
				<cfset status &= " No entries.">
			</cfif>
		<cfelse>
			<cfoutput>Feed #attributes.feed# STOPPED.<br /></cfoutput>
		</cfif>

		<cflog file="processresult" text="#status#">
		<cfset application.entries.setStatus(attributes.feedid, status)>
	</cfthread>
</cfloop>

<!---
<cfthread action="join" name="#structKeyList(cfthread)#" />
<cfdump var="#cfthread#" >
--->
