//antag spyglasses. meant to be an example for map_popups.dm
/obj/item/clothing/glasses/regular/spy
	desc = "Made by Nerd. Co's infiltration and surveillance department. Upon closer inspection, there's a small screen in each lens."
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
	var/list/buglist = list(linked_bug.cam_view,linked_bug.popupmaster)
	user.client.add_objs_to_map(buglist)
	linked_bug.update_view()

/obj/item/clothing/glasses/regular/spy/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_GLASSES)
		user.client.close_popup("spypopup")

/obj/item/clothing/glasses/regular/spy/dropped(mob/user)
	. = ..()
	user.client.close_popup("spypopup")

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
	var/obj/screen/plane_master/lighting/popupmaster 
	var/cam_range = 1//ranges higher than one can be used to see through walls.

	var/datum/movement_detector/tracker

/obj/item/spy_bug/Initialize()
	. = ..()
	tracker = new /datum/movement_detector(src, CALLBACK(src, .proc/update_view))
	
	cam_view = new
	cam_view.name = "screen"
	cam_view.del_on_map_removal = FALSE
	cam_view.assigned_map = "spypopup_map"
	cam_view.screen_info = list(1,1)

	popupmaster = new
	popupmaster.screen_loc = "spypopup_map:CENTER"//note that we don't use screen_info here, due to it being a non-standard placement.
	popupmaster.assigned_map = "spypopup_map"
	popupmaster.del_on_map_removal = FALSE //not stored on the client, but instead on the bug. there's no need to 
	//we need to add a lighting planesmaster to the popup, otherwise blending fucks up massively. Any planesmaster on the main screen does NOT apply to map popups.
	//if there's ever a way to make planesmasters omnipresent, then this wouldn't be needed.

/obj/item/spy_bug/Destroy()
	. = ..()
	qdel(tracker)

/obj/item/spy_bug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	cam_view.vis_contents.Cut()
	for(var/turf/visible_turf in view(1,get_turf(src)))//fuck you usr
		cam_view.vis_contents += visible_turf

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "spyglass kit"
	desc = "this box contains <b>cool</b> nerd glasses; with built-in displays to view a linked camera."

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/obj/item/spy_bug/newbug = new(src)
	var/obj/item/clothing/glasses/regular/spy/newglasses = new(src)
	newbug.linked_glasses = newglasses
	newglasses.linked_bug = newbug
