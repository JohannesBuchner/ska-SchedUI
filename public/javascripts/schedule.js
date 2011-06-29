// jQuery.noConflict();

var total = schedule_space.keys.length
var selectionStart = -1;
var selectionEnd = -1;
var buttonDown = false;

function getElementById(arr, id) {
	for (var i = 0; i < arr.length; i++) {
		if (arr[i].id == id)
			return arr[i];
	}
}

function menuItemFromJobCombination(jc) {
	var html = "<span class='parallel'>";
	for (var jid = 0; jid < jc.length; jid++) {
		j = jc[jid];
		var taskid = j.proposal + "." + j.job;
		var p = getElementById(proposals, j.proposal);
		var j = getElementById(p.jobs, j.job);
		var taskname = p.name + " task " + j.id + " (" + j.hours + ")";
		if (html == "") {
			html += " and ";
		}
		html += "<span class='" + taskid + "'>" + taskname + "</span>";
	}
	html += "</span>";
	console.log(html);
	action = {
		type:"fn",
		callback: function() {
			alert('THIS IS THE TEST');
		}
	}

	return {
		title: html,
		action: action,
	};
}

function slotIdFromHtmlId(html_id) {
	return parseInt(html_id.substr("slot_".length));
}

function getOptions(data) {
	var html_id = triggerElement.id;
	var id = slotIdFromHtmlId(html_id);

	menu = []
	options = schedule_space[id];
	for (var i = 0; i < options.length; i++) {
		menu.push(menuItemFromJobCombination(options[i]));
	}
	parentmenu = [{
		title:"prefer",
		type:"sub",
		src:menu,
		customClass:"prefer_menu_item",
	},{
		title:"require",
		type:"sub",
		src:menu,
		customClass:"require_menu_item",
	}];
	return parentmenu;
};

menuoptions =  [{
	getByFunction:getOptions
},
/*
* {
title:"Go to www.google.com",
action: {
type:"gourl",
url:"http://www.google.com/"
}
},{
title:"do <b style='color:red;'>nothing</b>"
},
*/

//type:"sub", src:[{title:"Submenu 1"},{title:"Submenu 2"},{title:"Submenu 3"},
// {title:"Submenu 4 - submenu", type:"sub", src:[{title:"SubSubmenu
// 1"},{title:"SubSubmenu 2"}]}]},
//action:{type:"fn",callback:"(function(){ alert('THIS IS THE TEST'); })"}}
];


function isSlot(slotid) {
	if (typeof slotid === "undefined")
		return false;
	return slotid.substring(0, "slot_".length) === "slot_";
}

function findSlot(el) {
	console.log("was called with " + el + " (id = " + el.id + ")");
	for(i = 0; i < 3; i++) {
		if (isSlot(el.id))
			break;
		el = el.parentNode;
		console.log("moved up once to " + el + " (id = " + el.id + ")");
	}
	return el;
}

jQuery.fn.extend({
	disableSelection : function() {
		return this.each( function() {
			this.onselectstart = function() {
				return false;
			};
			this.unselectable = "on";
			jQuery(this).css('user-select', 'none');
			jQuery(this).css('-o-user-select', 'none');
			jQuery(this).css('-moz-user-select', 'none');
			jQuery(this).css('-khtml-user-select', 'none');
			jQuery(this).css('-webkit-user-select', 'none');
		});
	} ,
	enableSelection : function() {
		return this.each( function() {
			this.onselectstart = function() {
			};
			this.unselectable = "off";
			jQuery(this).css('user-select', '');
			jQuery(this).css('-o-user-select', '');
			jQuery(this).css('-moz-user-select', '');
			jQuery(this).css('-khtml-user-select', '');
			jQuery(this).css('-webkit-user-select', '');
		});
	}
});

function endSelection(event) {
	if (event.button == 0 && buttonDown == true) {
		// finish selecting
		selectionEnd = slotIdFromHtmlId(findSlot(event.target).id);
		if (selectionStart > selectionEnd) {
			tmp = selectionEnd;
			selectionEnd = selectionStart;
			selectionStart = tmp;
		}
		for (i = 0; i <= schedule_space.keys.length; i++) {
			k = schedule_space.keys[i];
			if (k >= selectionStart && k <= selectionEnd) {
				$("#slot_" + k).css("background", "green");
			} else {
				$("#slot_" + k).css("background", "");
			}
		}
	}
}

function startSelection(event) {
	if (event.button == 0) {
		// start selecting
		selectionStart = slotIdFromHtmlId(findSlot(event.target).id);
		selectionEnd = -1;
		buttonDown = true;
		$(findSlot(event.target)).css("background", "yellow");
	}
}
function saveEndSelection(event) {
	if (event.button == 0) {
		buttonDown = false;
	}
}

function start() {

	menuposition = {};

	$("table.schedule td").bind("mousedown", startSelection );
	$("table.schedule td").bind("mouseup mouseover", endSelection);
	$("table.schedule td").bind("mouseup", saveEndSelection)
	$("table.schedule td").bind("mouseover", function(event) {
		$("#info").html("currently looking at " + event.target.id + " with content " + $("#" + event.target.id).html());
	});
	$("table.schedule td").jjmenu("rightClick", menuoptions, {}, menuposition);
}

(function($) {
	$(document).ready(start);
} ) ( jQuery );