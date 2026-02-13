/obj/machinery/rnd/experimentor
	name = "\improper E.X.P.E.R.I-MENTOR"
	desc = "Experimental Xeon Particle Entropy Reaction Infuser or something like that. Nanotrasen's new reaction infuser, with a slight less tendency to catastrophically fail than the previous model... or so they say."
	icon = 'icons/obj/machines/experimentator.dmi'
	icon_state = "h_lathe"
	base_icon_state = "h_lathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	circuit = /obj/item/circuitboard/machine/experimentor
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON

	/// Weakref to the station Ian the corgi (or whichever we can find)
	var/datum/weakref/tracked_ian_ref
	/// Weakref to the station Runtime the cat (or whichever we can find)
	var/datum/weakref/tracked_runtime_ref
	/// The current probability of a malfunction
	var/malfunction_probability_coeff = 0
	/// How many times we've had a critical reaction
	var/critical_malfunction_counter = 0
	/// How long is the cooldown between experiments
	var/cooldown = EXPERIMENT_COOLDOWN_BASE
	/// List of experiment handler datums by scantype
	var/list/experimentor_result_handlers = list()
	/// Reactions that can occur for specific items
	var/list/item_reactions = list()
	/// Items that we can get by transforming
	var/static/list/valid_items = list()
	/// Items that will cause critical reactions
	var/static/list/critical_items_typecache
	/// Items that the machine shouldn't interact with
	var/static/list/banned_typecache

	COOLDOWN_DECLARE(run_experiment)

/obj/machinery/rnd/experimentor/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/rnd/experimentor(src))

	load_handlers()

	tracked_ian_ref = WEAKREF(locate(/mob/living/basic/pet/dog/corgi/ian) in GLOB.mob_living_list)
	tracked_runtime_ref = WEAKREF(locate(/mob/living/basic/pet/cat/runtime) in GLOB.mob_living_list)

	if(!critical_items_typecache)
		critical_items_typecache = typecacheof(list(
			/obj/item/construction/rcd,
			/obj/item/grenade,
			/obj/item/aicard,
			/obj/item/slime_extract,
			/obj/item/transfer_valve,
		))

	if(!banned_typecache)
		banned_typecache = typecacheof(list(
			/obj/item/stock_parts/power_store/cell/infinite,
			/obj/item/grenade/chem_grenade/tuberculosis
		))

	if(!length(valid_items))
		for(var/obj/item/item_path as anything in valid_subtypesof(/obj/item))
			if(ispath(item_path, /obj/item/stock_parts) || ispath(item_path, /obj/item/grenade/chem_grenade) || ispath(item_path, /obj/item/knife))
				valid_items["[item_path]"] += 15

			if(ispath(item_path, /obj/item/food))
				valid_items["[item_path]"] += rand(1,4)

/obj/machinery/rnd/experimentor/proc/load_handlers()
	for(var/datum/experimentor_result_handler/scan/handler_type as anything in valid_subtypesof(/datum/experimentor_result_handler/scan))
		var/datum/experimentor_result_handler/scan/handler = new handler_type()
		experimentor_result_handlers[handler.scantype] = handler

	experimentor_result_handlers[FAIL] = new /datum/experimentor_result_handler/fail

/obj/machinery/rnd/experimentor/proc/get_available_reactions()
	var/list/all_reactions = list()
	for(var/scantype in experimentor_result_handlers)
		var/datum/experimentor_result_handler/handler = experimentor_result_handlers[scantype]
		if(handler.is_special)
			continue
		all_reactions += scantype

	return all_reactions

/obj/machinery/rnd/experimentor/proc/is_special_reaction(reaction_type)
	var/datum/experimentor_result_handler/handler = experimentor_result_handlers[reaction_type]
	return handler.is_special

/obj/machinery/rnd/experimentor/proc/run_experiment(experiment_type)
	if(!loaded_item)
		return

	icon_state = "[base_icon_state]_wloop"

	var/datum/experimentor_result_handler/handler = experimentor_result_handlers[experiment_type]
	if(handler)
		handler.execute(src, loaded_item)
	else
		fail_experiment()

	handle_global_reactions(loaded_item)
	update_appearance()
	COOLDOWN_START(src, run_experiment, cooldown)

/obj/machinery/rnd/experimentor/proc/show_start_message(message, type)
	switch(type)
		if(MSG_TYPE_NOTICE)
			visible_message(span_notice("[src] [message]"))
		if(MSG_TYPE_WARNING)
			visible_message(span_warning("[src] [message]"))
		if(MSG_TYPE_DANGER)
			visible_message(span_danger("[src] [message]"))
		else
			visible_message(span_notice("[src] [message]"))

/obj/machinery/rnd/experimentor/proc/is_critical_reaction()
	return is_type_in_typecache(loaded_item, critical_items_typecache)

/obj/machinery/rnd/experimentor/proc/get_malfunction_chance()
	return (100 - malfunction_probability_coeff) * 0.01

/obj/machinery/rnd/experimentor/proc/fail_experiment()
	var/datum/experimentor_result_handler/fail_handler = experimentor_result_handlers[FAIL]
	if(fail_handler)
		fail_handler.execute(src, loaded_item)

/obj/machinery/rnd/experimentor/proc/try_generate_reaction_for_item(obj/item/some_item)
	if(is_type_in_typecache(some_item.type, banned_typecache) || item_reactions["[some_item.type]"])
		return

	if(istype(some_item, /obj/item/relic))
		item_reactions["[some_item.type]"] = SCANTYPE_DISCOVER
	else
		item_reactions["[some_item.type]"] = pick(get_available_reactions())

/obj/machinery/rnd/experimentor/RefreshParts()
	. = ..()
	for(var/datum/stock_part/servo/servo in component_parts)
		cooldown = clamp((EXPERIMENT_COOLDOWN_BASE / servo.tier), 0.5, 2)

	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		malfunction_probability_coeff += scanning_module.tier * 2

	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		malfunction_probability_coeff += micro_laser.tier

/obj/machinery/rnd/experimentor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>")
		. += span_notice("Malfunction probability reduced by [span_bold("[malfunction_probability_coeff]")].")
		. += span_notice("Cooldown interval between experiments at [span_bold("[cooldown]")] seconds.")

/obj/machinery/rnd/experimentor/default_deconstruction_crowbar(obj/item/crowbar)
	item_eject()
	return ..()

/obj/machinery/rnd/experimentor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new (user, src, "Experimentor")
		ui.open()

/obj/machinery/rnd/experimentor/ui_data(mob/user)
	var/list/data = list()

	data["hasItem"] = !!loaded_item
	data["isOnCooldown"] = !COOLDOWN_FINISHED(src, run_experiment)
	data["isServerConnected"] = !!stored_research

	var/list/available_experiments = list()
	for(var/scantype in experimentor_result_handlers)
		if(scantype == FAIL)
			continue

		var/datum/experimentor_result_handler/scan/handler = experimentor_result_handlers[scantype]

		var/is_available = TRUE
		var/is_discover = (scantype == SCANTYPE_DISCOVER)

		if(loaded_item)
			if(istype(loaded_item, /obj/item/relic))
				is_available = is_discover
			else
				is_available = !is_discover
			available_experiments += list(list(
				"id" = scantype,
				"name" = handler.name || capitalize(scantype),
				"fa_icon" = handler.fa_icon || "question",
				"isAvailable" = is_available,
				"isDiscover" = is_discover
			))

	data["availableExperiments"] = available_experiments

	if(!isnull(loaded_item))
		var/list/item_data = list()

		item_data["name"] = loaded_item.name
		item_data["icon"] = icon2base64(getFlatIcon(loaded_item, no_anim = TRUE))
		item_data["isRelic"] = istype(loaded_item, /obj/item/relic)

		item_data["associatedNodes"] = list()
		var/list/unlockable_nodes = techweb_item_unlock_check(loaded_item)
		for(var/node_id in unlockable_nodes)
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)

			item_data["associatedNodes"] += list(list(
				"name" = node.display_name,
				"isUnlocked" = !(node_id in stored_research.hidden_nodes),
			))

		data["loadedItem"] = item_data

	return data

/obj/machinery/rnd/experimentor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			item_eject()
			return TRUE

		if("experiment")
			var/reaction = params["id"]
			if(isnull(reaction))
				return

			try_perform_experiment(reaction)
			return TRUE

/obj/machinery/rnd/experimentor/proc/item_eject(should_clone = FALSE)
	if(isnull(loaded_item))
		return

	var/atom/drop_atom = get_step(src, EAST) || drop_location()
	if(should_clone)
		visible_message(span_notice("A duplicate of \the [loaded_item] pops out!"))
		new loaded_item.type(drop_atom)
		return

	loaded_item.forceMove(drop_atom)
	loaded_item = null

/obj/machinery/rnd/experimentor/proc/match_reaction(obj/item/matching, target_reaction)
	PRIVATE_PROC(TRUE)
	if(isnull(matching) || isnull(target_reaction))
		return FAIL

	if(item_reactions["[matching.type]"] == target_reaction)
		return item_reactions["[matching.type]"]
	return FAIL

/obj/machinery/rnd/experimentor/proc/try_perform_experiment(reaction)
	PRIVATE_PROC(TRUE)
	if(!stored_research || !loaded_item || !COOLDOWN_FINISHED(src, run_experiment))
		return FALSE

	if(istype(loaded_item, /obj/item/relic))
		reaction = SCANTYPE_DISCOVER
	else if(reaction != SCANTYPE_DISCOVER)
		reaction = match_reaction(loaded_item, reaction)

	if(reaction != FAIL)
		var/picked_node_id = pick(techweb_item_unlock_check(loaded_item))
		stored_research.unhide_node(SSresearch.techweb_node_by_id(picked_node_id))

	run_experiment(reaction)
	use_energy(750 JOULES)

/obj/machinery/rnd/experimentor/proc/handle_global_reactions()
	if(!prob(EFFECT_PROBABILITY * (100 - malfunction_probability_coeff) * 0.01) || !loaded_item)
		return

	var/malf_coefficient = rand(1, 100)
	switch(malf_coefficient)
		if(1 to 15)
			visible_message(span_warning("[src]'s onboard detection system has malfunctioned!"))
			item_reactions["[loaded_item.type]"] = pick(get_available_reactions())
			item_eject()
		if(16 to 35)
			visible_message(span_warning("[src] melts [loaded_item], ian-izing the air around it!"))
			do_smoke(1, src, src)
			var/mob/living/tracked_ian = tracked_ian_ref?.resolve()
			if(tracked_ian)
				do_smoke(1, src, tracked_ian.loc)
				tracked_ian.forceMove(loc)
				investigate_log("Experimentor has stolen Ian!", INVESTIGATE_EXPERIMENTOR)
			else
				new /mob/living/basic/pet/dog/corgi(loc)
				investigate_log("Experimentor has spawned a new corgi.", INVESTIGATE_EXPERIMENTOR)
		if(36 to 50)
			visible_message(span_warning("Experimentor draws the life essence of those nearby!"))
			for(var/mob/living/m in view(4,src))
				to_chat(m, span_danger("You feel your flesh being torn from you, mists of blood drifting to [src]!"))
				playsound(src, pick('sound/effects/curse/curse1.ogg', 'sound/effects/curse/curse2.ogg', 'sound/effects/curse/curse3.ogg'), 30)
				m.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
				investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", INVESTIGATE_EXPERIMENTOR)
		if(51 to 75)
			visible_message(span_warning("[src] encounters a run-time error!"))
			do_smoke(1, src, src)
			var/mob/living/tracked_runtime = tracked_runtime_ref?.resolve()
			if(tracked_runtime)
				do_smoke(1, src, tracked_runtime.loc)
				tracked_runtime.forceMove(drop_location())
				investigate_log("Experimentor has stolen Runtime!", INVESTIGATE_EXPERIMENTOR)
			else
				new /mob/living/basic/pet/cat(loc)
				investigate_log("Experimentor failed to steal Runtime the cat and instead spawned a new cat.", INVESTIGATE_EXPERIMENTOR)
		if(76 to 98)
			visible_message(span_warning("[src] emits a low hum."))
			do_sparks(3, FALSE, src, src)
			use_energy(500 KILO JOULES)
			investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)
		if(99)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(boom)), 5 SECONDS)
		if(100)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(honk)), 5 SECONDS)


/obj/machinery/rnd/experimentor/proc/boom()
	explosion(src, devastation_range = 1, heavy_impact_range = 5, light_impact_range = 10, flash_range = 5, adminlog = TRUE)

/obj/machinery/rnd/experimentor/proc/honk()
	playsound(src, 'sound/items/bikehorn.ogg', 500)
	new /obj/item/grown/bananapeel(loc)


/obj/machinery/rnd/experimentor/item_interaction(mob/living/user, obj/item/weapon, list/modifiers)
	if(user.combat_mode)
		return ITEM_INTERACT_BLOCKING

	if(panel_open && is_wire_tool(weapon))
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS

	if(!is_insertion_ready(user))
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(weapon, src))
		to_chat(user, span_warning("\The [weapon] is stuck to your hand!"))
		return ITEM_INTERACT_BLOCKING

	loaded_item = weapon
	to_chat(user, span_notice("You put [weapon] in the chamber."))
	flick("h_lathe_load", src)
	try_generate_reaction_for_item(loaded_item)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/rnd/experimentor/attack_hand_secondary(mob/user, list/modifiers)
	if(!panel_open)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	wires.interact(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/rnd/experimentor/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/rnd/experimentor/multitool_act(mob/living/user, obj/item/tool)
	if(panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/rnd/experimentor/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/rnd/experimentor/proc/warn_admins(user, ReactionName)
	var/turf/T = get_turf(user)
	message_admins("Experimentor reaction: [ReactionName] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(T)]")
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in [AREACOORD(T)]")
