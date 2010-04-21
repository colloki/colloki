// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function showStoryOps(storyId, type){
	showDiv("storyEdit"+storyId);
	if (type == "link")
		document.getElementById("storyGotoLink"+storyId).innerHTML = "Go to link&raquo;";
//	showDiv("storyGotoLink"+storyId);	
}

function hideStoryOps(storyId, type) {
	hideDiv("storyEdit"+storyId);
	if(type == "link")
		document.getElementById("storyGotoLink"+storyId).innerHTML = "";	
//	hideDiv("storyGotoLink"+storyId);		
}

function showDiv(divId) {
	document.getElementById(divId).style.display='inline';
}

function hideDiv(divId) {
	document.getElementById(divId).style.display='none';
}