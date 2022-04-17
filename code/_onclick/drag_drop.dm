/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	receiving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return
	if(SEND_SIGNAL(src, COMSIG_MOUSEDROP_ONTO, over, usr) & COMPONENT_NO_MOUSEDROP) //Whatever is receiving will verify themselves for adjacency.
		return
	if(over == src)
		return usr.client.Click(src, src_location, src_control, params)
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows

	over.MouseDrop_T(src,usr, params)
	return

// receive a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user, params)
	SEND_SIGNAL(src, COMSIG_MOUSEDROPPED_ONTO, dropping, user, params)


/client/MouseDown(datum/object, location, control, params)
	if(QDELETED(object)) //Yep, you can click on qdeleted things before they have time to nullspace. Fun.
		return
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDOWN, object, location, control, params)
	if(mouse_down_icon)
		mouse_pointer_icon = mouse_down_icon
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			Click(selected_target[1], location, control, selected_target[2])
			sleep(delay)

/client/MouseUp(object, location, control, params)
	if(SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEUP, object, location, control, params) & COMPONENT_CLIENT_MOUSEUP_INTERCEPT)
		click_intercept_time = world.time
	if(mouse_up_icon)
		mouse_pointer_icon = mouse_up_icon
	selected_target[1] = null

/mob/proc/CanMobAutoclick(object, location, params)

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!object.IsAutoclickable())
		return
	var/obj/item/h = get_active_held_item()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)
	return

/atom/proc/IsAutoclickable()
	return TRUE

/atom/movable/screen/IsAutoclickable()
	return FALSE

/atom/movable/screen/click_catcher/IsAutoclickable()
	return TRUE

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	var/list/modifiers = params2list(params)
	if (LAZYACCESS(modifiers, MIDDLE_CLICK))
		if (src_object && src_location != over_location)
			middragtime = world.time
			middle_drag_atom_ref = WEAKREF(src_object)
		else
			middragtime = 0
			middle_drag_atom_ref = null
	mouseParams = params
	mouse_location_ref = WEAKREF(over_location)
	mouse_object_ref = WEAKREF(over_object)
	if(selected_target[1] && over_object?.IsAutoclickable())
		selected_target[1] = over_object
		selected_target[2] = params
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDRAG, src_object, over_object, src_location, over_location, src_control, over_control, params)
	return ..()

/client/MouseDrop(atom/src_object, atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
	if (IS_WEAKREF_OF(src_object, middle_drag_atom_ref))
		middragtime = 0
		middle_drag_atom_ref = null
	..()
