/client
	var/atom/selected_target

/client/MouseDown(object, location, control, params)
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target = object
		while(selected_target)
			Click(selected_target, location, control, params)
			sleep(delay)

/client/MouseUp(object, location, control, params)
	selected_target = null

/client/MouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(selected_target)
		selected_target = over_object

/mob/proc/CanMobAutoclick(object, location, params)

/mob/living/CanMobAutoclick(object, location, params)
	var/obj/item/h = get_active_hand()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)

/obj/item/weapon/gun
	var/automatic = 0 //can gun use it, 0 is no, anything above 0 is the delay between clicks in ds

/obj/item/weapon/gun/CanItemAutoclick(object, location, params)
	. = automatic