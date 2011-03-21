<!---
	Name         : contact.cfm
	Author       : Raymond Camden 
	Created      : July 29, 2007
	Last Updated : July 29, 2007
	History      : 
	Purpose		 : The contact form.
--->

<cfparam name="form.dname" default="Your Name">
<cfparam name="form.demail" default="Your Email">
<cfparam name="form.comments" default="">

<script>
$(document).ready(function() {
	$("#contactForm").submit(
		function(e) {
		var name = $("#dname").val()
		var email = $("#demail").val()
		var comments = $("#comments").val()
	
		var error = "";
		if(name == '' || name == 'Your Name') error+="Please include your name.\n";
		if(email == '' || email == 'Your Email') error+="Please include your email address.\n";
		if(comments == '') error+="Please include your comments.\n";
		
		if(error != '') { alert(error); e.preventDefault(); }
		else {
			$.post("sendcontact.cfm",{dname:name,demail:email,comments:comments},formDone);
			e.preventDefault()
		}
	})
})

clearDefaultName = function() {
	if($("#dname").val() == 'Your Name') $("#dname").val('')
}

clearDefaultEmail = function() {
	if($("#demail").val() == 'Your Email') $("#demail").val('')
}



formDone = function(resp) {
	alert('Thank you for your comments!');
	$("#contact").dialog("close")
}
</script>

<cfoutput>	
<form id="contactForm" action="contact.cfm" method="post">	
<p style="text-align:left;">				
<label>Name</label>
<input id="dname" name="dname" value="#form.dname#" type="text" size="30" onclick="clearDefaultName()" />
<label>Email</label>
<input id="demail" name="demail" value="#form.demail#" type="text" size="30" onclick="clearDefaultEmail()" />
<label>Your Comments</label>
<textarea rows="5" cols="5" name="comments" id="comments">#form.comments#</textarea>
<br />	
<input class="button" type="submit" value="Send Comments" />		
</p>		
</form>
</cfoutput>
