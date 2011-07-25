<cfif isDefined("url.entry") and isNumeric(url.entry) and url.entry gte 1 and round(url.entry) is url.entry>
	<cfset entry = application.entries.getEntry(url.entry)>	
</cfif>

<cfscript>
/**
* An &amp;quot;enhanced&amp;quot; version of ParagraphFormat.
* Added replacement of tab with nonbreaking space char, idea by Mark R Andrachek.
* Rewrite and multiOS support by Nathan Dintenfas.
* 
* @param string      The string to format. (Required)
* @return Returns a string. 
* @author Ben Forta (ben@forta.com) 
* @version 3, June 26, 2002 
*/
function ParagraphFormat2(str) {
    //first make Windows style into Unix style
    str = replace(str,chr(13)&chr(10),chr(10),"ALL");
    //now make Macintosh style into Unix style
    str = replace(str,chr(13),chr(10),"ALL");
    //now fix tabs
    //str = replace(str,chr(9),"&amp;nbsp;&amp;nbsp;&amp;nbsp;","ALL");
     str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
    //now return the text formatted in HTML
    return replace(str,chr(10),"<br />","ALL");
}
</cfscript>

<cfif structKeyExists(variables, "entry") and entry.recordCount is 1>

	<div data-role="page">
		<cfset portion = reReplace(entry.content, "<p[[:space:]]*/*>", "#chr(10)#", "all")>
		<cfset portion = reReplace(portion, "<br[[:space:]]*/*>", "#chr(10)#", "all")>
		<cfset portion = reReplace(portion, "<.*?>", "", "all")>
		<cfset portion = trim(portion)>
		
		<cfoutput>	
		<div data-role="header">
			<a href="http://#application.siteUrl#/index.cfm?nomobile=1" class="ui-btn-right" rel="external" data-icon="blogger-leave" data-iconpos="notext">Leave Mobile</a>		
			<h1>#entry.title#</h1>
		</div>

		<div data-role="content">
		#paragraphFormat2(portion)#
		
		<p>
		<a href="#entry.url#" data-role="button">Go to Blog Entry</a>
		</p>
		</div>

		<div data-role="footer">
			<h4>Created by Raymond Camden, coldfusionjedi.com</h4>
		</div>
		</cfoutput>

	</div>

<cfelse>
	
		<div data-role="page">

		<cfoutput>	
		<div data-role="header">
			<a href="http://#application.siteUrl#/index.cfm?nomobile=1" class="ui-btn-right" rel="external" data-icon="blogger-leave" data-iconpos="notext">Leave Mobile</a>		
			<h1>#application.siteTitle#</h1>
		</div>

		<div data-role="content">
		Invalid entry!
		</div>

		<div data-role="footer">
			<h4>Created by Raymond Camden, coldfusionjedi.com</h4>
		</div>
		</cfoutput>

	</div>
	
</cfif>