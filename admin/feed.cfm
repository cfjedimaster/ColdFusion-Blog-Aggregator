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

	</cfif>
</cfif>


<cfif saved>
	<div class="ui-widget">
				<div style="margin:1em; padding: .3em;" class="ui-state-highlight ui-corner-all"> 
					<p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-info"></span>
					<strong>Yay!</strong> The feed saved.</p>
				</div>
			</div>
</cfif>

<cfoutput>
	<script>
		$(document).ready(function(){
			$("##feedForm").uniform();
		})
	</script>
	<form  class="uniForm" id="feedForm" style="z-index:9999">
	  <fieldset>
	    <div class="ctrlHolder">
	      <label for="name">Blog Name</label>
	      <input type="text" id="name" name="name" value="#form.name#" size="35" class="textInput">
	    </div>
	  
	    <div class="ctrlHolder">
	      <label for="description">Description</label>
	      <textarea id="description" name="description" rows="25" cols="25">#form.description#</textarea>
	    </div>
	  
	    <div class="ctrlHolder">
	      <label for="url">Blog URL</label>
	      <input type="text" id="url" name="url" value="#form.url#" size="35" class="textInput">
	    </div>
	  
	    <div class="ctrlHolder">
	      <label for="rssurl">RSS URL</label>
	      <input type="text" id="rssurl" name="rssurl" value="#form.rssurl#" size="35" class="textInput">
	    </div>
	  	<input type="hidden" name="id" id="id" value="#url.id#" />
		<input type="hidden" name="urlomyurl" value="#url.myurl#">
	  </fieldset>
</form>

</cfoutput>