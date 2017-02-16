/client
	var/list/atom/selected_target[2]
	var/obj/item/active_mousedown_item = null

/client/MouseDown(object, location, control, params)
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			Click(selected_target[1], location, control, selected_target[2])
			sleep(delay)
	else
		active_mousedown_item = mob.canMobMousedown(object, location, params)
		if(active_mousedown_item)
			active_mousedown_item.onMouseDown(object, location, params)

/client/MouseUp(object, location, control, params)
	selected_target[1] = null
	if(active_mousedown_item)
		active_mousedown_item.onMouseUp(object, location, params)
		active_mousedown_item = null

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	if(selected_target[1] && over_object.IsAutoclickable())
		selected_target[1] = over_object
		selected_target[2] = params
	if(active_mousedown_item)
		active_mousedown_item.onMouseDrag(src_object, over_object, src_location, over_location, params)

/mob/proc/CanMobAutoclick(object, location, params)

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!object.IsAutoclickable())
		return
	var/obj/item/h = get_active_held_item()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/mob/proc/canMobMousedown(object, location, params)

/mob/living/carbon/canMobMousedown(atom/object, location, params)
	if(!object.IsAutoclickable())	//You shouldn't touch that.
		return
	var/obj/item/H = get_active_held_item()
	if(H)
		. = H.canItemMouseDown(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)

/obj/item/proc/canItemMouseDown(object, location, params)
	if(canMouseDown)
		return src

/obj/item/proc/onMouseDown(object, location, params)
	return

/obj/item/proc/onMouseUp(object, location, params)
	return

/obj/item/proc/onMouseDrag(src_object, over_object, src_location, over_location, params)
	return

/obj/item
	var/canMouseDown = FALSE

/obj/item/weapon/gun
	var/automatic = 0 //can gun use it, 0 is no, anything above 0 is the delay between clicks in ds

/obj/item/weapon/gun/CanItemAutoclick(object, location, params)
	. = automatic

/atom/proc/IsAutoclickable()
	. = 1

/obj/screen/IsAutoclickable()
	. = 0

/obj/screen/click_catcher/IsAutoclickable()
	. = 1