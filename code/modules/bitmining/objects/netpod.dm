
/**
 * ### Net Pod
 * Provides a way for players to engage with the loaded virtual domains.
 */
/obj/machinery/netpod
	name = "net pod"

	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	desc = "A link to the netverse. It has an assortment of cables to connect yourself to a virtual domain."
	icon = 'icons/obj/machines/sleeper.dmi'
	base_icon_state = "oldpod"
	icon_state = "oldpod"
	obj_flags = BLOCKS_CONSTRUCTION
	state_open = TRUE
	/// Holds this to see if it needs to generate a new one
	var/datum/weakref/avatar_ref
	/// Mind weakref used to keep track of the original mind
	var/datum/weakref/occupant_mind_ref
	/// The linked quantum server
	var/datum/weakref/server_ref
	/// A player selected outfit by clicking the netpod
	var/datum/outfit/netsuit = /datum/outfit/job/miner
	/// Static list of outfits to select from
	var/list/cached_outfits = list()
	/// Cached mob actions, stops mobs from keeping abilities
	var/list/datum/action/cached_actions = list()

/obj/machinery/netpod/Initialize(mapload)
	. = ..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/netpod/LateInitialize()
	. = ..()

	RegisterSignals(src, list(
		COMSIG_QDELETING,
		COMSIG_MACHINERY_BROKEN,
		COMSIG_MACHINERY_POWER_LOST,
		),
		PROC_REF(on_opened_or_destroyed),
	)
	register_context()
	update_appearance()

/obj/machinery/netpod/Destroy()
	. = ..()
	cached_actions.Cut()
	cached_outfits.Cut()

/obj/machinery/netpod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select Outfit"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/netpod/update_icon_state()
	icon_state = "[base_icon_state][state_open ? "-open" : null]"
	return ..()

/obj/machinery/netpod/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
		return
	close_machine(target)

/obj/machinery/netpod/attack_hand(mob/user, list/modifiers)
	var/mob/living/carbon/human/player = user
	if(!ishuman(player) || player.combat_mode)
		return ..()

	ui_interact(player)
	return TRUE

/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/netpod/container_resist_act(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/netpod/relaymove(mob/living/user, direction)
	if(!state_open)
		container_resist_act(user)

/obj/machinery/netpod/open_machine(drop = TRUE, density_to_set = FALSE)
	if(!state_open && !panel_open)
		on_opened_or_destroyed()
		flick("[initial(icon_state)]-anim", src)
	return ..()

/obj/machinery/netpod/close_machine(mob/user, density_to_set = TRUE)
	if(isnull(user) || !state_open || panel_open)
		return
	flick("[initial(icon_state)]-anim", src)
	..()
	enter_matrix()

/obj/machinery/netpod/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(default_pry_open(crowbar, user))
		return TRUE
	if(default_deconstruction_crowbar(crowbar))
		return TRUE
	return FALSE

/obj/machinery/netpod/default_pry_open(obj/item/crowbar, mob/living/pryer)
	if(panel_open && isnull(occupant) && !(flags_1 & NODECONSTRUCT_1) && crowbar.tool_behaviour == TOOL_CROWBAR)
		crowbar.play_tool_sound(src, 50)
		visible_message(span_danger("[pryer] pries open [src]!"), span_notice("You pry open [src]."))
		return ..()

	if(state_open || isnull(occupant))
		return ..()


	visible_message(span_danger("[pryer] starts prying open [src]!"), span_notice("You start to pry open [src]."))
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	SEND_SIGNAL(src, COMSIG_BITMINING_CROWBAR_ALERT, pryer)

	if(do_after(pryer, 15 SECONDS, src))
		open_machine()
		return ..()

/obj/machinery/netpod/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ..()
	if(occupant)
		balloon_alert(user, "occupied.")
		return TRUE
	if(state_open)
		balloon_alert(user, "close first.")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), screwdriver))
		return TRUE
	return FALSE

/obj/machinery/netpod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NetpodOutfits")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/netpod/ui_data()
	var/list/data = list()

	data["netsuit"] = netsuit
	return data

/obj/machinery/netpod/ui_static_data()
	var/list/data = list()

	if(!length(cached_outfits))
		cached_outfits += make_outfit_collection("Jobs", subtypesof(/datum/outfit/job))

	data["collections"] = cached_outfits

	return data

/obj/machinery/netpod/ui_act(action, params)
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

/**
 * ### Disconnect occupant
 * If this goes smoothly, should reconnect a receiving mind to the occupant's body
 *
 * This is the second stage of the process -  if you want to disconn avatars start at the mind first
 */
/obj/machinery/netpod/proc/disconnect_occupant(datum/mind/receiving, forced = FALSE)
	var/mob/living/mob_occupant = occupant
	var/datum/mind/hosted_mind = occupant_mind_ref?.resolve()
	if(!isliving(occupant) || receiving != hosted_mind)
		return

	mob_occupant.mind.key = null
	mob_occupant.key = null
	receiving.transfer_to(mob_occupant)
	occupant_mind_ref = null

	mob_occupant.actions = cached_actions
	cached_actions.Cut()

	mob_occupant.playsound_local(src, "sound/magic/blink.ogg", 25, TRUE)
	mob_occupant.set_static_vision(2 SECONDS)
	mob_occupant.set_temp_blindness(1 SECONDS)

	var/obj/machinery/quantum_server/server = find_server()
	if(server)
		SEND_SIGNAL(server, COMSIG_BITMINING_CLIENT_DISCONNECTED, occupant_mind_ref)
		receiving.UnregisterSignal(server, COMSIG_BITMINING_SERVER_CRASH)
		receiving.UnregisterSignal(server, COMSIG_BITMINING_SHUTDOWN_ALERT)
	receiving.UnregisterSignal(src, COMSIG_BITMINING_CROWBAR_ALERT)
	receiving.UnregisterSignal(src, COMSIG_BITMINING_SEVER_AVATAR)

	if(!forced || mob_occupant.stat == DEAD)
		return

	mob_occupant.Paralyze(2 SECONDS)
	mob_occupant.flash_act(override_blindness_check = TRUE, visual = TRUE)
	mob_occupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	INVOKE_ASYNC(mob_occupant, TYPE_PROC_REF(/mob/living, emote), "scream")
	mob_occupant.do_jitter_animation(200)
	to_chat(mob_occupant, span_danger("You've been forcefully disconnected from your avatar! Your thoughts feel scrambled!"))

/**
 * ### Enter Matrix
 * Finds any current avatars from this chair - or generates a new one
 *
 * New avatars cost 1 attempt, and this will eject if there's none left
 *
 * Connects the mind to the avatar if everything is ok
 */
/obj/machinery/netpod/proc/enter_matrix()
	var/mob/living/carbon/human/neo = occupant
	if(!ishuman(neo) || neo.stat == DEAD || isnull(neo.mind))
		balloon_alert(neo, "invalid occupant.")
		return

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
	if(isnull(current_avatar) || current_avatar.stat != CONSCIOUS) // We need a viable avatar
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
	cached_actions = neo.actions
	SEND_SIGNAL(server, COMSIG_BITMINING_CLIENT_CONNECTED, neo_mind_ref)
	neo.mind.initial_avatar_connection(
		avatar = current_avatar,
		hosting_netpod = src,
		server = server,
		help_text = generated_domain.help_text
	)

/// Finds a server and sets the server_ref
/obj/machinery/netpod/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	server = locate(/obj/machinery/quantum_server) in oview(4, src)
	if(server)
		server_ref = WEAKREF(server)
		return server

	return

/// Generates a new avatar for the bitminer.
/obj/machinery/netpod/proc/generate_avatar(obj/structure/hololadder/wayout, datum/map_template/virtual_domain/generated_domain)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/datum/outfit/to_wear = generated_domain.forced_outfit || netsuit
	avatar.equipOutfit(to_wear)

	var/obj/item/card/id/outfit_id = avatar.wear_id
	if(outfit_id)
		outfit_id.assignment = "Bit Avatar"
		outfit_id.registered_name = avatar.real_name
		SSid_access.apply_trim_to_card(outfit_id, /datum/id_trim/bit_avatar)

	return avatar

/// Generates a new hololadder for the bitminer. Effectively a respawn attempt.
/obj/machinery/netpod/proc/generate_hololadder()
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
/obj/machinery/netpod/proc/make_outfit_collection(identifier, list/outfit_list)
	var/list/collection = list(
		"name" = identifier,
		"outfits" = list()
	)

	for(var/path as anything in outfit_list)
		var/datum/outfit/outfit = path
		collection["outfits"] += list(list("path" = path, "name" = initial(outfit.name)))

	return list(collection)

/// On unbuckle or break, make sure the occupant ref is null
/obj/machinery/netpod/proc/on_opened_or_destroyed()
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_BITMINING_SEVER_AVATAR, TRUE, src)

/// Resolves a path to an outfit.
/obj/machinery/netpod/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(ispath(path, /datum/outfit) && locate(path) in subtypesof(/datum/outfit))
		return path

	return
