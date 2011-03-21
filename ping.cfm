<cfprocessingdirective pageencoding="utf-8">
<cfparam name="url.debug" default="false">
<cfif not isBoolean(url.debug)>
	<cfset url.debug = false>
</cfif>

<!--- First, did they pass in their blog url? --->
<cfif not structKeyExists(url, "burl") or trim(url.burl) is "">
	<cfoutput>Error - No BURL value.</cfoutput>
	<cfabort />
</cfif>

<cfset blog = application.entries.getFeeds(url=url.burl)>

<cfif blog.recordCount is 0>
	<cfoutput>Error - Unknown Blog</cfoutput>
	<cfabort />
</cfif>

<cftry>
	<cffeed source="#blog.rssurl#" query="entries" properties="metadata" timeout="10">

	<cfif url.debug>
		<cfoutput>entries.recordcount=#entries.recordcount#, rssurl is #blog.rssurl#<br></cfoutput>
	</cfif>

	<cfif entries.recordCount>
		<cfset entries = application.rss.massage(entries,metadata)>

		<cfif url.debug>
			<cfdump var="#entries#">
		</cfif>

		<cfloop query="entries">
			<cftry>
			<cfif date neq "">
				<cfset newcontent = application.utils.CleanHighAscii(content)>
				<cfset res = application.entries.addEntryIfNew(blog.id,title,link,date,newcontent,categorylabel)>
				<cfif application.twitterNotification AND res neq 0 and not application.localserver>
					<!--- do a Twit --->
					<!--- shorter url --->
					<cfset thisurl = "http://#application.siteURL#/click.cfm?entry=#res#">
					<cfset shorturl = application.utils.googleUrlShorten(thisurl)>
					<cfset thisurl = " - #shorturl#">
					<cfset avail = 160 - len(thisurl)>
					<cfset message = left(title, avail) & thisurl>
					<cfset application.twitter.updateStatus(message)>
				</cfif>
				<cfif url.debug>
				<cfoutput>Possibly adding #title# #blog.id#</cfoutput>
				<cfif res neq 0><cfoutput> added</cfoutput><cfelse><cfoutput> NOT added</cfoutput></cfif><br>
				</cfif>
			</cfif>
			<cfcatch>
				<cfoutput>Error occured adding an entry. <cfif structKeyExists(url, "ray")><cfdump var="#cfcatch#"><cfdump var="#entries#" label="#currentrow#"></cfif></cfoutput>
				<cfabort>
			</cfcatch>
			</cftry>
		</cfloop>
		<cfset application.entries.setStatus(blog.id, "Ping ran ok, had #entries.recordcount# entries to possibly add.")>
	</cfif>
	<cfoutput>Ok</cfoutput>
	<cfcatch>
		<cfset application.entries.setStatus(blog.id, "Ping error. #cfcatch.message#")>
		Error
		<cfdump var="#cfcatch#">
	</cfcatch>
</cftry>
