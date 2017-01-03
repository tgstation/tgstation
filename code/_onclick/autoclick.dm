/client
	var/list/atom/selected_target[2]

/client/MouseDown(object, location, control, params)
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			Click(selected_target[1], location, control, selected_target[2])
			sleep(delay)

/client/MouseUp(object, location, control, params)
	selected_target[1] = null

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	if(selected_target[1] && over_object.IsAutoclickable())
		selected_target[1] = over_object
		selected_target[2] = params

/mob/proc/CanMobAutoclick(object, location, params)

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!object.IsAutoclickable())
		return
	var/obj/item/h = get_active_held_item()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)

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