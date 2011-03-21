<cfprocessingdirective pageencoding="utf-8">

<cfif not len(application.opmlcache)>
	<cfset blogs = application.entries.getFeeds()>
	
	<cfsavecontent variable="header">
	<opml version="1.1">
	<head>
	<title>ColdFusion Feeds</title>
	<dateCreated><cfoutput>#dateFormat(now(),"dd mmm yy")#</cfoutput></dateCreated>
	<ownerName>Raymond Camden</ownerName>
	<ownerEmail>Raymond Camden</ownerEmail>
	</head>
	</cfsavecontent>
	
	<cfsavecontent variable="body">
	<body>
	<cfoutput query="blogs">
		<outline text="#application.toxml.safeText(name)#" title="#application.toxml.safeText(name)#" description="#application.toxml.safeText(description)#" language="English" htmlUrl="#xmlformat(url)#" xmlUrl="#xmlFormat(rssUrl)#" />
	</cfoutput>
	</body>
	</opml>
	</cfsavecontent>
	<cfset application.opmlcache = header & body>
</cfif>

<cfcontent type="text/xml; chartset=utf-8" reset="true"><cfoutput>#application.opmlcache#</cfoutput>