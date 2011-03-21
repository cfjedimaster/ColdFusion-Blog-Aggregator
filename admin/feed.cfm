<cfparam name="url.id" default="0" />
<cfparam name="url.myurl" default="" />
<cfparam name="saved" default="false" />
<cfparam name="form.id" default="#url.id#" />
<cfparam name="form.name" default="" />
<cfparam name="form.description" default="" />
<cfparam name="form.url" default="" />
<cfparam name="form.rssurl" default="" />

<cfif url.id neq 0>
	<cfset feed = application.entries.getFeeds(url.id) />
	<cfset form.name = feed.name />
	<cfset form.description = feed.description  />
	<cfset form.url = feed.url />
	<cfset form.rssurl = feed.rssurl />
</cfif>

<cfif url.myurl neq ''>
<cffeed source="#url.myurl#" query="blogdetails" properties="feedmetadata" timeout="10">


<!--- check to see if its atom or rss --->
<cfif StructKeyExists(feedmetadata,"version") AND feedmetadata.version contains 'atom'>

<cfset form.name = feedmetadata.title.value>
<cfset form.url = feedmetadata.link[1].href>
<cfset form.rssurl = url.myurl>
<cfset form.description = feedmetadata.title.value>

<cfelse>

<cfset form.name = feedmetadata.title>
<cfif StructKeyExists(feedmetadata,"description")>
	<cfset form.description = feedmetadata.description>
<cfelse>
	<cfset form.description = feedmetadata.title>
</cfif>
<cfset form.url = feedmetadata.link>
<cfset form.rssurl = url.myurl>


</cfif>
</cfif>


<cfif structKeyExists(form, "submit") and len(form.name)>
<cflog file="application" text="form.name=#form.name#">
	<!--- are we updating or inserting? --->
	<cfif form.id eq 0>
		<cfset saved = application.entries.createFeed(argumentCollection=form) />
	<cfelse>
		<cfset saved = application.entries.updateFeed(argumentCollection=form) />
	</cfif>
	<cfif form.urlomyurl neq ''>
	<script>

		ColdFusion.Window.hide('pfeedWin')

	</script>
	</cfif>
</cfif>

<cfif saved>
	<div style="text-align:center;"><strong> || Feed Saved ||</strong></div>
</cfif>

<cfform name="feedForm" action="#cgi.SCRIPT_NAME#" method="post" onsubmit="isChanged=true;">
	<div>
		<div style="float:left; width:100px;">Name</div>
		<div style="float:left;"><cfinput type="text" name="name" id="name" value="#form.name#" required="true" message="Feed name is required." maxlength="255" size="50" /></div>
		<div style="clear:both;"></div>
	</div>
	<div>
		<div style="float:left; width:100px;">Description</div>
		<div style="float:left;"><cftextarea name="description" id="description" value="#form.description#" required="true" message="Description is required." maxlength="255" cols="50" ></cftextarea></div>
		<div style="clear:both;"></div>
	</div>
	<div>
		<div style="float:left; width:100px;">URL</div>
		<div style="float:left;"><cfinput type="text" name="url" id="url" value="#form.url#" required="true" message="Feed url is required." maxlength="500" size="50"/></div>
		<div style="clear:both;"></div>
	</div>
	<div>
		<div style="float:left; width:100px;">RSS URL</div>
		<div style="float:left;"><cfinput type="text" name="rssurl" id="rssurl" value="#form.rssurl#" required="true" message="Feed rssurl is required." maxlength="500" size="50"/></div>
		<div style="clear:both;"></div>
	</div>
	<div>
		<div style="float:left; width:100px;">&nbsp;</div>
		<div style="float:left;"><cfinput type="submit" name="submit" id="submit" value="Save it" /></div>
		<div style="clear:both;"></div>
	</div>
	<cfinput type="hidden" name="id" id="id" value="#url.id#" />
	<cfinput type="hidden" name="urlomyurl" value="#url.myurl#">
</cfform>