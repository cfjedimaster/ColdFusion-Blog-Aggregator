<!---+ 
Note: Twitter is rather slow, you'll want to wrap this in some kind of caching system.
	
When requesting XML, the response is UTF-8 encoded.  Symbols and characters outside of the standard ASCII range are translated to HTML entities.

HTTP Status Codes

The Twitter API attempts to return appropriate HTTP status codes for every request. Here's what's going on with our various status codes:
200 OK: everything went awesome.
304 Not Modified: there was no new data to return.
400 Bad Request: your request is invalid, and we'll return an error message that tells you why. This is the status code returned if you've exceeded the rate limit (see below). 
401 Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
403 Forbidden: we understand your request, but are refusing to fulfill it.  An accompanying error message should explain why.
404 Not Found: either you're requesting an invalid URI or the resource in question doesn't exist (ex: no such user). 
500 Internal Server Error: we did something wrong.  Please post to the group about it and the Twitter team will investigate.
502 Bad Gateway: returned if Twitter is down or being upgraded.
503 Service Unavailable: the Twitter servers are up, but are overloaded with requests.  Try again later.
When the Twitter API returns error messages, it attempts to do in your requested format.  For example, an error from an XML method might look like this:
 
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <request>/direct_messages/destroy/456.xml</request>
  <error>No direct message with that ID found.</error>
</hash>  

Clients are allowed 70 requests per 60 sixty minute time period, starting from their first request.  This is enough to make just over one request per minute, per hour, which should meet the needs of most applications.  Rate limiting applies only to authenticated API requests; requests for the public timeline do not count.  POST requests (ex: updating status, sending a direct message) also do not count against the rate limit.  
 
Notification that a client has exceeded the rate limit will be sent as JSON or XML when either is the requested format, and otherwise will be sent in plain text.  A status code of 400 will be returned when the client has exceeded the rate limit.
 
The Twitter API attempts supports UTF-8 encoding to the extent that our infrastructure (Ruby, MySQL, etc.) does.  Please note that angle brackets ("<" and ">") are entity-encoded to prevent Cross-Site Scripting attacks for web-embedded consumers of JSON API output.  The resulting encoded entities do count towards the 140 character limit. 
--->

<cfcomponent output="false">

	<!---+
	--->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="defaultFormat" type="string" required="false" default="xml">
		
		<cfset variables.username = arguments.username>
		<cfset variables.password = arguments.password>
		<cfset variables.defaultFormat = arguments.defaultFormat>
		
		<cfreturn this>
	</cffunction>
	
	<!---+
		Sends a raw twitter request.
	--->
	<cffunction name="sendRawRequest" access="private" returntype="any" output="false">
		<cfargument name="method" type="string" required="true">
		<cfargument name="resource" type="string" required="true">
		<cfargument name="params" type="struct" required="true">

		<cfset var key = "">
		<cfset var queryString = "">
		<cfset var response = "">
		<cfset var returnFormat = arguments.params.format>
		
		<cfset structDelete(arguments.params,"format")>
		
		<!--- Magic to past rest params as /:controller/:action/:id --->
		<cfif structKeyExists(arguments.params,"id")>
			<cfset arguments.resource = arguments.resource & "/" & arguments.params.id>
			<cfset structDelete(arguments.params,"id")>
		</cfif>
			
		<!--- Generate the query string if we're in GET mode --->
		<cfif arguments.method eq "get">
			<cfloop collection="#arguments.params#" item="key">
				<!--- Deal with nulls so passing the arguments scope works properly. --->
				<cfif structKeyExists(arguments.params,key)>
					<cfset queryString = queryString & "&#URLEncodedFormat(lCase(key))#=#URLEncodedFormat(arguments.params[key])#">
				</cfif>
			</cfloop>
		</cfif>
						
		<cfhttp 
			url="http://twitter.com/#arguments.resource#.#returnFormat#?#queryString#"
			method="#arguments.method#"
			username="#variables.username#" 
			password="#variables.password#"
			useragent="ColdFusion/8.0">
			
			<cfif arguments.method eq "post">
				<cfloop collection="#arguments.params#" item="key">
					<!--- Deal with nulls so passing the arguments scope works properly. --->
					<cfif structKeyExists(arguments.params,key)>
						<cfhttpparam name="#lCase(key)#" value="#arguments.params[key]#" type="formfield">
					</cfif>
				</cfloop>
			</cfif>
		</cfhttp>
		
		<!--- Mold cfhttp into the data structure we want --->
		<cfset response = duplicate(cfhttp)>
		<cfset response.fileContent = toString(response.fileContent)>
		<cfset response.success = response.statusCode eq "200 OK">
		<cfset response.body = response.fileContent>
		<cfset response.headers = response.responseHeader>
		
		<cfreturn response>
	</cffunction>
	
	<!---
	public_timeline

	Returns the 20 most recent statuses from non-protected users who have set a custom user icon.  Does not require authentication.
	URL: http://twitter.com/statuses/public_timeline.format
	Formats: xml, json, rss, atom 
	Parameters:  
	since_id.  Optional.  Returns only public statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/public_timeline.xml?since_id=12345
	--->
	<cffunction name="statuses_public_timeline" access="public" returntype="any" output="false">
		<cfargument name="since_id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
				
		<cfreturn sendRawRequest("get","statuses/public_timeline",arguments)>
	</cffunction>

	<!---
	friends_timeline

	Returns the 20 most recent statuses posted in the last 24 hours from the authenticating user and that user's friends.  It's also possible to request another user's friends_timeline via the id parameter below.
	URL: http://twitter.com/statuses/friends_timeline.format
	Formats: xml, json, rss, atom
	Parameters:
	id.  Optional.  Specifies the ID or screen name of the user for whom to return the friends_timeline.  Ex: http://twitter.com/statuses/friends_timeline/12345.xml or http://twitter.com/statuses/friends_timeline/bob.json.
	since.  Optional.  Narrows the returned results to just those statuses created after the specified HTTP-formatted date.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/friends_timeline.rss?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	page. Optional.  Gets the 20 next most recent statuses from the authenticating user and that user's friends.  Ex: http://twitter.com/statuses/friends_timeline.rss?page=3 TEMPORARILY DISABLED
	--->
	<cffunction name="statuses_friends_timeline" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/friends_timeline",arguments)>
	</cffunction>	

	<!---
	user_timeline

	Returns the 20 most recent statuses posted in the last 24 hours from the authenticating user.  It's also possible to request another user's timeline via the id parameter below.
	URL: http://twitter.com/statuses/user_timeline.format
	Formats: xml, json, rss, atom
	Parameters:
	id.  Optional.  Specifies the ID or screen name of the user for whom to return the friends_timeline.  Ex: http://twitter.com/statuses/user_timeline/12345.xml or http://twitter.com/statuses/user_timeline/bob.json.
	count.  Optional.  Specifies the number of statuses to retrieve.  May not be greater than 20 for performance purposes.  Ex: http://twitter.com/statuses/user_timeline?count=5 
	since.  Optional.  Narrows the returned results to just those statuses created after the specified HTTP-formatted date.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/user_timeline.rss?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/user_timeline.xml?since_id=12345
	--->
	<cffunction name="statuses_user_timeline" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="false">
		<cfargument name="count" type="numeric" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="since_id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/user_timeline",arguments)>
	</cffunction>

	<!---
	show

	Returns a single status, specified by the id parameter below.  The status's author will be returned inline.
	URL: http://twitter.com/statuses/show/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The numerical ID of the status you're trying to retrieve.  Ex: http://twitter.com/statuses/show/123.xml 
	--->
	<cffunction name="statuses_show" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/show",arguments)>
	</cffunction>	

	<!---
	update

	Updates the authenticating user's status.  Requires the status parameter specified below.  Request must be a POST.
	URL: http://twitter.com/statuses/update.format
	Formats: xml, json.  Returns the posted status in requested format when successful.
	Parameters:
	status.  Required.  The text of your status update.  Be sure to URL encode as necessary.  Must not be more than 160 characters and should not be more than 140 characters to ensure optimal display.
	--->
	<cffunction name="statuses_update" access="public" returntype="any" output="false">
		<cfargument name="status" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<!--- Truncate to proper length??
		<cfset arguments.status = mid(arguments.status,1,160)>
		--->
	
		<cfreturn sendRawRequest("post","statuses/update",arguments)>
	</cffunction>

	<!---
	replies

	Returns the 20 most recent replies (status updates prefixed with @username posted by users who are friends with the user being replied to) to the authenticating user.  Replies are only available to the authenticating user; you can not request a list of replies to another user whether public or protected.
	URL: http://twitter.com/statuses/replies.format
	Formats: xml, json, rss, atom
	Parameters:
	page.  Optional. Retrieves the 20 next most recent replies.  Ex: http://twitter.com/statuses/replies.xml?page=3
	since.  Optional.  Narrows the returned results to just those replies created after the specified HTTP-formatted date.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/replies.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/replies.xml?since_id=12345
	--->
	<cffunction name="statuses_replies" access="public" returntype="any" output="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="since_id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/replies",arguments)>
	</cffunction>	

	<!---
	destroy
	Destroys the status specified by the required ID parameter.  The authenticating user must be the author of the specified status.
	URL: http://twitter.com/statuses/destroy/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID of the status to destroy.  Ex: http://twitter.com/statuses/destroy/12345.json or http://twitter.com/statuses/destroy/23456.xml
	--->
	<cffunction name="statuses_destroy" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/destroy",arguments)>
	</cffunction>

	<!--- User Methods --->

	<!---
	friends

	Returns up to 100 of the authenticating user's friends who have most recently updated, each with current status inline.  It's also possible to request another user's recent friends list via the id parameter below. 
	URL: http://twitter.com/statuses/friends.format
	Formats: xml, json
	Parameters:
	id.  Optional.  The ID or screen name of the user for whom to request a list of friends.  Ex: http://twitter.com/statuses/friends/12345.json or http://twitter.com/statuses/friends/bob.xml
	page.  Optional. Retrieves the next 100 friends.  Ex: http://twitter.com/statuses/friends.xml?page=2 
	lite. Optional.  Prevents the inline inclusion of current status.  Must be set to a value of true.  Ex: http://twitter.com/statuses/friends.xml?lite=true
	since.  Optional.  Narrows the returned results to just those friendships created after the specified HTTP-formatted date.  The same behavior is available by setting an If-Modified-Since header in your HTTP request.  Ex: http://twitter.com/statuses/friends.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	--->
	<cffunction name="statuses_friends" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="lite" type="boolean" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/friends",arguments)>
	</cffunction>

	<!---
	followers

	Returns the authenticating user's followers, each with current status inline. 
	URL: http://twitter.com/statuses/followers.format
	Formats: xml, json
	Parameters: 
	page.  Optional. Retrieves the next 100 followers.  Ex: http://twitter.com/statuses/followers.xml?page=2
	lite. Optional.  Prevents the inline inclusion of current status.  Must be set to a value of true.  Ex: http://twitter.com/statuses/followers.xml?lite=true
	--->
	<cffunction name="statuses_followers" access="public" returntype="any" output="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="lite" type="boolean" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/followers",arguments)>
	</cffunction>

	<!---
	featured

	Returns a list of the users currently featured on the site with their current statuses inline.
	URL: http://twitter.com/statuses/featured.format 
	Formats: xml, json
	--->
	<cffunction name="statuses_featured" access="public" returntype="any" output="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","statuses/featured",arguments)>
	</cffunction>	

	<!---
	show

	Returns extended information of a given user, specified by ID or screen name as per the required id parameter below.  This information includes design settings, so third party developers can theme their widgets according to a given user's preferences.
	URL: http://twitter.com/users/show/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID or screen name of a user.  Ex: http://twitter.com/users/show/12345.json or http://twitter.com/users/show/bob.xml
	email. Optional.  The email address of a user.  Ex: http://twitter.com/users/show.xml?email=test@example.com
	Notes:
	If you are trying to fetch data for a user who is only giving updates to friends, the returned text will be "You are not authorized to see this user." 
	--->
	<cffunction name="users_show" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="false">
		<cfargument name="email" type="string" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","users/show",arguments)>
	</cffunction>

	<!--- Direct Message Methods --->

	<!---
	direct_messages

	Returns a list of the 20 most recent direct messages sent to the authenticating user.  The XML and JSON versions include detailed information about the sending and recipient users.
	URL: http://twitter.com/direct_messages.format
	Formats: xml, json, rss, atom 
	Parameters:
	since.  Optional.  Narrows the resulting list of direct messages to just those sent after the specified HTTP-formatted date.  The same behavior is available by setting the If-Modified-Since parameter in your HTTP request.  Ex: http://twitter.com/direct_messages.atom?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	since_id.  Optional.  Returns only direct messages with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/direct_messages.xml?since_id=12345
	page.  Optional. Retrieves the 20 next most recent direct messages.  Ex: http://twitter.com/direct_messages.xml?page=3
	--->
	<cffunction name="direct_messages" access="public" returntype="any" output="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="since_id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","direct_messages",arguments)>
	</cffunction>

	<!---
	sent

	Returns a list of the 20 most recent direct messages sent by the authenticating user.  The XML and JSON versions include detailed information about the sending and recipient users.
	URL: http://twitter.com/direct_messages/sent.format
	Formats: xml, json
	Parameters:
	since.  Optional.  Narrows the resulting list of direct messages to just those sent after the specified HTTP-formatted date.  The same behavior is available by setting the If-Modified-Since parameter in your HTTP request.  Ex: http://twitter.com/direct_messages/sent.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	since_id.  Optional.  Returns only sent direct messages with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/direct_messages/sent.xml?since_id=12345
	page.  Optional. Retrieves the 20 next most recent direct messages sent.  Ex: http://twitter.com/direct_messages/sent.xml?page=3
	--->
	<cffunction name="direct_messages_sent" access="public" returntype="any" output="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="since_id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","direct_messages/sent",arguments)>
	</cffunction>	

	<!---
	new

	Sends a new direct message to the specified user from the authenticating user.  Requires both the user and text parameters below.  Request must be a POST.  Returns the sent message in the requested format when successful.
	URL: http://twitter.com/direct_messages/new.format
	Formats: xml, json  
	Parameters:
	user.  Required.  The ID or screen name of the recipient user.
	text.  Required.  The text of your direct message.  Be sure to URL encode as necessary, and keep it under 140 characters.  
	--->
	<cffunction name="direct_messages_new" access="public" returntype="any" output="false">
		<cfargument name="user" type="string" required="true">
		<cfargument name="text" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<!--- Truncate to proper length??
		<cfset arguments.text = mid(arguments.text,1,140)>
		--->
		
		<cfreturn sendRawRequest("post","direct_messages/new",arguments)>
	</cffunction>

	<!---
	destroy
	Destroys the direct message specified in the required ID parameter.  The authenticating user must be the recipient of the specified direct message.
	URL: http://twitter.com/direct_messages/destroy/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID of the direct message to destroy.  Ex: http://twitter.com/direct_messages/destroy/12345.json or http://twitter.com/direct_messages/destroy/23456.xml
	--->
	<cffunction name="direct_messages_destory" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","direct_messages/destroy",arguments)>		
	</cffunction>

	<!--- Friendship Methods --->

	<!---
	create

	Befriends the user specified in the ID parameter as the authenticating user.  Returns the befriended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
	URL: http://twitter.com/friendships/create/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID or screen name of the user to befriend.  Ex: http://twitter.com/friendships/create/12345.json or http://twitter.com/friendships/create/bob.xml
	--->
	<cffunction name="friendships_create" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","friendships/create",arguments)>
	</cffunction>

	<!---
	destroy

	Discontinues friendship with the user specified in the ID parameter as the authenticating user.  Returns the un-friended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.
	URL: http://twitter.com/friendships/destroy/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID or screen name of the user with whom to discontinue friendship.  Ex: http://twitter.com/friendships/destroy/12345.json or http://twitter.com/friendships/destroy/bob.xml
	--->
	<cffunction name="friendships_destroy" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","friendships/destroy",arguments)>
	</cffunction>	

	<!---
	exists

	Tests if friendship exists between the two users specified in the parameter specified below.
	URL: http://twitter.com/friendships/exists.format
	Formats: xml, json, none
	Parameters:
	user_a.  Required.  The ID or screen_name of the first user to test friendship for.
	user_b.  Required.  The ID or screen_name of the second user to test friendship for.
	Ex: http://twitter.com/friendships/exists.xml?user_a=alice&user_b=bob
	--->
	<cffunction name="friendships_exists" access="public" returntype="any" output="false">
		<cfargument name="user_a" type="string" required="true">
		<cfargument name="user_b" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","friendships/exists",arguments)>
	</cffunction>	
	
	<!--- Account Methods --->

	<!---
	rate_limit_status

	[Added May 27, 2008] From time to time, Twitter may lower the rate limit to preserve system stability. To find the current rate limit, use http://twitter.com/account/rate_limit_status (available in .xml and .json).
	
	Calls to rate_limit_status require authentication, but will not count against the rate limit.
	--->
	<cffunction name="account_rate_limit_status" access="public" returntype="any" output="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","account/rate_limit_status",arguments)>
	</cffunction>	
	
	<!---
	verify_credentials

	Returns an HTTP 200 OK response code and a format-specific response if authentication was successful.  Use this method to test if supplied user credentials are valid with minimal overhead.
	URL: http://twitter.com/account/verify_credentials.format
	Formats: text (returned when no format is specified), xml, json
	--->
	<cffunction name="account_verify_credentials" access="public" returntype="any" output="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","account/verify_credentials",arguments)>
	</cffunction>

	<!---
	end_session

	Ends the session of the authenticating user, returning a null cookie.  Use this method to sign users out of client-facing applications like widgets.
	URL: http://twitter.com/account/end_session
	Formats: N/A
	--->
	<cffunction name="account_end_session" access="public" returntype="any" output="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","account/end_session",arguments)>
	</cffunction>

	<!---
	archive

	Returns 80 statuses per page for the authenticating user, ordered by descending date of posting.  Use this method to rapidly export your archive of statuses.
	URL: http://twitter.com/account/archive.format
	Formats: xml, json
	Parameters:
	page.  Optional. Retrieves the 80 next most recent statuses.  Ex: http://twitter.com/account/archive.xml?page=2
	since.  Optional.  Narrows the resulting list of statuses to just those sent after the specified HTTP-formatted date.  The same behavior is available by setting the If-Modified-Since parameter in your HTTP request.  Ex: http://twitter.com/account/archive.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
	since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/account/archive.xml?since_id=12345
	--->
	<cffunction name="account_archive" access="public" returntype="any" output="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="since" type="date" required="false">
		<cfargument name="since_id" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","account/archive",arguments)>
	</cffunction>

	<!---
	update_location New as of April 29th, 2008!
	Updates the location attribute of the authenticating user, as displayed on the side of their profile and returned in various API methods.  Works as either a POST or a GET.
	URL: http://twitter.com/account/update_location.format
	Formats: xml, json
	Parameters:
	location.  Required.  The location of the user.  Please note this is not normalized, geocoded, or translated to latitude/longitude at this time.  Ex: http://twitter.com/account/update_location.xml?location=San%20Francisco
	--->
	<cffunction name="account_update_location" access="public" returntype="any" output="false">
		<cfargument name="location" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("post","account/update_location",arguments)>
	</cffunction>
	
	<!---
	update_delivery_device New as of April 29th, 2008!
	Sets which device Twitter delivers updates to for the authenticating user.  Sending none as the device parameter will disable IM or SMS updates.
	URL: http://twitter.com/account/update_delivery_device.format
	Formats: xml, json
	Parameters:
	device.  Required.  Must be one of: sms, im, none.  Ex: http://twitter.com/account/update_delivery_device?device=im
	--->
	<cffunction name="account_update_delivery_device" access="public" returntype="any" output="false">
		<cfargument name="device" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","account/update_delivery_device",arguments)>		
	</cffunction>
	
	<!--- Favorite Methods --->

	<!---
	favorites

	Returns the 20 most recent favorite statuses for the authenticating user or user specified by the ID parameter in the requested format.  
	URL: http://twitter.com/favorites.format
	Formats: xml, json, rss, atom
	Parameters:
	id.  Optional.  The ID or screen name of the user for whom to request a list of favorite statuses.  Ex: http://twitter.com/favorites/bob.json or http://twitter.com/favorites/bob.rss
	page.  Optional. Retrieves the 20 next most recent favorite statuses.  Ex: http://twitter.com/favorites.xml?page=3 
	--->
	<cffunction name="favorites" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="false">
		<cfargument name="page" type="numeric" required="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","favorites",arguments)>
	</cffunction>

	<!---
	create

	Favorites the status specified in the ID parameter as the authenticating user.  Returns the favorite status when successful.
	URL: http://twitter.com/favorites/create/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID of the status to favorite.  Ex: http://twitter.com/favorites/create/12345.json or http://twitter.com/favorites/create/45567.xml
	--->
	<cffunction name="favorites_create" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","favorites/create",arguments)>
	</cffunction>

	<!---
	destroy

	Un-favorites the status specified in the ID parameter as the authenticating user.  Returns the un-favorited status in the requested format when successful.
	URL: http://twitter.com/favorites/destroy/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID of the status to un-favorite.  Ex: http://twitter.com/favorites/destroy/12345.json or http://twitter.com/favorites/destroy/23456.xml 
	--->
	<cffunction name="favorites_destroy" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","favorites/destroy",arguments)>
	</cffunction>

	<!--- Notification Methods --->

	<!---
	follow

	Enables notifications for updates from the specified user to the authenticating user.  Returns the specified user when successful.
	URL:http://twitter.com/notifications/follow/id.format
	Formats: xml, json
	Parameters: 
	id.  Required.  The ID or screen name of the user to follow.  Ex:  http://twitter.com/notifications/follow/12345.xml or http://twitter.com/notifications/follow/bob.json 
	--->
	<cffunction name="notifications_follow" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","notifications/follow",arguments)>
	</cffunction>

	<!---
	leave

	Disables notifications for updates from the specified user to the authenticating user.  Returns the specified user when successful.
	URL: http://twitter.com/notifications/leave/id.format
	Formats: xml, json
	Parameters: 
	id.  Required.  The ID or screen name of the user to leave.  Ex:  http://twitter.com/notifications/leave/12345.xml or http://twitter.com/notifications/leave/bob.json 
	--->
	<cffunction name="notifications_leave" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","notifications/leave",arguments)>
	</cffunction>
	
	<!--- Block Methods --->

	<!---
	create  New as of April 29th, 2008!

	Blocks the user specified in the ID parameter as the authenticating user.  Returns the blocked user in the requested format when successful.  You can find out more about blocking in the Twitter Support Knowledge Base.
	URL: http://twitter.com/blocks/create/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID or screen_name of the user to block.  Ex: http://twitter.com/blocks/create/12345.json or http://twitter.com/blocks/create/bob.xml
	--->
	<cffunction name="blocks_create" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","blocks/create",arguments)>		
	</cffunction>
	
	<!---
	destroy  New as of April 29th, 2008!

	Un-blocks the user specified in the ID parameter as the authenticating user.  Returns the un-blocked user in the requested format when successful.
	URL: http://twitter.com/blocks/destroy/id.format
	Formats: xml, json
	Parameters:
	id.  Required.  The ID or screen_name of the user to un-block.  Ex: http://twitter.com/blocks/destroy/12345.json or http://twitter.com/blocks/destroy/bob.xml 
	--->
	<cffunction name="blocks_destory" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="true">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","blocks/destory",arguments)>
	</cffunction>
	
	<!--- Help Methods --->

	<!---
	test  New as of April 29th, 2008!

	Returns the string "ok" in the requested format with a 200 OK HTTP status code.
	URL:http://twitter.com/help/test.format
	Formats: xml, json
	--->
	<cffunction name="help_test" access="public" returntype="any" output="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","help/test",arguments)>
	</cffunction>
	
	<!---
	downtime_schedule  New as of April 29th, 2008!

	Returns the same text displayed on http://twitter.com/home when a maintenance window is scheduled, in the requested format.
	URL:http://twitter.com/help/downtime_schedule.format
	Formats: xml, json	
	--->
	<cffunction name="help_downtime_schedule" access="public" returntype="any" output="false">
		<cfargument name="format" type="string" required="false" default="#variables.defaultFormat#">
		
		<cfreturn sendRawRequest("get","help/downtime_schedule",arguments)>		
	</cffunction>

</cfcomponent>