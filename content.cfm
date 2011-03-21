<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : content.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : August 3, 2007
	History      : Notice log url and pass it (rkc 8/3/07)
	Purpose		 : Main content div for entries.
--->

<!--- look for page in url --->
<cfif structKeyExists(url, "page") and isNumeric(url.page)>
	<cfset url.start = (url.page-1) * request.perpage + 1>
</cfif>

<cfparam name="url.start" default="1">

<cfif not isNumeric(url.start) or url.start lte 0 or url.start neq round(url.start)>
	<cfset url.start = 1>
</cfif>

<cfif structKeyExists(url, "search_query")>
	<cfset form.search_query = url.search_query>
</cfif>
<cfif structKeyExists(form, "search_query") and len(trim(form.search_query))>
	<cfset form.search_query = left(trim(htmlEditFormat(form.search_query)),255)>
	<!--- was it a search we want to log? --->
	<cfif structKeyExists(url, "log")>
		<cfset log = true>
	<cfelse>
		<cfset log = false>
	</cfif>
	<cfset data = application.entries.getEntries(url.start,request.perpage,form.search_query,log)>
<cfelse>
	<cfset data = application.entries.getEntries(url.start,request.perpage)>
</cfif>

<cfif url.start gt 1>
	<cfset lp = ((url.start-1)/request.perpage)>
	<cfoutput>
	<script>
	previous = function(u) {
		<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>$("##loadingmsg").show();</cfif>
		document.location.href = '###lp#';
		//$("##content").load(u<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>,cbfunc</cfif>);		
		loadDiv(u)		
		document.body.scrollIntoView(true);
	}
	</script>
	</cfoutput>
</cfif>
<cfif url.start+request.perpage-1 lt data.total>
	<cfset np = ((url.start-1)/request.perpage)+2>
	<cfoutput>
	<script>
	next = function(u) {
		<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>$("##loadingmsg").show();</cfif>
		document.location.href = '###np#';
		//$("##content").load(u<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>,cbfunc</cfif>);
		loadDiv(u)		
		document.body.scrollIntoView(true);
	}
	</script>
	</cfoutput>
</cfif>

<cfif structKeyExists(form, "search_query") and len(trim(form.search_query))>

	<cfoutput>
	<h2>Searched for #form.search_query# (#data.total# Entries)</h2>
	</cfoutput>

<cfelse>

	<cfoutput>
	<h2>All Entries (#data.total# Entries)</h2>
	</cfoutput>

</cfif>

<cfsavecontent variable="pagey">
	<cfif structKeyExists(form, "search_query") and len(trim(form.search_query))>
		<!---
		<cfset append = "&search_query=#urlEncodedFormat(form.search_query)#">
		--->
		<cfset append = "&search_query=#replace(form.search_query,' ','+','all')#">
	<cfelse>
		<cfset append = "">
	</cfif>
<cfoutput>
<p align="right">
<cfif url.start gt 1>
	<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>
	<a href="javaScript:previous('#cgi.script_name#?start=#max(1,url.start-request.perpage)##append#')">Previous</a>
	<cfelse>
	<a href="#cgi.script_name#?start=#max(1,url.start-request.perpage)#">Previous</a>
	</cfif>
<cfelse>
	Previous
</cfif>
/ #url.start# - #min(url.start+request.perpage-1,data.total)# / 
<cfif url.start+request.perpage-1 lt data.total>
	<cfif not structKeyExists(variables, "isiphone") or not variables.isiphone>
		<a href="javaScript:next('#cgi.script_name#?start=#url.start+request.perpage##append#')">Next</a>
	<cfelse>
		<a href="#cgi.script_name#?start=#url.start+request.perpage#">Next</a>
	</cfif>
<cfelse>
	Next
</cfif>
</p>
</cfoutput>
</cfsavecontent>

<cfif data.total gte 1>
	<cfoutput>#pagey#</cfoutput>

	<cfoutput query="data.entries">
		<cfset portion = reReplace(content, "<.*?>", "", "all")>
		<!--- fix trailing HTML --->
		<cfset portion = reReplace(portion, "<.*$", "")>
		<!--- fix weird categories --->
		<cfset categorylist = reReplace(categories,"[, ]{1,}$", "", "all")>
		<cfset categorylist = replace(categories,",", ", ", "all")>
		
		<!--- until we fix the parser to get first url only, use listFirst --->
		<cfset myurl = listFirst(data.entries.url)>
		
	<p <cfif currentRow mod 2 is 0>style="background-color: ##dbdbdb; padding: 5px;"<cfelse>style="padding: 5px;"</cfif>>
	<a href="click.cfm?entry=#id#&entryurl=#urlEncodedFormat(myurl)#"><b><cfif not len(title)>No Title<cfelse>#htmlEditFormat(title)#</cfif></b></a> <a href="click.cfm?entry=#id#&entryurl=#urlEncodedFormat(myurl)#" target="_new">[+]</a><br />
	<b><a href="#blogurl#">#blog#</a> | #dateFormat(created,"short")# #timeFormat(created,"short")#<cfif len(categorylist)> | #categorylist#</cfif></b><br />
	#left(portion, 750)#<cfif len(portion) gt 750>...</cfif>
	</p>
	</cfoutput>

	<cfoutput>#pagey#</cfoutput>

<cfelse>

<cfoutput>
<p>
Sorry, but I ain't got nothing to show...
</p>
</cfoutput>

</cfif>
