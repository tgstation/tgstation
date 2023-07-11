
/**
 * ## Net Chair
 * Provides a way for players to engage with the loaded virtual domains.
 */
/obj/structure/netchair
	name = "net chair"
	desc = "A link to the netverse. It has an assortment of cables to connect yourself to a virtual domain."

	anchored = TRUE
	buckle_lying = 0 //you sit in a chair, not lay
	can_buckle = TRUE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	icon = 'icons/obj/chairs.dmi'
	icon_state = "echair0"
	integrity_failure = 0.1
	layer = OBJ_LAYER
	max_integrity = 250
	resistance_flags = NONE
	/// The person sitting in this chair.
	var/datum/weakref/bitminer_ref
	/// The current avatar for the bitminer.
	var/datum/weakref/avatar_ref
	/// The selected outfit for the gamer chair.
	var/datum/outfit/netsuit = /datum/outfit/job/miner
	/// Static list of outfits to select from
	var/static/list/cached_outfits
	/// The linked quantum server
	var/obj/machinery/quantum_server/server

/obj/structure/netchair/Initialize(mapload)
	. = ..()
	if(!server)
		panic_find_server()

	RegisterSignal(src, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))

/obj/structure/netchair/Destroy()
	. = ..()
	QDEL_NULL(netsuit)
	cached_outfits.Cut()
	var/mob/living/carbon/human/avatar/avatar = bitminer_ref?.resolve()
	if(avatar)
		avatar.disconnect()

/obj/structure/netchair/attack_hand(mob/living/user, list/modifiers)
	if(ishuman(user) && !user.combat_mode)
		ui_interact(user)
	else
		return ..()

/obj/structure/netchair/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NetChair")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/netchair/ui_data()
	var/list/data = list()

	data["netsuit"] = netsuit
	return data

/obj/structure/netchair/ui_static_data()
	var/list/data = list()

	if(!cached_outfits)
		cached_outfits += make_outfit_collection("Jobs", subtypesof(/datum/outfit/job))

	data["collections"] = cached_outfits

	return data

/obj/structure/netchair/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("select_outfit")
			var/datum/outfit/new_suit = resolve_outfit(params["outfit"])
			if(new_suit)
				netsuit = new_suit
				return TRUE

	return FALSE

/// Creates a new z-level, an avatar, then transfers the mind to the avatar.
/obj/structure/netchair/proc/enter_matrix(mob/living/carbon/human/neo)
	set waitfor = FALSE

	if(!server)
		return

	var/mob/living/carbon/human/avatar/current_avatar = avatar_ref?.resolve()
	if(!current_avatar)
		current_avatar = generate_avatar(neo)

	if(!current_avatar)
		balloon_alert(neo, "out of bandwidth!")
		return

	// Final check before we start the transfer
	if(QDELETED(neo) || QDELETED(current_avatar) || neo.stat == DEAD || current_avatar.stat == DEAD)
		return

	var/datum/weakref/neo_ref = WEAKREF(neo)
	bitminer_ref = neo_ref
	server.occupant_refs += neo_ref
	avatar_ref = WEAKREF(current_avatar)
	current_avatar.pilot = neo

	neo.mind.transfer_to(current_avatar, TRUE)
	playsound(current_avatar, 'sound/magic/repulse.ogg', 30, 2)

/// Generates a new avatar for the bitminer.
/obj/structure/netchair/proc/generate_avatar(mob/living/carbon/human/neo)
	var/list/turf/possible_turfs = get_area_turfs(/area/station/virtual_domain/safehouse/exit, server.vdom.z_value)
	if(!length(possible_turfs))
		return FALSE

	// Find an empty spot to spawn the ladder
	var/turf/destination
	for(var/turf/dest_turf as anything in possible_turfs)
		if(!locate(/obj/structure/hololadder) in dest_turf)
			destination = dest_turf
			break
	if(!destination)
		return FALSE

	var/obj/structure/hololadder/wayout = new(destination, src)
	var/mob/living/carbon/human/avatar/avatar = new(wayout.loc, neo)
	avatar.equipOutfit(netsuit, visualsOnly = TRUE)
	return avatar

/// Creates a list of outfit entries for the UI.
/obj/structure/netchair/proc/make_outfit_collection(identifier, list/outfit_list)
	var/list/collection = list(
		"name" = identifier,
		"outfits" = list()
	)

	for(var/path as anything in outfit_list)
		var/datum/outfit/outfit = path
		collection["outfits"] += list(list("path" = path, "name" = initial(outfit.name)))

	return list(collection)

/// On buckled, checks if mob is alive and human, then enters the matrix.
/obj/structure/netchair/proc/on_buckle(datum/source, mob/living/mob_to_buckle, _force)
	SIGNAL_HANDLER

	if(!istype(mob_to_buckle) || !ishuman(mob_to_buckle) || mob_to_buckle.stat == DEAD)
		return FALSE

	enter_matrix(mob_to_buckle)

/// Finds a quantum server to link to.
/obj/structure/netchair/proc/panic_find_server()
	for(var/obj/machinery/quantum_server/server as anything in oview(7))
		if(istype(server, /obj/machinery/quantum_server))
			src.server = server
			return TRUE

	return FALSE

/// Resolves a path to an outfit.
/obj/structure/netchair/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(ispath(path, /datum/outfit))
		return path

	return FALSE
