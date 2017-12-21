/datum/component/click_reciever
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/datum/component/click_intercept/intercepts = list()

/datum/component/click_reciever/Initialize(datum/component/click_intercept/relay_to)
	if(!isclient(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Click reciever component attempted to be applied to a non client!")
	add_intercept(relay_to)
	RegisterSignal(COMSIG_CLIENT_MOB_SWITCH, .proc/on_mob_switch)
	RegisterSignal(COMSIG_CLIENT_CLICK, .proc/click)
	RegisterSignal(COMSIG_CLIENT_DBLCLICK, .proc/dblclick)
	RegisterSignal(COMSIG_CLIENT_MOUSEMOVE, .proc/mousemove)
	RegisterSignal(COMSIG_CLIENT_MOUSEDRAG, .proc/mousedrag)
	RegisterSignal(COMSIG_CLIENT_MOUSEDROP, .proc/mousedrop)
	RegisterSignal(COMSIG_CLIENT_MOUSEDOWN, .proc/mousedown)
	RegisterSignal(COMSIG_CLIENT_MOUSEUP, .proc/mouseup)
	RegisterSignal(COMSIG_CLIENT_MOUSEWHEEL, .proc/mousewheel)

/datum/component/click_reciever/Destroy()
	for(var/i in intercepts)
		remove_intercept(i)
	return ..()

/datum/component/click_reciever/InheritComponent(datum/component/click_reciever/R, is_original)
	if(is_original)
		for(var/i in R.intercepts)
			R.remove_intercept(i)
			add_intercept(i)
	return ..()

/datum/component/click_reciever/proc/remove_intercept(datum/component/click_intercept/intercept)
	intercepts -= intercept
	intercept.reciever_destroyed(src)
	if(!length(intercepts))
		qdel(src)

/datum/component/click_reciever/proc/add_intercept(datum/component/click_intercept/intercept)
	intercepts += intercept
	intercept.reciever_added(src)

/datum/component/click_reciever/proc/on_mob_switch(mob/oldmob, mob/newmob)
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(!intercept.persists_on_mob_change)
			remove_intercept(i)

/datum/component/click_reciever/proc/click(atom/A, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.click_callback)
			. |= intercept.click_callback.Invoke(C.mob, A, params)

/datum/component/click_reciever/proc/dblclick(atom/A, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.dblclick_callback)
			. |= intercept.dblclick_callback.Invoke(C.mob, A, params)

/datum/component/click_reciever/proc/mousemove(object, location, control, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.mousemove_callback)
			. |= intercept.mousemove_callback.Invoke(C.mob, object, location, control, params)

/datum/component/click_reciever/proc/mousewheel(atom/A, delta_x, delta_y, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.mousewheel_callback)
			. |= intercept.mousewheel_callback.Invoke(C.mob, A, delta_x, delta_y, params)

/datum/component/click_reciever/proc/mousedrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.mousedrag_callback)
			. |= intercept.mousedrag_callback.Invoke(C.mob, src_object, over_object, src_location, over_location, src_control, over_control, params)

/datum/component/click_reciever/proc/mousedrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.mousedrop_callback)
			. |= intercept.mousedrop_callback.Invoke(C.mob, over, src_location, over_location, src_control, over_control, params)

/datum/component/click_reciever/proc/mousedown(object, location, control, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.mousedown_callback)
			. |= intercept.mousedown_callback.Invoke(C.mob, object, location, control, params)

/datum/component/click_reciever/proc/mouseup(object, location, control, params)
	. = NONE
	var/client/C = parent
	for(var/i in intercepts)
		var/datum/component/click_intercept/intercept = i
		if(intercept.mouseup_callback)
			. |= intercept.mouseup_callback.Invoke(C.mob, object, location, control, params)
