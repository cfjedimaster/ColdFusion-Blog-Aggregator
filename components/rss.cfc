<cfcomponent hint="My utility function for RSS related stuff." output="false">

<cffunction name="massage" returnType="query" output="false">
	<cfargument name="entries" type="query" required="true">
	<cfargument name="metadata" type="struct" required="true">
	<cfset var isAtom = "">
	<cfset var date = "">
	<cfset var time = "">
	<cfset var tempcat = "">
	
	<cfset queryAddColumn(arguments.entries, "link", "varchar", arrayNew(1))>
	<cfset queryAddColumn(arguments.entries, "date", "date", arrayNew(1))>
	               
    <cfif findNoCase("atom", arguments.metadata.version)>
        <cfset isAtom = true>
    <cfelse>
        <cfset isAtom = false>
    </cfif>

	<cfloop query="arguments.entries">
	
		<cfif isAtom>
		
			<!--- changed from publisheddate --->
			<cfif len(updateddate)>
				<!--- From Jared --->
				<cfset date = dateFormat(listFirst(updateddate,"T"),"short")>
				<cfset time = timeFormat(replaceNoCase(listLast(updateddate,"T"),"z",""),"short")>   
				<cfset querySetCell(arguments.entries, "date", date & " " & time, currentRow)>       
			</cfif>

			<cfset querySetCell(arguments.entries, "link", listfirst(linkhref), currentRow)>

			<!--- handle cases where we have a summary but no content --->
			<cfif len(summary) and not len(content)>
				<cfset querySetCell(arguments.entries, "content", summary,currentrow)>
			</cfif>

			<!--- sometimes we see , , for categorylabel, but categoryterm has content --->
			<cfset tempcat = reReplace(categorylabel,"[, ]","","all")>
			<cfif tempcat is "" and len(categoryterm)>
				<cfset querySetCell(arguments.entries, "categorylabel", categoryterm, currentrow)>
			</cfif>

		<cfelse>

			<cfset querySetCell(arguments.entries, "link", rsslink, currentRow)>

			<cfif isDate(publishedDate)>
				<cfset querySetCell(arguments.entries, "date", parseDateTime(publishedDate), currentRow)>
			<cfelseif isDefined("dc_date") and isDate(dc_date)>
				<cfset querySetCell(arguments.entries, "date", parseDateTime(dc_date), currentRow)>						
			</cfif>   

		</cfif>
	
	</cfloop>
	
	<cfreturn arguments.entries>
</cffunction>

</cfcomponent>