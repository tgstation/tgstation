//this function places received data into element with specified id.
var/const/js_byjax = {"
function replaceContent(id,content) {
	var parent = document.getElementById(id);
	if(typeof(parent)!=='undefined' && parent!=null){
		parent.innerHTML = content?content:'';
	}
}
"}

/*
sends data to control_id:replaceContent

receiver - mob
control_id - window id (for windows opened with browse(), it'll be "windowname.browser")
target_element - HTML element id
new_content - HTML content
callback - js function that will be called after the data is sent //TODO: move callback processing to js
callback_args - arguments for callback function

Be sure to include required js functions in your page, or it'll raise an exception.
*/
proc/send_byjax(receiver, control_id, target_element, new_content=null, callback=null, list/callback_args=null)
	if(receiver && target_element && control_id) // && winexists(receiver, control_id))
		receiver << output(list2params(list(target_element, new_content)),"[control_id]:replaceContent")
		if(callback)
			receiver << output(istype(callback_args)?list2params(callback_args):"","[control_id]:[callback]")
	return

