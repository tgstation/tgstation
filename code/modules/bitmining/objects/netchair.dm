
/**
 * ### Net Chair
 * Provides a way for players to engage with the loaded virtual domains.
 */
/obj/structure/netchair
	name = "net chair"

	anchored = TRUE
	buckle_lying = 0 //you sit in a chair, not lay
	can_buckle = TRUE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	desc = "A link to the netverse. It has an assortment of cables to connect yourself to a virtual domain."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "echair0"
	integrity_failure = 0.1
	layer = OBJ_LAYER
	max_integrity = 250
	resistance_flags = NONE
	/// Weakref of the current avatar
	var/datum/weakref/avatar_ref
	/// The person sitting in this chair.
	var/datum/weakref/occupant_ref
	/// Mind weakref used to keep track of the avatar.
	var/datum/weakref/occupant_mind_ref
	/// The linked quantum server
	var/datum/weakref/server_ref
	/// The selected outfit for the gamer chair.
	var/datum/outfit/netsuit = /datum/outfit/job/miner
	/// Static list of outfits to select from
	var/static/list/cached_outfits

/obj/structure/netchair/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))
	RegisterSignal(src, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))

/obj/structure/netchair/Destroy()
	. = ..()
	cached_outfits.Cut()

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

	if(!length(cached_outfits))
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

/// If this goes smoothly, should reconnect a receiving mind to the occupant's body
/obj/structure/netchair/proc/disconnect_occupant(datum/mind/receiving, forced = FALSE)
	var/mob/living/occupant = occupant_ref?.resolve()
	var/datum/mind/hosted_mind = occupant_mind_ref?.resolve()
	if(isnull(occupant) || receiving != hosted_mind)
		return

	occupant.mind.key = null
	occupant.key = null
	receiving.transfer_to(occupant)

	var/datum/action/avatar_domain_info/action = locate(/datum/action/avatar_domain_info) in occupant.actions
	if(action)
		action.Remove()

	occupant.set_static_vision(2 SECONDS)
	occupant.set_temp_blindness(1 SECONDS)

	var/obj/machinery/quantum_server/server = find_server()
	if(server)
		SEND_SIGNAL(server, COMSIG_BITMINER_DISCONNECTED, occupant_mind_ref)
		receiving.UnregisterSignal(server, COMSIG_QSERVER_DISCONNECTED)
	occupant_mind_ref = null

	if(!forced || occupant.stat == DEAD)
		return

	occupant.flash_act(override_blindness_check = TRUE, visual = TRUE)
	occupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	INVOKE_ASYNC(occupant, TYPE_PROC_REF(/mob/living, emote), "scream")
	occupant.do_jitter_animation(200)
	to_chat(occupant, span_danger("You've been forcefully disconnected from your avatar! Your thoughts feel scrambled!"))

/// Creates a new z-level, an avatar, then transfers the mind to the avatar.
/obj/structure/netchair/proc/enter_matrix(mob/living/carbon/human/neo)
	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		balloon_alert(neo, "no server connected!")
		return

	var/datum/map_template/virtual_domain/generated_domain = server.generated_domain
	if(isnull(generated_domain))
		balloon_alert(neo, "no connection!")
		return

	var/mob/living/carbon/current_avatar = avatar_ref?.resolve()
	var/obj/structure/hololadder/wayout
	if(!current_avatar || current_avatar.stat != CONSCIOUS) // We need an avatar that exists and is living
		wayout = generate_hololadder()
		if(isnull(wayout))
			balloon_alert(neo, "out of bandwidth!")
			return
		current_avatar = generate_avatar(wayout, generated_domain)
		avatar_ref = WEAKREF(current_avatar)

	neo.set_static_vision(3 SECONDS)
	if(!do_after(neo, 2 SECONDS, src))
		return

	// Final sanity check before we start the transfer
	if(QDELETED(neo) || QDELETED(current_avatar) || isnull(neo.mind) || neo.stat == DEAD || current_avatar.stat == DEAD)
		return

	var/datum/weakref/neo_mind_ref = WEAKREF(neo.mind)
	occupant_mind_ref = neo_mind_ref
	SEND_SIGNAL(server, COMSIG_BITMINER_CONNECTED, neo_mind_ref)
	neo.mind.initial_avatar_connection(
		occupant = neo,
		avatar = current_avatar,
		hosting_chair = src,
		server = server,
		help_text = generated_domain.help_text
	)

/obj/structure/netchair/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	server = locate(/obj/machinery/quantum_server) in oview(4, src)
	if(server)
		server_ref = WEAKREF(server)
		server.RegisterSignal(src, COMSIG_BITMINER_CONNECTED, TYPE_PROC_REF(/obj/machinery/quantum_server, on_client_connect))
		server.RegisterSignal(src, COMSIG_BITMINER_DISCONNECTED, TYPE_PROC_REF(/obj/machinery/quantum_server, on_client_disconnect))
		return server

	return FALSE

/// Generates a new avatar for the bitminer.
/obj/structure/netchair/proc/generate_avatar(obj/structure/hololadder/wayout, datum/map_template/virtual_domain/generated_domain)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/datum/outfit/to_wear = generated_domain.forced_outfit || netsuit
	avatar.equipOutfit(to_wear, visualsOnly = TRUE)
	avatar.job = "Bit Avatar"

	return avatar

/// Generates a new hololadder for the bitminer. Effectively a respawn attempt.
/obj/structure/netchair/proc/generate_hololadder()
	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		return

	var/datum/space_level/vdom = server.vdom_ref?.resolve()
	if(isnull(vdom))
		return

	var/list/turf/possible_turfs = get_area_turfs(/area/station/virtual_domain/safehouse/exit, vdom.z_value)
	if(!length(possible_turfs))
		return

	var/turf/destination
	for(var/turf/dest_turf as anything in possible_turfs)
		if(!locate(/obj/structure/hololadder) in dest_turf)
			destination = dest_turf
			break
	if(isnull(destination))
		return

	var/obj/structure/hololadder/wayout = new(destination)
	if(isnull(wayout))
		return

	return wayout

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

	occupant_ref = WEAKREF(mob_to_buckle)
	INVOKE_ASYNC(src, PROC_REF(enter_matrix), mob_to_buckle)

/// On unbuckle, make sure the occupant ref is null
/obj/structure/netchair/proc/on_unbuckle(datum/source, mob/living/mob_to_unbuckle, force)
	SIGNAL_HANDLER

	occupant_ref = null

	var/datum/mind/hosted_mind = occupant_mind_ref?.resolve()
	if(hosted_mind)
		disconnect_occupant(hosted_mind, forced = TRUE)

/// Resolves a path to an outfit.
/obj/structure/netchair/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(ispath(path, /datum/outfit) && locate(path) in subtypesof(/datum/outfit))
		return path

	return FALSE
