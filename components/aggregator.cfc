<!---
    Name         : Aggregator.cfc
    Author       : Raymond Camden
    Created      : June 2007
    Last Updated :
    History      : feedtitle, feeddescription support (6/10/07 tsharp)
                 : added opmlToFeedQuery (6/10/07 tsharp)
				 : Use request scope counter instead of createUUID, thanks to Dan S for idea (6/10/07)
--->


<cfcomponent displayName="Aggregator 2000 - Vista Leapord Edition" output="false">
    
    <!--- Use this column list since not all feeds return the same cols. --->
    <cfset variables.collist = "authoremail,authorname,authoruri,categorylabel,categoryscheme,categoryterm,comments,content,contentmode,contentsrc,contenttype,contributoremail,contributorname,contributoruri,createddate,expirationdate,feedtitle,feeddescription,id,idpermalink,linkhref,linkhreflang,linklength,linkrel,linktitle,publisheddate,rights,rsslink,source,sourceurl,summary,summarymode,summarysrc,summarytype,title,updateddate,uri,xmlbase,link,version,[date],feedid">
	<!--- used for naming --->
	<cfset variables.requestkey = "AggregatorCFCThread">

	<cffunction name="getCounter" access="private" returnType="numeric" output="false">
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
				
    <cffunction name="aggregate" returnType="query" output="false">
        <cfargument name="feeds" type="any" required="true" hint="RSS url, or array of them.">
        <cfargument name="feedids" type="array" required="true" hint="Array of feed IDs.">
		
        <cfset var results = structNew()>
        <cfset var result = "">
        <cfset var entries = "">
        <cfset var x = "">
        <cfset var totalentries = "">
        <cfset var tlist = "">
        <cfset var tname = "">
        <cfset var thread = "">
        <cfset var tmpArr = "">
        <cfset var keys = "">
       	<cfset var stopWork = "">
		
        <cfif not isArray(arguments.feeds)>
            <cfset tmpArr = arrayNew(1)>
            <cfset tmpArr[1] = arguments.feeds>
            <cfset arguments.feeds = tmpArr>
        </cfif>
   
        <cfloop index="x" from="1" to="#arrayLen(arguments.feeds)#">
			<cfset tname = "thread_#getCounter()#">
            <cfthread action="run" name="#tname#" url="#arguments.feeds[x]#" feedid="#arguments.feedids[x]#">
				<cftry>
					<cffeed source="#attributes.url#" query="thread.entries" properties="thread.metadata" timeout="10">
					<cfset stopWork = false>
					<cfcatch>
						<cfset stopWork = true>
					</cfcatch>
				</cftry>
				<cfif not stopWork>
	                <!--- based on the type of feeds, lets munge things a bit --->
					<cfset feedidarr = arrayNew(1)>
					<cfif thread.entries.recordCount gte 1>
						<cfset arraySet(feedidarr, 1, thread.entries.recordcount, attributes.feedid)>
					</cfif>					
	                <cfset queryAddColumn(thread.entries, "link", "varchar", arrayNew(1))>
	                <cfset queryAddColumn(thread.entries, "version", "varchar", arrayNew(1))>
	                <cfset queryAddColumn(thread.entries, "date", "date", arrayNew(1))>
	                <cfset queryAddColumn(thread.entries, "feedtitle", "varchar", arrayNew(1))>
	                <cfset queryAddColumn(thread.entries, "feeddescription", "varchar", arrayNew(1))>
	                <cfset queryAddColumn(thread.entries, "feedid", "integer", feedidarr)>
	               
	                <cfif findNoCase("atom", thread.metadata.version)>
	                    <cfset isAtom = true>
	                <cfelse>
	                    <cfset isAtom = false>
	                </cfif>
	                <cfloop query="thread.entries">
	                    <cfif isAtom>
	                        <cfif len(publisheddate)>
	                            <!--- From Jared --->
	                            <cfset date = dateFormat(listFirst(publisheddate,"T"),"short")>
	                            <cfset time = timeFormat(replaceNoCase(listLast(publisheddate,"T"),"z",""),"short")>   
	                            <cfset querySetCell(thread.entries, "date", date & " " & time, currentRow)>       
	                        </cfif>
	                        <cfset querySetCell(thread.entries, "link", linkhref, currentRow)>
	                        <cfif structKeyExists(thread.metadata, "title") and structKeyExists(thread.metadata.title, "value")>
	                            <cfset querySetCell(thread.entries, "feedtitle", thread.metadata.title.value, currentRow)>
	                        <cfelse>   
	                            <cfset querySetCell(thread.entries, "feedtitle", "", currentRow)>
	                        </cfif>
	                        <cfif structKeyExists(thread.metadata, "tagline") and structKeyExists(thread.metadata.tagline, "value")>
	                            <cfset querySetCell(thread.entries, "feeddescription", thread.metadata.tagline.value, currentRow)>   
	                        <cfelse>
	                            <cfset querySetCell(thread.entries, "feeddescription", "", currentRow)>                           
	                        </cfif>
	                    <cfelse>
	                        <cfset querySetCell(thread.entries, "link", rsslink, currentRow)>
	                        <cfif isDate(publishedDate)>
	                            <cfset querySetCell(thread.entries, "date", parseDateTime(publishedDate), currentRow)>
							<cfelseif isDefined("dc_date") and isDate(dc_date)>
	                            <cfset querySetCell(thread.entries, "date", parseDateTime(dc_date), currentRow)>						
	                        </cfif>   
	                        <cfif structKeyExists(thread.metadata, "title")>
	                            <cfset querySetCell(thread.entries, "feedtitle", thread.metadata.title, currentRow)>
	                        <cfelse>
	                            <cfset querySetCell(thread.entries, "feedtitle", "", currentRow)>                       
	                        </cfif>
	                        <cfif structKeyExists(thread.metadata, "description")>                       
	                            <cfset querySetCell(thread.entries, "feeddescription", thread.metadata.description, currentRow)>
	                        <cfelse>
	                            <cfset querySetCell(thread.entries, "feeddescription", "", currentRow)>
	                        </cfif>
	                    </cfif>
	                    <cfset querySetCell(thread.entries, "version", thread.metadata.version, currentRow)>   
	                </cfloop>
	             </cfif>           
            </cfthread>
            <cfset tlist = listAppend(tlist, tname)>
        </cfloop>
   
        <cfthread action="join" name="#tlist#" />   
       
        <!--- copy out just for ease of use --->   
        <cfloop index="x" list="#tlist#">
            <cfset thread = evaluate("#x#")>
            <cfif thread.status is "completed" and structKeyExists(thread, "entries")>
                <cfset results["result_#x#"] = thread.entries>
            </cfif>
        </cfloop>

<!---
<cfloop item="result" collection="#results#">
<cfset temp = results[result]>
<cfdump var="#valueList(temp.feedtitle)#">
</cfloop>
<cfabort>
--->

        <cfquery name="totalentries" dbtype="query">
            <cfset keys = structKeyArray(results)>
            <cfloop index="x" from="1" to="#arrayLen(keys)#">
            select
             #variables.collist#
            from results.#keys[x]#
            <cfif x is not arrayLen(keys)>
            union
            </cfif>
            </cfloop>
        </cfquery>
   
        <!--- sort --->
        <cfquery name="totalentries" dbtype="query">
        select #variables.collist#
        from totalentries
        order by [date] desc
        </cfquery>
   
        <cfreturn totalentries>
    </cffunction>
   
    <cffunction name="search" returnType="query" output="false">
        <cfargument name="feeds" type="any" required="true" hint="RSS url, or array of them.">
        <cfargument name="searchterms" type="string" required="true">
        <cfargument name="caseinsensitive" type="boolean" required="false" default="true">
       
        <cfset var results = aggregate(feeds)>
        <!--- our collist escapes date, so lets "fix" it back here for the query new --->
        <cfset var result = queryNew(rereplace(variables.collist,"\[|\]","","all"))>

        <cfquery name="result" dbtype="query">
        select    *
        from    results
        where   
        <cfif arguments.caseensitive>
        lower(title) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.searchterms)#%">
        or        lower(content) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.searchterms)#%">
        <cfelse>
        title like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchterms#%">
        or        content like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchterms#%">
        </cfif>
        </cfquery>
       
        <cfreturn result>
    </cffunction>
   
    <cffunction name="opmlToFeedArray" returntype="array" output="false">
        <cfargument name="opmlURL" type="string" required="true" hint="URL that points to a valid OPML feed.">
        <cfset var returnArr = []>
        <cfset var feed = "">
        <cfset var feedXML = "">
        <cfset var i = "">
       
        <cfhttp url="#arguments.opmlURL#" result="feed" timeout="10" />
       
        <cfif findNoCase("200", feed.statusCode)>
            <cfset feedXML = xmlParse(feed.fileContent)>
            <cfloop from="1" to="#arrayLen(feedXML.opml.body.outline)#" index="i">
                <cfset arrayAppend(returnArr,feedXML.opml.body.outline[i].xmlAttributes.xmlURL)>
            </cfloop>
        </cfif>
       
        <cfreturn returnArr />
    </cffunction>
</cfcomponent>
 