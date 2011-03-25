<cfimport taglib="tags" prefix="ui" />

<cfsavecontent variable="js" >
	<cfoutput>
		<script src="includes/grid.locale-en.js"></script>
		<script src="includes/jquery.jqGrid.min.js"></script>
		<script src="includes/uni-form.jquery.min.js"></script>
		<link rel="stylesheet" href="includes/ui.jqgrid.css" type="text/css" />
		<link rel="stylesheet" href="includes/uni-form.css" type="text/css" />
		<link rel="stylesheet" href="includes/blue.uni-form.css" type="text/css" />
		<link rel="stylesheet" href="includes/custom.css" type="text/css" />
    	<script type="text/javascript">
    		
		$(document).ready(function(){
		
			$("##feeds").jqGrid({
		    url:'../components/entriesProxy.cfc?method=getFeeds&returnFormat=json',
		    datatype: 'json',
		    mtype: 'GET',
		    colNames:['',  'Name','Description', 'URL'],
		    colModel :[ 
			  {name:'id', index:'id',width:35, formatter:buttonFormatter},
		      {name:'name', index:'name', width:200}, 
		      {name:'description', index:'description', width:250}, 
		      {name:'url', index:'url', width:250} 
		     
		    ],
			width:735,
			height: 500,
			altRows: true,
		    pager: '##pager',
		    rowNum:20,
		    rowList:[10,20,30],
		    sortname: 'name',
		    sortorder: 'asc',
		    viewrecords: true,
			jsonReader : {
				repeatitems: false, 
				id: "id"
			},
		    caption: '#application.siteName# Feeds'
		  });
		  
		  $( "##deleteconfirm" ).dialog({
			resizable: false,
			autoOpen: false,
			modal: true,
			width: 500,
			position: ['center', 5],
			buttons: {
				"Delete feed": function() {
					$.get('../components/entriesProxy.cfc?method=deleteFeed&id=' + $("##deleteconfirm").attr("ref"), function(data){
						$("##feeds").trigger('reloadGrid');
						$( "##deleteconfirm" ).dialog( "close" );
					})
					
					
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
		
		$("##feedform").dialog({
			resizable: false,
			autoOpen: false,
			modal: true,
			width: 550,
			position: ['center', 5],
			buttons: {
				"Save Feed": function() {
					saveFeed();
				},
				"Close Window": function() {
					$( this ).dialog( "close" );
				}
			}
		})
		})
		
		function buttonFormatter( cellvalue, options, rowObject ){
			var txt = '<a href="javascript:;" title="Edit Feed" onclick="editFeed(' + cellvalue + ')"><img src="includes/document-edit.png" /></a>'
			txt = txt + '<a href="javascript:;" title="Delete Feed" onclick="deleteFeed(' + cellvalue + ')"><img src="includes/list-remove.png" /></a>'
			return txt;
		}
		
		function editFeed( id ){
			$("##feedform").load("feed.cfm?id="+id);
			$("##feedform").dialog( "option", "title", 'Edit Feed' );
			$("##feedform").dialog("open");
		}
		
		function addFeed(){
			$("##feedform").load("feed.cfm");
			$("##feedform").dialog( "option", "title", 'Add Feed' );
			$("##feedform").dialog("open");
			
		}
		
		function deleteFeed( id ){
			$("##deleteconfirm").attr( "ref", id )
			$("##deleteconfirm").dialog( 'open' );
		}
		
		function searchFeeds( s ){
			$('##feeds').setGridParam( { url:'../components/entriesProxy.cfc?method=getFeeds&returnFormat=json&filter=' + s } ).trigger( 'reloadGrid' )
		}
		
		function saveFeed(){
			var data = $("##feedForm").serializeArray();
			var s = new Object();
			s.name = "submit";
			s.value = Math.random();
			data.push(s);
			$("##feedform").load('feed.cfm', data, function(){
				$("##feeds").trigger('reloadGrid');
			});
		}
		

		</script>
    </cfoutput>
</cfsavecontent>
<cfhtmlhead text="#js#" />
<ui:adminLayout title="Feed List">
<cfoutput>
<div style="padding:1em;"><label for="filter">Search feeds:</label><input type="text" id="filter" onkeyup="searchFeeds( $(this).val() )" /><br /><button type="button" onclick="addFeed()">Add New Feed</button></div>
<table id="feeds"></table>
<div id="pager"></div>
</cfoutput>

<div id="deleteconfirm" title="Delete this Feed?" ref="0" style="display:none;">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>Are you sure you want to delete this feed?</p> <p>This action CANNOT be undone!</p>
</div>
<div id="feedform" style="display:none"></div>
</ui:adminlayout>