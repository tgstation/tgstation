SUBSYSTEM_DEF(door_remotes)
	name = "IDs and Access"
	init_order = INIT_ORDER_DOOR_REMOTES
	flags = SS_NO_FIRE
	var/remotes_listening_by_region = list(
		REGION_ALL_STATION = null,
		REGION_SECURITY = null,
		REGION_MEDBAY = null,
		REGION_RESEARCH = null,
		REGION_ENGINEERING = null,
		REGION_SUPPLY = null,
		REGION_COMMAND = null,
		REGION_GENERAL = null,
	)
/datum/controller/subsystem/door_remotes/Initialize()

	setup_remote_request_action_lists()
	setup_door_remote_radials()

/datum/controller/subsystem/door_remotes/proc/setup_remote_request_action_lists()

/datum/controller/subsystem/door_remotes/proc/add_listening_remote(region_listened_to, obj/item/door_remote/remote_added)
	LAZYADD(remotes_listening_by_region[region_listened_to], remote_added)

/datum/controller/subsystem/door_remotes/proc/remove_listening_remote(region_listened_to, obj/item/door_remote/remote_removed)
	LAZYREMOVE(remotes_listening_by_region[region_listened_to], remote_removed)
	if(LAZYLEN(remotes_listening_by_region[region_listened_to]))
		return // return if there's other remotes listening for that region
	LAZYNULL(remotes_listening_by_region[region_listened_to]) // otherwise null it out

/* When someone bops a door with the alternate action of their ID, they will request the door be opened by the door remote.
 * First, we deduce the appropriate region(s) for the access request.
 * If we find an appropriate region, then we add it to the list of regions we're gonna send a signal for.
 *
 * * ID_requesting - The ID card that is requesting the door be opened.
 * * door_requested - The door that the ID card is requesting be opened.
 */
/datum/controller/subsystem/door_remotes/proc/route_request_to_door_remote(obj/item/card/id/ID_requesting, obj/machinery/door/airlock/door_requested)
	. = FALSE
	for(var/region in SSid_access.station_regions)
		if(door_requested.check_access_list(SSid_access.accesses_by_region[region]))
			for(var/obj/item/door_remote/remote in SSdoor_remotes.remotes_listening_by_region[region])
				. = SEND_SIGNAL(remote, COMSIG_DOOR_REMOTE_ACCESS_REQUEST, ID_requesting, door_requested)
	if(!.)
		ID_requesting.visible_message("A scroll of text rolls across the front of [ID_requesting]: ACCESS REQUEST ROUTING FAILED, CONSULT ARTIFICIAL INTELLIGENCE FOR ASSISTANCE.", vision_distance = 1)

/*/datum/controller/subsystem/id_access/proc/handle_request_response(response_from_remote, obj/machinery/door/airlock/door_requested, emagged_remote = FALSE)
	if(!istext(response_from_remote))
		CRASH("handle_request_response called with non-text response. How did we get here?")
	if(!istype(door_requested, /obj/machinery/door/airlock))
		CRASH("handle_request_response for airlock tried to handle something that wasn't an airlock.")
	// we don't need to do any more checking on airlock condition at this point; there have been two
	// rounds of validation and any further procs have their own checks
	switch (response_from_remote)
		if("Approve")
			if(door_requested.locked)
				door_requested.unbolt()
			door_requested.open()
			return TRUE
		if("Deny")
			return FALSE
		if("Bolt")
			door_requested.secure_close(force_crush = emagged_remote)
			return FALSE
		if("Block")
			return FALSE
		if("Emergency Access")

		if("Clear")

		if("Escalate")

		if("SHOCK")
PSEUDO_M*/

/datum/controller/subsystem/door_remotes/proc/setup_door_remote_radials()
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
