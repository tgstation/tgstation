#define BASE_DISCONNECT_DAMAGE 40

/obj/machinery/netpod
	name = "netpod"

	base_icon_state = "netpod"
	circuit = /obj/item/circuitboard/machine/netpod
	desc = "A link to the netverse. It has an assortment of cables to connect yourself to a virtual domain."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "netpod"
	max_integrity = 300
	obj_flags = BLOCKS_CONSTRUCTION
	state_open = TRUE
	/// Whether we have an ongoing connection
	var/connected = FALSE
	/// A player selected outfit by clicking the netpod
	var/datum/outfit/netsuit = /datum/outfit/job/bitrunner
	/// Holds this to see if it needs to generate a new one
	var/datum/weakref/avatar_ref
	/// The linked quantum server
	var/datum/weakref/server_ref
	/// The amount of brain damage done from force disconnects
	var/disconnect_damage
	/// Static list of outfits to select from
	var/list/cached_outfits = list()

/obj/machinery/netpod/Initialize(mapload)
	. = ..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/netpod/LateInitialize()
	. = ..()

	disconnect_damage = BASE_DISCONNECT_DAMAGE
	find_server()

	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(src, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(src, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_loss))
	RegisterSignals(src, list(COMSIG_QDELETING,	COMSIG_MACHINERY_BROKEN),PROC_REF(on_broken))

	register_context()
	update_appearance()

/obj/machinery/netpod/Destroy()
	. = ..()
	cached_outfits.Cut()

/obj/machinery/netpod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select Outfit"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/crowbar) && occupant)
		context[SCREENTIP_CONTEXT_LMB] = "Pry Open"
		return CONTEXTUAL_SCREENTIP_SET

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/netpod/update_icon_state()
	if(!is_operational)
		icon_state = base_icon_state
		return ..()

	if(state_open)
		icon_state = base_icon_state + "_open_active"
		return ..()

	if(panel_open)
		icon_state = base_icon_state + "_panel"
		return ..()

	icon_state = base_icon_state + "_closed"
	if(occupant)
		icon_state += "_active"

	return ..()

/obj/machinery/netpod/MouseDrop_T(mob/target, mob/user)
	var/mob/living/carbon/player = user
	if(!iscarbon(player))
		return

	if((HAS_TRAIT(player, TRAIT_UI_BLOCKED) && !player.resting) || !Adjacent(player) || !ISADVANCEDTOOLUSER(player) || !is_operational)
		return

	close_machine(target)

/obj/machinery/netpod/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		attack_hand(user)
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(default_pry_open(tool, user) || default_deconstruction_crowbar(tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/netpod/screwdriver_act(mob/living/user, obj/item/tool)
	if(occupant)
		balloon_alert(user, "in use!")
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(state_open)
		balloon_alert(user, "close first.")
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", "[base_icon_state]_closed", tool))
		update_appearance() // sometimes icon doesnt properly update during flick()
		ui_close(user)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/netpod/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!state_open && user == occupant)
		container_resist_act(user)

/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/netpod/relaymove(mob/living/user, direction)
	if(!state_open)
		container_resist_act(user)

/obj/machinery/netpod/container_resist_act(mob/living/user)
	user.visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"),
		span_notice("With a hiss, you hear a machine opening."))
	open_machine()

/obj/machinery/netpod/open_machine(drop = TRUE, density_to_set = FALSE)
	playsound(src, 'sound/machines/tramopen.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_opening", src)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_OPENED)
	update_use_power(IDLE_POWER_USE)

	return ..()

/obj/machinery/netpod/close_machine(mob/user, density_to_set = TRUE)
	if(!state_open || panel_open || !is_operational || !iscarbon(user))
		return

	playsound(src, 'sound/machines/tramclose.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	..()

	enter_matrix()

/obj/machinery/netpod/default_pry_open(obj/item/crowbar, mob/living/pryer)
	if(isnull(occupant) || !iscarbon(occupant))
		if(!state_open)
			if(panel_open)
				return FALSE
			open_machine()
		else
			shut_pod()

		return TRUE

	pryer.visible_message(
		span_danger("[pryer] starts prying open [src]!"),
		span_notice("You start to pry open [src]."),
		span_notice("You hear loud prying on metal.")
	)
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_CROWBAR_ALERT, pryer)

	if(do_after(pryer, 15 SECONDS, src))
		if(!state_open)
			SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)
			open_machine()

	return TRUE

/obj/machinery/netpod/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational || occupant)
		return

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

/obj/machinery/netpod/attack_ghost(mob/dead/observer/our_observer)
	var/our_target = avatar_ref?.resolve()
	if(isnull(our_target) || !our_observer.orbit(our_target))
		return ..()

/// Puts the occupant in netpod stasis, basically short-circuiting environmental conditions
/obj/machinery/netpod/proc/add_healing(mob/living/target)
	if(target != occupant)
		return

	target.AddComponent(/datum/component/netpod_healing, pod = src)
	target.playsound_local(src, 'sound/effects/submerge.ogg', 20, vary = TRUE)
	target.extinguish_mob()
	update_use_power(ACTIVE_POWER_USE)

/// Disconnects the occupant after a certain time so they aren't just hibernating in netpod stasis. A balance change
/obj/machinery/netpod/proc/auto_disconnect()
	if(isnull(occupant) || state_open || connected)
		return

	var/mob/player = occupant
	player.playsound_local(src, 'sound/effects/splash.ogg', 60, TRUE)
	to_chat(player, span_notice("The machine disconnects itself and begins to drain."))
	open_machine()

/// Handles occupant post-disconnection effects like damage, sounds, etc
/obj/machinery/netpod/proc/disconnect_occupant(forced = FALSE)
	connected = FALSE

	var/mob/living/mob_occupant = occupant
	if(isnull(occupant) || mob_occupant.stat == DEAD)
		open_machine()
		return

	mob_occupant.playsound_local(src, "sound/magic/blink.ogg", 25, TRUE)
	mob_occupant.set_static_vision(2 SECONDS)
	mob_occupant.set_temp_blindness(1 SECONDS)
	mob_occupant.Paralyze(2 SECONDS)

	if(!is_operational)
		open_machine()
		return

	var/heal_time = 1
	if(mob_occupant.health < mob_occupant.maxHealth)
		heal_time = (mob_occupant.stat + 2) * 5
	addtimer(CALLBACK(src, PROC_REF(auto_disconnect)), heal_time SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)

	if(!forced)
		return

	mob_occupant.flash_act(override_blindness_check = TRUE, visual = TRUE)
	mob_occupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, disconnect_damage)
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

	var/datum/lazy_template/virtual_domain/generated_domain = server.generated_domain
	if(isnull(generated_domain) || !server.is_ready)
		balloon_alert(neo, "nothing loaded!")
		return

	var/mob/living/carbon/current_avatar = avatar_ref?.resolve()
	if(isnull(current_avatar) || current_avatar.stat != CONSCIOUS) // We need a viable avatar
		var/obj/structure/hololadder/wayout = server.generate_hololadder()
		if(isnull(wayout))
			balloon_alert(neo, "out of bandwidth!")
			return
		current_avatar = server.generate_avatar(wayout, netsuit)
		avatar_ref = WEAKREF(current_avatar)
		server.stock_gear(current_avatar, neo, generated_domain)

	neo.set_static_vision(3 SECONDS)
	add_healing(occupant)
	if(!do_after(neo, 2 SECONDS, src))
		return

	// Very invalid
	if(QDELETED(neo) || QDELETED(current_avatar) || QDELETED(src))
		return

	// Invalid
	if(occupant != neo || isnull(neo.mind) || neo.stat == DEAD || current_avatar.stat == DEAD)
		return

	current_avatar.AddComponent( \
		/datum/component/avatar_connection, \
		old_mind = neo.mind, \
		old_body = neo, \
		server = server, \
		pod = src, \
		help_text = generated_domain.help_text, \
	)

	connected = TRUE

/// Finds a server and sets the server_ref
/obj/machinery/netpod/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	server = locate(/obj/machinery/quantum_server) in oview(4, src)
	if(isnull(server))
		return

	server_ref = WEAKREF(server)
	RegisterSignal(server, COMSIG_BITRUNNER_SERVER_UPGRADED, PROC_REF(on_server_upgraded))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_complete))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_SCRUBBED, PROC_REF(on_domain_scrubbed))

	return server

/// Creates a list of outfit entries for the UI.
/obj/machinery/netpod/proc/make_outfit_collection(identifier, list/outfit_list)
	var/list/collection = list(
		"name" = identifier,
		"outfits" = list()
	)

	for(var/path as anything in outfit_list)
		var/datum/outfit/outfit = path

		var/outfit_name = initial(outfit.name)
		if(findtext(outfit_name, "(") != 0 || findtext(outfit_name, "-") != 0) // No special variants please
			continue

		collection["outfits"] += list(list("path" = path, "name" = outfit_name))

	return list(collection)

/// Machine has been broken - handles signals and reverting sprites
/obj/machinery/netpod/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

/// Checks the integrity, alerts occupants
/obj/machinery/netpod/proc/on_damage_taken(datum/source, damage_amount)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	var/total = max_integrity - damage_amount
	var/integrity = (atom_integrity / total) * 100
	if(integrity > 50)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_INTEGRITY)

/// Puts points on the current occupant's card account
/obj/machinery/netpod/proc/on_domain_complete(datum/source, atom/movable/crate, reward_points)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	var/mob/living/player = occupant

	var/datum/bank_account/account = player.get_bank_account()
	if(isnull(account))
		return

	account.bitrunning_points += reward_points * 100

/// The domain has been fully purged, so we should double check our avatar is deleted
/obj/machinery/netpod/proc/on_domain_scrubbed(datum/source)
	SIGNAL_HANDLER

	var/mob/avatar = avatar_ref?.resolve()
	if(isnull(avatar))
		return

	QDEL_NULL(avatar)

/// User inspects the machine
/obj/machinery/netpod/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_infoplain("Drag yourself into the pod to engage the link.")
	examine_text += span_infoplain("It has limited resuscitation capabilities. Remaining in the pod can heal some injuries.")
	examine_text += span_infoplain("It has a security system that will alert the occupant if it is tampered with.")

	if(isnull(occupant))
		examine_text += span_notice("It is currently unoccupied.")
		return

	examine_text += span_notice("It is currently occupied by [occupant].")
	examine_text += span_notice("It can be pried open with a crowbar, but its safety mechanisms will alert the occupant.")

/// Boots out anyone in the machine && opens it
/obj/machinery/netpod/proc/on_power_loss(datum/source)
	SIGNAL_HANDLER

	if(state_open)
		return

	if(isnull(occupant) || !connected)
		connected = FALSE
		open_machine()
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

/// When the server is upgraded, drops brain damage a little
/obj/machinery/netpod/proc/on_server_upgraded(datum/source, servo_rating)
	SIGNAL_HANDLER

	disconnect_damage = BASE_DISCONNECT_DAMAGE * (1 - servo_rating)

/// Resolves a path to an outfit.
/obj/machinery/netpod/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(ispath(path, /datum/outfit))
		return path

/// Closes the machine without shoving in an occupant
/obj/machinery/netpod/proc/shut_pod()
	state_open = FALSE
	playsound(src, 'sound/machines/tramclose.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	set_density(TRUE)

	update_appearance()

#undef BASE_DISCONNECT_DAMAGE
