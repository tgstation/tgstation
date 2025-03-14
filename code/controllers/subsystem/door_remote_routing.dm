SUBSYSTEM_DEF(door_remote_routing)
	name = "IDs and Access"
	init_order = INIT_ORDER_DOOR_REMOTES
	flags = SS_NO_FIRE

/datum/controller/subsystem/door_remote_routing/Initialize()
	setup_door_remote_radials()
	..()

/* When someone bops a door with the alternate action of their ID, they will request the door be opened by the door remote.
 * First, we deduce the appropriate region(s) for the access request.
 * If we find an appropriate region, then we add it to the list of regions we're gonna send a signal for.
 *
 * * ID_requesting - The ID card that is requesting the door be opened.
 * * door_requested - The door that the ID card is requesting be opened.
 */
/datum/controller/subsystem/door_remote_routing/proc/route_request_to_door_remote(obj/item/card/id/ID_requesting, obj/machinery/door/airlock/door_requested)
	// Signal that someone requested this door; if no door remotes are listening, ask the AI
	var/received = SEND_SIGNAL(src, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, ID_requesting, door_requested)
	if(!received)
		id_feedback_message(ID_requesting, "buzzes \"ROUTE REQUEST: FAILED\".")

/// Does a bunch of a hullabaloo to set up a door remote's radial menu images
/// Done this way so we can just have a set of images hanging around on GLOB
/// Instead of regenerating the images every time the menu gets opened
/datum/controller/subsystem/door_remote_routing/proc/setup_door_remote_radials()
	for(var/region_name in GLOB.door_remote_radial_images)
		var/image_set = GLOB.door_remote_radial_images[region_name]
		if(!islist(image_set)) // then it's our odd-one-out image for handling requests
			if(!isimage(image_set)) // then we have a problem
				CRASH("Wrong type when trying to configure door remote radials! [image_set] is not a list or image.")
			for(var/added_to in GLOB.door_remote_radial_images) // this will only run once
				var/list/list_to_append = GLOB.door_remote_radial_images[added_to]
				if(islist(list_to_append))
					list_to_append[WAND_HANDLE_REQUESTS] = GLOB.door_remote_radial_images[WAND_HANDLE_REQUESTS]
			return // we do it like this to minimize the creation of GLOB variables for holding our radial images
		var/image/bolt_radial = image_set[WAND_BOLT]
		var/image/EA_radial = image_set[WAND_EMERGENCY]
		var/image/shock_radial = image_set[WAND_SHOCK]
		bolt_radial.add_overlay(image(icon = 'icons/obj/doors/airlocks/station/overlays.dmi', icon_state = "lights_bolts"))
		EA_radial.add_overlay(image(icon = 'icons/obj/doors/airlocks/station/overlays.dmi', icon_state = "lights_emergency"))
		shock_radial.add_overlay(image(icon = 'icons/mob/huds/hud.dmi', icon_state = "electrified"))

// A proc to give feedback to the holder of an ID making a request, as well as any nosey busybodies nearby
/datum/controller/subsystem/door_remote_routing/proc/id_feedback_message(obj/item/card/id/advanced/ID_requesting, message)
	if(!istype(ID_requesting, /obj/item/card/id/advanced))
		CRASH("generate_ID_response called with non-ID card. How did we get here?")
	ID_requesting.audible_message(message, audible_message_flags = EMOTE_MESSAGE)
