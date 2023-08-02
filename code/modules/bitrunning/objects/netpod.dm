/obj/machinery/netpod
	name = "net pod"

	base_icon_state = "netpod"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	desc = "A link to the netverse. It has an assortment of cables to connect yourself to a virtual domain."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "netpod"
	max_integrity = 300
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
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(src, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_take_damage))

	register_context()
	update_appearance()

/obj/machinery/netpod/Destroy()
	. = ..()
	cached_actions.Cut()
	cached_outfits.Cut()

/obj/machinery/netpod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Open Machine"
		context[SCREENTIP_CONTEXT_RMB] = "Select Outfit"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/crowbar) && occupant)
		context[SCREENTIP_CONTEXT_LMB] = "Pry Open"
		return CONTEXTUAL_SCREENTIP_SET

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/netpod/update_icon_state()
	if(machine_stat & (BROKEN | NOPOWER))
		icon_state = base_icon_state
		return ..()

	if(state_open)
		icon_state = base_icon_state + "_open_active"
		return ..()

	icon_state = base_icon_state + "_closed"
	if(occupant)
		icon_state += "_active"

	return ..()

/obj/machinery/netpod/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
		return
	close_machine(target)

/obj/machinery/netpod/attack_hand(mob/living/user, list/modifiers)
	if(user.combat_mode)
		return ..()

	if(occupant && user != occupant)
		balloon_alert(user, "it's sealed shut!")
		return TRUE

	if(!state_open)
		open_machine()
		return TRUE

	if(get_turf(user) == get_turf(src))
		close_machine(user)
		return TRUE

	// Had the issue where calling close_machine() would pull you inside
	state_open = FALSE
	playsound(src, 'sound/machines/tramclose.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	set_density(TRUE)

	update_appearance()
	return TRUE

/obj/machinery/netpod/attack_hand_secondary(mob/user, list/modifiers)
	var/mob/living/carbon/human/player = user
	if(!ishuman(player) || player.combat_mode)
		return ..()

	if(occupant)
		balloon_alert(player, "in use!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	ui_interact(player)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/netpod/container_resist_act(mob/living/user)
	user.visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"),
		span_notice("With a hiss, you hear a machine opening."))
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
		playsound(src, 'sound/machines/tramopen.ogg', 60, TRUE, frequency = 65000)
		flick("[base_icon_state]_opening", src)
	return ..()

/obj/machinery/netpod/close_machine(mob/user, density_to_set = TRUE)
	if(isnull(user) || !state_open || panel_open)
		return
	playsound(src, 'sound/machines/tramclose.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	..()
	protect_occupant(occupant)
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
		pryer.visible_message(span_notice("[pryer] pries open [src]."), span_notice("You pry open [src]."), span_notice("You hear a machine being disassembled."))
		return ..()

	if(state_open || isnull(occupant))
		return ..()

	pryer.visible_message(span_danger("[pryer] starts prying open [src]!"), span_notice("You start to pry open [src]."))
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_CROWBAR_ALERT, pryer)

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
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", "[base_icon_state]_closed", screwdriver))
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

	mob_occupant.actions = cached_actions
	cached_actions.Cut()

	mob_occupant.playsound_local(src, "sound/magic/blink.ogg", 25, TRUE)
	mob_occupant.set_static_vision(2 SECONDS)
	mob_occupant.set_temp_blindness(1 SECONDS)

	var/obj/machinery/quantum_server/server = find_server()
	if(server)
		SEND_SIGNAL(server, COMSIG_BITRUNNER_CLIENT_DISCONNECTED, occupant_mind_ref)
		receiving.UnregisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE)
		receiving.UnregisterSignal(server, COMSIG_BITRUNNER_SEVER_AVATAR)
		receiving.UnregisterSignal(server, COMSIG_BITRUNNER_SHUTDOWN_ALERT)
	receiving.UnregisterSignal(src, COMSIG_BITRUNNER_CROWBAR_ALERT)
	receiving.UnregisterSignal(src, COMSIG_BITRUNNER_NETPOD_INTEGRITY)
	receiving.UnregisterSignal(src, COMSIG_BITRUNNER_SEVER_AVATAR)
	occupant_mind_ref = null

	if(mob_occupant.stat >= HARD_CRIT)
		open_machine()
		return

	if(!forced)
		return

	mob_occupant.Paralyze(2 SECONDS)
	mob_occupant.flash_act(override_blindness_check = TRUE, visual = TRUE)
	mob_occupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	INVOKE_ASYNC(mob_occupant, TYPE_PROC_REF(/mob/living, emote), "scream")
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
		wayout = server.generate_hololadder()
		if(isnull(wayout))
			balloon_alert(neo, "out of bandwidth!")
			return
		current_avatar = server.generate_avatar(wayout, netsuit)
		avatar_ref = WEAKREF(current_avatar)

	neo.set_static_vision(3 SECONDS)
	if(!do_after(neo, 2 SECONDS, src))
		return

	// Very invalid
	if(QDELETED(neo) || QDELETED(current_avatar) || QDELETED(src))
		return

	// Invalid
	if(occupant != neo || isnull(neo.mind) || neo.stat == DEAD || current_avatar.stat == DEAD)
		return

	var/datum/weakref/neo_mind_ref = WEAKREF(neo.mind)
	occupant_mind_ref = neo_mind_ref
	cached_actions += neo.actions
	SEND_SIGNAL(server, COMSIG_BITRUNNER_CLIENT_CONNECTED, neo_mind_ref)
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

/obj/machinery/netpod/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(isnull(occupant))
		examine_text += span_infoplain("It is currently unoccupied.")
		return

	examine_text += span_infoplain("It is currently occupied by [occupant].")

/// On unbuckle or break, make sure the occupant ref is null
/obj/machinery/netpod/proc/on_opened_or_destroyed(datum/source)
	SIGNAL_HANDLER

	if(isnull(occupant))
		return

	unprotect_occupant(occupant)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR, src)

/// Checks the integrity, alerts occupants
/obj/machinery/netpod/proc/on_take_damage(datum/source, damage_amount)
	SIGNAL_HANDLER

	if(isnull(occupant))
		return

	var/total = max_integrity - damage_amount
	var/integrity = (atom_integrity / total) * 100
	if(integrity > 50)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_INTEGRITY)

/// Sets the owner to in_netpod state, basically short-circuiting environmental conditions
/obj/machinery/netpod/proc/protect_occupant(mob/living/target)
	if(target != occupant)
		return

	target.apply_status_effect(/datum/status_effect/grouped/embryonic, STASIS_NETPOD_EFFECT)
	target.extinguish_mob()
	update_use_power(ACTIVE_POWER_USE)

/// Removes the in_netpod state
/obj/machinery/netpod/proc/unprotect_occupant(mob/living/target)
	target.remove_status_effect(/datum/status_effect/grouped/embryonic, STASIS_NETPOD_EFFECT)
	update_use_power(IDLE_POWER_USE)

/// Resolves a path to an outfit.
/obj/machinery/netpod/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(ispath(path, /datum/outfit) && locate(path) in subtypesof(/datum/outfit))
		return path
