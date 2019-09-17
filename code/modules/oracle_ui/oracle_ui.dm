/datum/oracle_ui
	var/width = 512
	var/height = 512
	var/can_close = TRUE
	var/can_minimize = FALSE
	var/can_resize = TRUE
	var/titlebar = TRUE
	var/window_id = null
	var/viewers[0]
	var/auto_check_view = TRUE
	var/auto_refresh = FALSE
	var/atom/datasource = null
	var/datum/asset/assets = null

/datum/oracle_ui/New(atom/n_datasource, n_width = 512, n_height = 512, n_assets = null)
	datasource = n_datasource
	window_id = REF(src)
	width = n_width
	height = n_height

/datum/oracle_ui/Destroy()
	close_all()
	if(src.datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSobj, src)
	return ..()

/datum/oracle_ui/process()
	if(auto_check_view)
		check_view_all()
	if(auto_refresh)
		render_all()

/datum/oracle_ui/proc/get_content(mob/target)
	return call(datasource, "oui_getcontent")(target)

/datum/oracle_ui/proc/can_view(mob/target)
	return call(datasource, "oui_canview")(target)

/datum/oracle_ui/proc/test_viewer(mob/target, updating)
	//If the target is null or does not have a client, remove from viewers and return
	if(!target | !target.client | !can_view(target))
		viewers -= target
		if(viewers.len < 1 && (src.datum_flags & DF_ISPROCESSING))
			STOP_PROCESSING(SSobj, src)  //No more viewers, stop polling
		close(target)
		return FALSE
	//If this is an update, and they have closed the window, remove from viewers and return
	if(updating && winget(target, window_id, "is-visible") != "true")
		viewers -= target
		if(viewers.len < 1 && (src.datum_flags & DF_ISPROCESSING))
			STOP_PROCESSING(SSobj, src) //No more viewers, stop polling
		return FALSE
	return TRUE

/datum/oracle_ui/proc/render(mob/target, updating = FALSE)
	set waitfor = FALSE //Makes this an async call
	if(!can_view(target))
		return
	//Check to see if they have the window open still if updating
	if(updating && !test_viewer(target, updating))
		return
	//Send assets
	if(!updating && assets)
		assets.send(target)
	//Add them to the viewers if they aren't there already
	viewers |= target
	if(!(src.datum_flags & DF_ISPROCESSING) && (auto_refresh | auto_check_view))
		START_PROCESSING(SSobj, src) //Start processing to poll for viewability
	//Send the content
	if(updating)
		target << output(get_content(target), "[window_id].browser")
	else
		target << browse(get_content(target), "window=[window_id];size=[width]x[height];can_close=[can_close];can_minimize=[can_minimize];can_resize=[can_resize];titlebar=[titlebar];focus=false;")
	steal_focus(target)

/datum/oracle_ui/proc/render_all()
	for(var/viewer in viewers)
		render(viewer, TRUE)

/datum/oracle_ui/proc/close(mob/target)
	if(target && target.client)
		target << browse(null, "window=[window_id]")

/datum/oracle_ui/proc/close_all()
	for(var/viewer in viewers)
		close(viewer)
	viewers = list()

/datum/oracle_ui/proc/check_view_all()
	for(var/viewer in viewers)
		check_view(viewer)

/datum/oracle_ui/proc/check_view(mob/target)
	set waitfor = FALSE //Makes this an async call
	if(!test_viewer(target, TRUE))
		close(target)

/datum/oracle_ui/proc/call_js(mob/target, js_func, list/parameters = list())
	set waitfor = FALSE //Makes this an async call
	if(!test_viewer(target, TRUE))
		return
	target << output(list2params(parameters),"[window_id].browser:[js_func]")

/datum/oracle_ui/proc/call_js_all(js_func, list/parameters = list())
	for(var/viewer in viewers)
		call_js(viewer, js_func, parameters)

/datum/oracle_ui/proc/steal_focus(mob/target)
	set waitfor = FALSE //Makes this an async call
	winset(target, "[window_id]","focus=true")

/datum/oracle_ui/proc/steal_focus_all()
	for(var/viewer in viewers)
		steal_focus(viewer)

/datum/oracle_ui/proc/flash(mob/target, times = -1)
	set waitfor = FALSE //Makes this an async call
	winset(target, "[window_id]","flash=[times]")

/datum/oracle_ui/proc/flash_all(times = -1)
	for(var/viewer in viewers)
		flash(viewer, times)

/datum/oracle_ui/proc/href(mob/user, action, list/parameters = list())
	var/params_string = replacetext(list2params(parameters),"&",";")
	return "?src=[REF(src)];sui_action=[action];sui_user=[REF(user)];[params_string]"

/datum/oracle_ui/Topic(href, parameters)
	var/action = parameters["sui_action"]
	var/mob/current_user = locate(parameters["sui_user"])
	if(!call(datasource, "oui_canuse")(current_user))
		return
	if(datasource)
		call(datasource, "oui_act")(current_user, action, parameters);
