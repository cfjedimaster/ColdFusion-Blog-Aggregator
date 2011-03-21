<cfajaximport tags="cfwindow,cfform" />

<html>
<head>
<script type="text/javascript">
//global vars
var isChanged = "";
var myURL = "";
feedWinCB = function(){
	if(isChanged) ColdFusion.Grid.refresh('feedGrid');
	document.forms['addfeed'].feedurl.value = '';
}

getFeedWin = function(id){
	isChanged = false;
	ColdFusion.Window.create("feedWin","Add/Edit Feed","feed.cfm?id="+id,
	{center:true,modal:true,draggable:true,resizable:true,width:550,height:235});
	ColdFusion.Window.onHide("feedWin",feedWinCB);
	ColdFusion.navigate("feed.cfm?id="+id,"feedWin");
	ColdFusion.Window.show("feedWin");
}

populateFeedWin = function(id){
	isChanged = false;
	myURL = ColdFusion.getElementValue('feedurl');
	myURL = escape(myURL);

	ColdFusion.Window.create("pfeedWin","Add Feed","feed.cfm?myurl="+myURL,
	{center:true,modal:true,draggable:true,resizable:true,width:550,height:235});
	ColdFusion.Window.onHide("pfeedWin",feedWinCB);
	ColdFusion.navigate("feed.cfm?myurl="+myURL,"pfeedWin");
	ColdFusion.Window.show("pfeedWin");

}

delCB = function(){
	ColdFusion.Grid.refresh('feedGrid');
	alert('Feed has been eliminated.');
}
delFeed = function(id){
	ColdFusion.navigate('../components/entriesProxy.cfc?method=deleteFeed&id='+id, 'delDiv', delCB);
}
</script>
</head>
<body>

<!---
<cfform name="addfeed" method="post" onSubmit="populateFeedWin(); return false;">
	<strong>Feed URL:</strong> 	<cfinput type="text" size="50" required="true" name="feedurl" id="feedurl" value="">
	<cfinput type="submit" name="submit" value="Add Feed">
</cfform>
--->

<cfform name="feedForm" method="post">

	<div>
		<div style="float:left; padding-bottom:10px;"><cfinput type="button" name="newFeedBtn" id="newFeedBtn" value="Add New Feed Manually" onclick="javascript:getFeedWin(0);"></div>
		<div style="clear:both;"></div>
	</div>

	<div>
		<div style="float:left; width:100px;">Search For:</div>
		<div style="float:left;"><cfinput type="text" name="searchString" /></div>
		<div style="clear:both;"></div>
	</div>
	<cfgrid name="feedGrid" format="html" pagesize="20"
		bind="cfc:components.entriesProxy.getFeeds({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection},{searchString@keyup})" sort="true" width="1200" height="500">
		<cfgridcolumn name="ID" header="ID" />
		<cfgridcolumn name="NAME" header="Name" width="200" />
		<cfgridcolumn name="DESCRIPTION" header="Description" width="300" />
		<cfgridcolumn name="URL" header="URL" width="220" />
		<cfgridcolumn name="STATUS" header="Status" width="300"/>
		<cfgridcolumn name="FEEDACTION" header="Action">
	</cfgrid>
</cfform>

<div id="delDiv" style="visibility:hidden;display:none;"></div>

</body>
</html>