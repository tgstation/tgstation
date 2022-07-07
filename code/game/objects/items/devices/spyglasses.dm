//detective spyglasses. meant to be an example for map_popups.dm
/obj/item/clothing/glasses/sunglasses/spy
	desc = "Made by Nerd. Co's infiltration and surveillance department. Upon closer inspection, there's a small screen in each lens."
	actions_types = list(/datum/action/item_action/activate_remote_view)
	var/obj/item/clothing/accessory/spy_bug/linked_bug

/obj/item/clothing/glasses/sunglasses/spy/proc/show_to_user(mob/user)//this is the meat of it. most of the map_popup usage is in this.
	if(!user)
		return
	if(!user.client)
		return
	if(!linked_bug)
		user.audible_message(span_warning("[src] lets off a shrill beep!"))
	if(user.client.screen_maps["spypopup_map"]) //alright, the popup this object uses is already IN use, so the window is open. no point in doing any other work here, so we're good.
		return
	user.client.setup_popup("spypopup", 3, 3, 2)
	user.client.register_map_obj(linked_bug.cam_screen)
	for(var/plane in linked_bug.cam_plane_masters)
		user.client.register_map_obj(plane)
	linked_bug.update_view()

/obj/item/clothing/glasses/sunglasses/spy/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_EYES)
		user.client.close_popup("spypopup")

/obj/item/clothing/glasses/sunglasses/spy/dropped(mob/user)
	. = ..()
	user.client.close_popup("spypopup")

/obj/item/clothing/glasses/sunglasses/spy/ui_action_click(mob/user)
	show_to_user(user)

/obj/item/clothing/glasses/sunglasses/spy/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/sunglasses/spy/Destroy()
	if(linked_bug)
		linked_bug.linked_glasses = null
	. = ..()

/datum/action/item_action/activate_remote_view
	name = "Activate Remote View"
	desc = "Activates the Remote View of your spy sunglasses."

/obj/item/clothing/accessory/spy_bug
	name = "pocket protector"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	desc = "An advanced piece of espionage equipment in the shape of a pocket protector. It has a built in 360 degree camera for all your \"admirable\" needs. Microphone not included."
	var/obj/item/clothing/glasses/sunglasses/spy/linked_glasses
	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	// Ranges higher than one can be used to see through walls.
	var/cam_range = 1
	var/datum/movement_detector/tracker

/obj/item/clothing/accessory/spy_bug/Initialize(mapload)
	. = ..()
	tracker = new /datum/movement_detector(src, CALLBACK(src, .proc/update_view))

	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = "spypopup_map"
	cam_screen.del_on_map_removal = FALSE
	cam_screen.set_position(1, 1)

	// We need to add planesmasters to the popup, otherwise
	// blending fucks up massively. Any planesmaster on the main screen does
	// NOT apply to map popups. If there's ever a way to make planesmasters
	// omnipresent, then this wouldn't be needed.
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/instance = new plane()
		if(instance.blend_mode_override)
			instance.blend_mode = instance.blend_mode_override
		instance.assigned_map = "spypopup_map"
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "spypopup_map:CENTER"
		cam_plane_masters += instance

/obj/item/clothing/accessory/spy_bug/Destroy()
	if(linked_glasses)
		linked_glasses.linked_bug = null
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(tracker)
	. = ..()

/obj/item/clothing/accessory/spy_bug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	cam_screen.vis_contents.Cut()
	for(var/turf/visible_turf in view(1,get_turf(src)))//fuck you usr
		cam_screen.vis_contents += visible_turf

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "spyglass kit"
	desc = "this box contains <i>cool</i> nerd glasses; with built-in displays to view a linked camera."

/obj/item/paper/fluff/nerddocs
	name = "Espionage For Dummies"
	color = "#FFFF00"
	desc = "An eye gougingly yellow pamphlet with a badly designed image of a detective on it. the subtext says \" The Latest way to violate privacy guidelines!\" "
	info = @{"

Thank you for your purchase of the Nerd Co SpySpeks <small>tm</small>, this paper will be your quick-start guide to violating the privacy of your crewmates in three easy steps!<br><br>Step One: Nerd Co SpySpeks <small>tm</small> upon your face. <br>
Step Two: Place the included "ProfitProtektor <small>tm</small>" camera assembly in a place of your choosing - make sure to make heavy use of it's inconspicous design!

Step Three: Press the "Activate Remote View" Button on the side of your SpySpeks <small>tm</small> to open a movable camera display in the corner of your vision, it's just that easy!<br><br><br><center><b>TROUBLESHOOTING</b><br></center>
My SpySpeks <small>tm</small> Make a shrill beep while attempting to use!

A shrill beep coming from your SpySpeks means that they can't connect to the included ProfitProtektor <small>tm</small>, please make sure your ProfitProtektor is still active, and functional!
	"}

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/obj/item/clothing/accessory/spy_bug/newbug = new(src)
	var/obj/item/clothing/glasses/sunglasses/spy/newglasses = new(src)
	newbug.linked_glasses = newglasses
	newglasses.linked_bug = newbug
	new /obj/item/paper/fluff/nerddocs(src)
