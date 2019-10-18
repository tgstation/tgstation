//antag spyglasses. meant to be an example for map_popups.dm
/obj/item/clothing/glasses/regular/spy
	desc = "Made by Nerd. Co's infiltration and surveillance departmentt. Upon closer inspection, there's a small screen put into the lenses."
	var/obj/item/spy_bug/linked_bug

/obj/item/clothing/glasses/regular/spy/proc/show_to_user(var/mob/user)//this is the meat of it. most of the map_popup usage is in this.
	if(!user)
		return
	if(!user.client)
		return	
	if(!linked_bug)
		user.audible_message("<span class='warning'>[src] lets off a shrill beep!</span>")

	if("spypopup_map" in user.client.screen_maps) //alright, the popup this object uses is already IN use, so the window is open. no point in doing any other work here, so we're good. 
		return 
	user.client.setup_popup("spypopup",3,3,2)
	var/list/buglist = list(linked_bug.cam_view)
	user.client.add_objs_to_map(buglist)
	linked_bug.update_view()

/obj/item/clothing/glasses/regular/spy/dropped(mob/user)
	. = ..()
	user.client.close_popup("spypopup_map")

/obj/item/clothing/glasses/regular/spy/verb/activate_remote_view()
	//yada yada check to see if the glasses are in their eye slot
	show_to_user(usr)

/obj/item/spy_bug
	name = "pocket protector"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	desc = "an advanced holographic projection in the shape of a pocket protector featuring technology similar to a chameleon projector. it has a built in 360 degree camera for all your nefarious needs. Simply hitting an object with it will cause it's projection to change. Microphone not included."
	var/obj/item/clothing/glasses/regular/spy/linked_glasses
	var/obj/screen/cam_view
	var/cam_range = 1//ranges higher than one can be used to see through walls.
	var/list/disallowed_clone_types = list(/obj/mecha) 




/obj/item/spy_bug/proc/clone_object(var/obj/to_clone)
	for(var/type in disallowed_clone_types)
		if(istype(to_clone,type))
			audible_message("<span class='warning'>[src] lets off a shrill beep!</span>")
			return
	icon = to_clone.icon
	icon_state = to_clone.icon_state
	name = to_clone.name
	desc = to_clone.desc


/obj/item/spy_bug/proc/reset_to_init()
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	desc = initial(desc)

/obj/item/spy_bug/New(loc, ...)
	. = ..()
	cam_view = new
	cam_view.name = "screen"
	cam_view.del_on_map_removal = FALSE
	cam_view.assigned_map = "spypopup_map"
	cam_view.screen_info = list(1,1)

/obj/item/spy_bug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	cam_view.vis_contents.Cut()
	for(var/turf/visible_turf in range(1))
		cam_view.vis_contents += visible_turf

/obj/item/spy_bug/Moved()
	. = ..()
	update_view()

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/obj/item/spy_bug/newbug = new(src)
	var/obj/item/clothing/glasses/regular/spy/newglasses = new(src)

	newbug.linked_glasses = newglasses
	newglasses.linked_bug = newbug

