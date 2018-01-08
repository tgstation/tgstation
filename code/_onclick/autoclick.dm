/client
	var/list/atom/selected_target[2]
	var/obj/item/active_mousedown_item = null
	var/mouseParams = ""
	var/mouseLocation = null
	var/mouseObject = null
	var/mouseControlObject = null

/client/MouseDown(object, location, control, params)
	if(SendSignal(COMSIG_CLIENT_MOUSEDOWN, object, location, control, params))
		return
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			Click(selected_target[1], location, control, selected_target[2])
			sleep(delay)
	active_mousedown_item = mob.canMobMousedown(object, location, params)
	if(active_mousedown_item)
		active_mousedown_item.onMouseDown(object, location, params, mob)

/client/MouseUp(object, location, control, params)
	selected_target[1] = null
	if(active_mousedown_item)
		active_mousedown_item.onMouseUp(object, location, params, mob)
		active_mousedown_item = null
	SendSignal(COMSIG_CLIENT_MOUSEDOWN, object, location, control, params)		//Placement below above block is intentional. We can not have mousedown items held when we're mouse upped.

/mob
	var/autoclick_override		//badmin memes

/mob/proc/CanMobAutoclick(object, location, params)
	if(!isnull(autoclick_override))
		return autoclick_override

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!isnull(autoclick_override))
		return autoclick_override
	if(!object.IsAutoclickable())
		return
	var/obj/item/h = get_active_held_item()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/mob/proc/canMobMousedown(object, location, params)
	if(!isnull(autoclick_override))
		return autoclick_override

/mob/living/carbon/canMobMousedown(atom/object, location, params)
	if(!isnull(autoclick_override))
		return autoclick_override
	var/obj/item/H = get_active_held_item()
	if(H)
		. = H.canItemMouseDown(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)

/obj/item/proc/canItemMouseDown(object, location, params)
	if(canMouseDown)
		return src

/obj/item/proc/onMouseDown(object, location, params, mob)
	return

/obj/item/proc/onMouseUp(object, location, params, mob)
	return

/obj/item/proc/InterceptMouseDrag(src_object, over_location, srC_location, over_location, params, mob)
	return

/obj/item
	var/canMouseDown = FALSE

/obj/item/gun
	var/automatic = 0 //can gun use it, 0 is no, anything above 0 is the delay between clicks in ds

/obj/item/gun/CanItemAutoclick(object, location, params)
	. = automatic

/atom/proc/IsAutoclickable()
	. = 1

/obj/screen/IsAutoclickable()
	. = 0

/obj/screen/click_catcher/IsAutoclickable()
	. = 1

//Please don't roast me too hard
/client/MouseMove(object,location,control,params)
	mouseParams = params
	mouseLocation = location
	mouseObject = object
	mouseControlObject = control
	SendSignal(COMSIG_CLIENT_MOUSEMOVE, object, location, control, params)

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	mouseParams = params
	mouseLocation = over_location
	mouseObject = over_object
	mouseControlObject = over_control
	if(SendSignal(COMSIG_CLIENT_MOUSEDRAG, src_object, over_object, src_location, over_location, src_control, over_control, params))
		return
	if(selected_target[1] && over_object && over_object.IsAutoclickable())
		selected_target[1] = over_object
		selected_target[2] = params
	if(active_mousedown_item)
		active_mousedown_item.InterceptMouseDrag(src_object, over_object, src_location, over_location, params, mob)
