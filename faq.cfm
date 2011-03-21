<!---
	Name         : faq.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : The FAQ page.
--->

<cf_layout title="#application.siteTitle# - FAQ">

<cfoutput>
<h2>Frequently Asked Questions</h2>

<p>
<a href="##q2">What blogs do you aggregate?</a><br>
<a href="##q3">Can you add my blog?</a><br>
<a href="##q3a">Is there a ping service?</a><br>
<a href="##q3b">Can I control how many items are shown per page?</a><br>

<a name="q2"></a>
<p>
<b>What blogs do you aggregate?</b><br />
For a full list of the blogs aggregated, hit the <a href="feeds.cfm">feeds</a> page. There is
also an <a href="opml.cfm">OPML</a> feed.
</p>


<a name="q3"></a>
<p>
<b>Can you add my blog?</b><br />
Use the contact link above to send me an email with your blog name, url, and RSS feed.
</p>

<a name="q3a"></a>
<p>
<b>Is there a ping service?</b><br />
Yes. To ping this site, first figure out the <i>exact</i> URL we have on record for your blog. You
can find this on the <a href="feeds.cfm">Feeds</a> page. Then simply set your blog software to ping:
</p>
<p>
http://#application.siteUrl#/ping.cfm?burl=YOURURL
</p>
<p>
If it worked correctly, you will get an &quot;Ok&quot; response.
</p>

<a name="q3b"></a>
<p>
<b>Can I control how many items are shown per page?</b><br />
<p>
If you add a perpage=X to the URL, where X is a number from 1 to 100, you can set how many items the site will show per page. 
This value is stored in a cookie so you only need to do it once.
</p>


</cfoutput>

</cf_layout>