//Check click_reciever.dm on what the callbacks will send in terms of args!
/datum/component/click_intercept
	var/persists_on_mob_change = FALSE
	var/list/datum/component/click_reciever/recievers = list()
	var/datum/callback/click_callback
	var/datum/callback/dblclick_callback
	var/datum/callback/mousemove_callback
	var/datum/callback/mousewheel_callback
	var/datum/callback/mousedrag_callback
	var/datum/callback/mousedrop_callback
	var/datum/callback/mouseup_callback
	var/datum/callback/mousedown_callback

/datum/component/click_intercept/Initialize(clickcb, dblclickcb, movecb, wheelcb, dragcb, dropcb, upcb, downcb)
	click_callback = clickcb
	dblclick_callback = dblclickcb
	mousewheel_callback = wheelcb
	mousemove_callback = movecb
	mousedrag_callback = dragcb
	mousedrop_callback = dropcb
	mouseup_callback = upcb
	mousedown_callback = downcb

/datum/component/click_intercept/InheritComponent(datum/component/click_intercept/other, original)
	if(original)
		if(other.click_callback)
			click_callback = other.click_callback
		if(other.dblclick_callback)
			dblclick_callback = other.dblclick_callback
		if(other.mousewheel_callback)
			mousewheel_callback = other.mousewheel_callback
		if(other.mousedrag_callback)
			mousedrag_callback = other.mousedrag_callback
		if(other.mousedrop_callback)
			mousedrop_callback = other.mousedrop_callback
		if(other.mouseup_callback)
			mouseup_callback = other.mouseup_callback
		if(other.mousedown_callback)
			mousedown_callback = other.mousedown_callback
		if(other.mousemove_callback)
			mousemove_callback = other.mousemove_callback

/datum/component/click_intercept/Destroy()
	for(var/i in recievers)
		var/datum/component/click_reciever/R = i
		R.remove_intercept(src)
	recievers = null
	return ..()

/datum/component/click_intercept/proc/reciever_added(datum/component/click_reciever/reciever)
	recievers += reciever

/datum/component/click_intercept/proc/reciever_destroyed(datum/component/click_reciever/reciever)
	recievers -= reciever

/datum/component/click_intercept/proc/attach_to(datum/object)
	if(ismob(object))
		var/mob/M = object
		var/client/C = M.client
		if(!istype(C))
			return FALSE
		C.AddComponent(/datum/component/click_reciever, src)
		return TRUE
	if(isclient(object))
		var/client/C = object
		C.AddComponent(/datum/component/click_reciever, src)
		return TRUE
	return FALSE

/datum/component/click_intercept/proc/remove_from(datum/object)
	GET_COMPONENT_FROM(reciever, /datum/component/click_reciever, object)
	if(reciever)
		reciever.remove_intercept(src)
		return TRUE
	return FALSE
