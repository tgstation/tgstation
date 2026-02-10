#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7
#define FAIL 8

#define EFFECT_PROBABILITY 20
#define EXPERIMENT_COOLDOWN_BASE 2 SECONDS
#define ALL_REACTIONS_EXCEPT_DISCOVER list(SCANTYPE_POKE, SCANTYPE_IRRADIATE, SCANTYPE_GAS, SCANTYPE_HEAT, SCANTYPE_COLD, SCANTYPE_OBLITERATE)

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
	/// List of experiment handler datums
	var/list/experiment_handlers = list()
	/// Reactions that can occur
	var/list/item_reactions
	/// Items that we can get by transforming
	var/list/valid_items
	/// Items that will cause critical reactions
	var/list/critical_items_typecache

	COOLDOWN_DECLARE(run_experiment)

/obj/machinery/rnd/experimentor/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/rnd(src))

	experiment_handlers[SCANTYPE_POKE] = new /datum/experiment_handler/poke()
	experiment_handlers[SCANTYPE_IRRADIATE] = new /datum/experiment_handler/irradiate()
	experiment_handlers[SCANTYPE_GAS] = new /datum/experiment_handler/gas()
	experiment_handlers[SCANTYPE_HEAT] = new /datum/experiment_handler/heat()
	experiment_handlers[SCANTYPE_COLD] = new /datum/experiment_handler/cold()
	experiment_handlers[SCANTYPE_OBLITERATE] = new /datum/experiment_handler/obliterate()
	experiment_handlers[SCANTYPE_DISCOVER] = new /datum/experiment_handler/discover()
	experiment_handlers[FAIL] = new /datum/experiment_handler/fail()

	tracked_ian_ref = WEAKREF(locate(/mob/living/basic/pet/dog/corgi/ian) in GLOB.mob_living_list)
	tracked_runtime_ref = WEAKREF(locate(/mob/living/basic/pet/cat/runtime) in GLOB.mob_living_list)

	critical_items_typecache = typecacheof(list(
		/obj/item/construction/rcd,
		/obj/item/grenade,
		/obj/item/aicard,
		/obj/item/slime_extract,
		/obj/item/transfer_valve,
	))

	var/static/list/banned_typecache = typecacheof(list(
		/obj/item/stock_parts/power_store/cell/infinite,
		/obj/item/grenade/chem_grenade/tuberculosis
	))

	for(var/obj/item/item_path as anything in valid_subtypesof(/obj/item))
		if(ispath(item_path, /obj/item/stock_parts) || ispath(item_path, /obj/item/grenade/chem_grenade) || ispath(item_path, /obj/item/knife))
			valid_items["[item_path]"] += 15

		if(ispath(item_path, /obj/item/food))
			valid_items["[item_path]"] += rand(1,4)

/obj/machinery/rnd/experimentor/base_item_interaction(mob/living/user, obj/item/weapon, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) || user.combat_mode || !is_insertion_ready(user))
		return ..()

	if(!user.transferItemToLoc(weapon, src))
		to_chat(user, span_warning("\The [weapon] is stuck to your hand!"))
		return TRUE

	loaded_item = weapon
	to_chat(user, span_notice("You put [weapon] in the chamber."))
	flick("h_lathe_load", src)
	try_generate_reaction_for_item(loaded_item)
	return TRUE

/obj/machinery/rnd/experimentor/proc/run_experiment(experiment_type)
	if(!loaded_item)
		return

	icon_state = "[base_icon_state]_wloop"
	var/datum/experiment_handler/handler = experiment_handlers[experiment_type]
	if(handler)
		handler.execute(src, loaded_item)
	else
		fail_experiment()

	handle_global_reactions(loaded_item)
	update_appearance()
	COOLDOWN_START(src, run_experiment, cooldown)

/obj/machinery/rnd/experimentor/proc/is_critical_reaction()
	return is_type_in_typecache(loaded_item, critical_items_typecache)

/obj/machinery/rnd/experimentor/proc/get_malfunction_chance()
	return (100 - malfunction_probability_coeff) * 0.01

/obj/machinery/rnd/experimentor/proc/fail_experiment()
	var/a = pick("rumbles", "shakes", "vibrates", "shudders", "honks")
	var/b = pick("crushes", "spins", "crumbles", "smashes", "squeezes")
	visible_message(span_warning("[loaded_item] [a] and [b] before coming to a stop. It seems the experiment was a failure."))

/obj/machinery/rnd/experimentor/proc/try_generate_reaction_for_item(var/obj/item/some_item)
	var/item_path = some_item.path

	if(is_type_in_typecache(item_path, banned_typecache) || item_reactions["[item_path]"])
		return

	item_reactions["[item_path]"] = (ispath(item_path, /obj/item/relic) ? SCANTYPE_DISCOVER : pick(ALL_REACTIONS_EXCEPT_DISCOVER))

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
		ui = new (user, src, "Experimentator")
		ui.open()

/obj/machinery/rnd/experimentor/ui_data(mob/user)
	var/list/data = list()

	data["hasItem"] = !!loaded_item
	data["isOnCooldown"] = !COOLDOWN_FINISHED(src, run_experiment)
	data["isServerConnected"] = !!stored_research

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
			var/reaction = text2num(params["id"])
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

	if("[matching.type]" in item_reactions)
		var/associated_reaction = item_reactions["[matching.type]"]
		if(associated_reaction == target_reaction)
			return associated_reaction

	return FAIL

/obj/machinery/rnd/experimentor/proc/try_perform_experiment(reaction)
	PRIVATE_PROC(TRUE)
	if(!stored_research || !loaded_item || !COOLDOWN_FINISHED(src, run_experiment))
		return FALSE

	if(reaction != SCANTYPE_DISCOVER)
		reaction = match_reaction(loaded_item, reaction)

	if(reaction != FAIL)
		var/picked_node_id = pick(techweb_item_unlock_check(loaded_item))
		stored_research.unhide_node(SSresearch.techweb_node_by_id(picked_node_id))

	run_experiment(reaction, loaded_item)
	use_energy(750 JOULES)

/obj/machinery/rnd/experimentor/proc/handle_global_reactions()
	if(!prob(EFFECT_PROBABILITY * (100 - malfunction_probability_coeff) * 0.01) || !loaded_item)
		return

	var/malf_coefficient = rand(1, 100)
	switch(malf_coefficient)
		if(1 to 15)
			visible_message(span_warning("[src]'s onboard detection system has malfunctioned!"))
			item_reactions["[loaded_item.type]"] = pick(SCANTYPE_POKE, SCANTYPE_IRRADIATE, SCANTYPE_GAS, SCANTYPE_HEAT, SCANTYPE_COLD, SCANTYPE_OBLITERATE)
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
			QDEL_NULL(src)
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
			QDEL_NULL(src)
		if(76 to 98)
			visible_message(span_warning("[src] begins to smoke and hiss, shaking violently!"))
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

/obj/machinery/rnd/experimentor/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/machinery/rnd/experimentor/proc/warn_admins(user, ReactionName)
	var/turf/T = get_turf(user)
	message_admins("Experimentor reaction: [ReactionName] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(T)]")
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in [AREACOORD(T)]")

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER
#undef FAIL

#undef EFFECT_PROBABILITY
#undef EXPERIMENT_COOLDOWN_BASE
#undef ALL_REACTIONS_EXCEPT_DISCOVER
