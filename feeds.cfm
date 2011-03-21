<!---
	Name         : feeds.cfm
	Author       : Raymond Camden
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      :
	Purpose		 : Main feeds page.
--->

<cf_layout title="#application.siteTitle# - List of Blogs">

<script type="text/javascript">
$(document).ready(function() {
	$("#tabs").tabs({
      spinner: "",
      select: function(event, ui) {
        var tabID = "#ui-tabs-" + (ui.index + 1);
        $(tabID).html("<b>Fetching Data.... Please wait....</b>");
      }
    });
})
</script>
<style>
#feedList a {
	text-decoration: underline;
}
</style>
<cfset stats = application.entries.getStats()>

<cfoutput>
<h2>List of Blogs (#stats.totalblogs# Blogs)</h2>

<p>
Here is the complete and total list of blogs in use here. You can also access the list as an <a href="opml.cfm">OPML</a> feed.
</p>
</cfoutput>

<div id="tabs">
	<ul>
		<li><a href="feeds_list.cfm?r=a-c">A-C</a></li>
		<li><a href="feeds_list.cfm?r=d-f">D-F</a></li>
		<li><a href="feeds_list.cfm?r=g-j">G-J</a></li>
		<li><a href="feeds_list.cfm?r=k-o">K-O</a></li>
		<li><a href="feeds_list.cfm?r=p-t">P-T</a></li>
		<li><a href="feeds_list.cfm?r=u-z">U-Z</a></li>
	</ul>
</div>

</cf_layout>
