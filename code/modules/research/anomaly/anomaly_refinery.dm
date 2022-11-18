#define MAX_RADIUS_REQUIRED 20 //maxcap
#define MIN_RADIUS_REQUIRED 4 //1, 2, 4
/// How long the compression test can last before the machine just gives up and ejects the items.
#define COMPRESSION_TEST_TIME (SSOBJ_DT SECONDS * 5)

/**
 * # Explosive compressor machines
 *
 * The explosive compressor machine used in anomaly core production.
 *
 * Uses the standard ordnance/tank explosion scaling to compress raw anomaly cores into completed ones. The required explosion radius increases as more cores of that type are created.
 */
/obj/machinery/research/anomaly_refinery
	name = "anomaly refinery"
	desc = "An advanced machine capable of implosion-compressing raw anomaly cores into finished artifacts. Also equipped with state of the art bomb prediction software."
	circuit = /obj/item/circuitboard/machine/anomaly_refinery
	icon = 'icons/obj/machines/research.dmi'
	base_icon_state = "explosive_compressor"
	icon_state = "explosive_compressor"
	density = TRUE

	/// The raw core inserted in the machine.
	var/obj/item/raw_anomaly_core/inserted_core
	/// The TTV inserted in the machine.
	var/obj/item/transfer_valve/inserted_bomb
	/// The timer that lets us timeout the test.
	var/datum/timedevent/timeout_timer
	/// Whether we are currently active a bomb and core.
	var/active = FALSE
	/// The message produced by the explosive compressor at the end of the compression test.
	var/test_status = null
	/// Determines which tank will be the merge_gases target (destroyed upon testing).
	var/obj/item/tank/tank_to_target

	// These vars are used for the explosion simulation and doesn't affect the core detonation.
	/// Combined result of the first two tanks. Exists only in our machine.
	var/datum/gas_mixture/combined_gasmix
	/// Here for the UI, tracks the amounts of reaction that has occured. 1 means valve opened but not reacted.
	var/reaction_increment = 0

/obj/machinery/research/anomaly_refinery/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION, .proc/check_test)

/obj/machinery/research/anomaly_refinery/examine_more(mob/user)
	. = ..()
	if (obj_flags & EMAGGED)
		. += span_notice("A small panel on [p_their()] side is dislaying a notice. Something about firmware?")


/obj/machinery/research/anomaly_refinery/assume_air(datum/gas_mixture/giver)
	return null // Required to make the TTV not vent directly into the air.

/**
 * Determines how much explosive power (last value, so light impact theoretical radius) is required to make a certain anomaly type.
 *
 * Returns null if the max amount has already been reached.
 *
 * Arguments:
 * * anomaly_type - anomaly type define
 */
/obj/machinery/research/anomaly_refinery/proc/get_required_radius(anomaly_type)
	var/already_made = SSresearch.created_anomaly_types[anomaly_type]
	var/hard_limit = SSresearch.anomaly_hard_limit_by_type[anomaly_type]
	if(already_made >= hard_limit)
		return //return null
	// my crappy autoscale formula
	// linear scaling.
	var/radius_span = MAX_RADIUS_REQUIRED - MIN_RADIUS_REQUIRED
	var/radius_increase_per_core = radius_span / hard_limit
	var/radius = clamp(round(MIN_RADIUS_REQUIRED + radius_increase_per_core * already_made, 1), MIN_RADIUS_REQUIRED, MAX_RADIUS_REQUIRED)
	return radius

/obj/machinery/research/anomaly_refinery/attackby(obj/item/tool, mob/living/user, params)
	if(active)
		to_chat(user, span_warning("You can't insert [tool] into [src] while [p_theyre()] currently active."))
		return
	if(istype(tool, /obj/item/raw_anomaly_core))
		if(inserted_core)
			to_chat(user, span_warning("There is already a core in [src]."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		var/obj/item/raw_anomaly_core/raw_core = tool
		if(!get_required_radius(raw_core.anomaly_type))
			say("Unfortunately, due to diminishing supplies of condensed anomalous matter, [raw_core] and any cores of its type are no longer of a sufficient quality level to be compressed into a working core.")
		inserted_core = raw_core
		to_chat(user, span_notice("You insert [raw_core] into [src]."))
		return
	if(istype(tool, /obj/item/transfer_valve))
		if(inserted_bomb)
			to_chat(user, span_warning("There is already a bomb in [src]."))
			return
		var/obj/item/transfer_valve/valve = tool
		if(!valve.ready())
			to_chat(user, span_warning("[valve] is incomplete."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		inserted_bomb = tool
		tank_to_target = inserted_bomb.tank_two
		to_chat(user, span_notice("You insert [tool] into [src]"))
		return
	update_appearance()
	return ..()

/obj/machinery/research/anomaly_refinery/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/research/anomaly_refinery/screwdriver_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_screwdriver(user, "[base_icon_state]-off", "[base_icon_state]", tool))
		return FALSE
	update_appearance()
	return TRUE

/obj/machinery/research/anomaly_refinery/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return FALSE
	return TRUE

/obj/machinery/research/anomaly_refinery/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if (obj_flags & EMAGGED)
		balloon_alert(user, span_warning("already hacked!"))
		return

	obj_flags |= EMAGGED
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, vary = FALSE)
	say("ERROR: Unauthorized firmware access.")
	return TRUE

/**
 * Starts a compression test.
 */
/obj/machinery/research/anomaly_refinery/proc/start_test()
	if (active)
		say("ERROR: Already running a compression test.")
		return

	if(!istype(inserted_core) || !istype(inserted_bomb))
		end_test("ERROR: Missing equpment. Items ejected.")
		return

	if(!inserted_bomb?.tank_one || !inserted_bomb?.tank_two || !(tank_to_target == inserted_bomb?.tank_one || tank_to_target == inserted_bomb?.tank_two))
		end_test("ERROR: Transfer valve malfunctioning. Items ejected.")
		return

	say("Beginning compression test. Opening transfer valve.")
	active = TRUE
	test_status = null

	if (obj_flags & EMAGGED)
		say("ERROR: An firmware issue was detected while starting a process. Running autopatcher.")
		playsound(src, 'sound/machines/ding.ogg', 50, vary = TRUE)
		addtimer(CALLBACK(src, .proc/error_test), 2 SECONDS, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT) // Synced with the sound.
		return

	inserted_bomb.toggle_valve(tank_to_target)
	timeout_timer = addtimer(CALLBACK(src, .proc/timeout_test), COMPRESSION_TEST_TIME, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT)
	return

/**
 * Ejects a live TTV.
 * Triggered by attempting to operate an emagged anomaly refinery.
 */
/obj/machinery/research/anomaly_refinery/proc/error_test()
	message_admins("[src] was emagged and ejected a TTV")
	investigate_log("was emagged and ejected a TTV", INVESTIGATE_RESEARCH)
	obj_flags &= ~EMAGGED

	say("Issue resolved. Have a nice day!")
	inserted_bomb.toggle_valve(tank_to_target)
	eject_bomb(force = TRUE)
	timeout_timer = addtimer(CALLBACK(src, .proc/timeout_test), COMPRESSION_TEST_TIME, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT) // Actually start the test so they can't just put the bomb back in.

/**
 * Ends a compression test.
 *
 * Arguments:
 * - message: A message for the compressor to say when the test ends.
 */
/obj/machinery/research/anomaly_refinery/proc/end_test(message)
	active = FALSE
	tank_to_target = null
	test_status = null
	if(inserted_core)
		eject_core()
	if(inserted_bomb)
		eject_bomb()
	if(timeout_timer)
		QDEL_NULL(timeout_timer)
	if(message)
		say(message)
	return

/**
 * Checks whether an internal explosion was sufficient to compress the core.
 */
/obj/machinery/research/anomaly_refinery/proc/check_test(atom/source, list/arguments)
	SIGNAL_HANDLER
	if(!inserted_core)
		test_status = "ERROR: No core present during detonation."
		return COMSIG_CANCEL_EXPLOSION

	var/heavy = arguments[EXARG_KEY_DEV_RANGE]
	var/medium = arguments[EXARG_KEY_HEAVY_RANGE]
	var/light = arguments[EXARG_KEY_LIGHT_RANGE]
	var/explosion_range = max(heavy, medium, light, 0)
	var/required_range = get_required_radius(inserted_core.anomaly_type)
	var/turf/location = get_turf(src)

	var/cap_multiplier = SSmapping.level_trait(location.z, ZTRAIT_BOMBCAP_MULTIPLIER)
	if(isnull(cap_multiplier))
		cap_multiplier = 1
	var/capped_heavy = min(GLOB.MAX_EX_DEVESTATION_RANGE * cap_multiplier, heavy)
	var/capped_medium = min(GLOB.MAX_EX_HEAVY_RANGE * cap_multiplier, medium)
	SSexplosions.shake_the_room(location, explosion_range, (capped_heavy * 15) + (capped_medium * 20), capped_heavy, capped_medium)

	if(explosion_range < required_range)
		test_status = "Resultant detonation failed to produce enough implosive power to compress [inserted_core]. Items ejected."
		return COMSIG_CANCEL_EXPLOSION

	if(test_status)
		return COMSIG_CANCEL_EXPLOSION
	inserted_core = inserted_core.create_core(src, TRUE, TRUE)
	test_status = "Success. Resultant detonation has theoretical range of [explosion_range]. Required radius was [required_range]. Core production complete."
	return COMSIG_CANCEL_EXPLOSION

/**
 * Handles timing out the test after a while.
 */
/obj/machinery/research/anomaly_refinery/proc/timeout_test()
	timeout_timer = null
	if(!test_status)
		test_status = "Transfer valve resulted in negligible explosive power. Items ejected."
	end_test(test_status)

/// This is not the real valve opening process. This is the simulated one used for displaying reactions.
/obj/machinery/research/anomaly_refinery/proc/simulate_valve()
	if(!inserted_bomb?.tank_one || !inserted_bomb?.tank_two)
		eject_bomb()
		return FALSE

	if(reaction_increment == 0)
		var/datum/gas_mixture/first_gasmix = inserted_bomb.tank_one.return_air()
		var/datum/gas_mixture/second_gasmix = inserted_bomb.tank_two.return_air()

		combined_gasmix = new(70)
		combined_gasmix.volume = first_gasmix.volume + second_gasmix.volume
		combined_gasmix.merge(first_gasmix.copy())
		combined_gasmix.merge(second_gasmix.copy())
	else
		combined_gasmix.react()

	reaction_increment += 1

/// We dont allow incomplete valves to go in but do code in checks for incomplete valves. Just in case.
/obj/machinery/research/anomaly_refinery/proc/eject_bomb(mob/user, force = FALSE)
	if(!inserted_bomb || (active && !force))
		return
	if(user)
		user.put_in_hands(inserted_bomb)
		to_chat(user, span_notice("You remove [inserted_bomb] from [src]."))
	else
		inserted_bomb.forceMove(drop_location())
	combined_gasmix = null
	reaction_increment = 0

/obj/machinery/research/anomaly_refinery/proc/eject_core(mob/user)
	if(!inserted_core || active)
		return
	if(user)
		user.put_in_hands(inserted_core)
		to_chat(user, span_notice("You remove [inserted_core] from [src]."))
	else
		inserted_core.forceMove(drop_location())

/// We rely on exited to clear references.
/obj/machinery/research/anomaly_refinery/Exited(atom/movable/gone, direction)
	if(gone == inserted_bomb)
		inserted_bomb = null
		tank_to_target = null
	if(gone == inserted_core)
		inserted_core = null
	. = ..()

/obj/machinery/research/anomaly_refinery/proc/swap_target()
	if(!inserted_bomb?.tank_one || !inserted_bomb?.tank_two)
		eject_bomb()
		return FALSE
	tank_to_target = (tank_to_target == inserted_bomb.tank_one) ? inserted_bomb.tank_two : inserted_bomb.tank_one

/obj/machinery/research/anomaly_refinery/on_deconstruction()
	eject_bomb()
	eject_core()
	return ..()

/obj/machinery/research/anomaly_refinery/Destroy()
	inserted_bomb = null
	inserted_core = null
	combined_gasmix = null
	return ..()

/obj/machinery/research/anomaly_refinery/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalyRefinery")
		ui.open()

/obj/machinery/research/anomaly_refinery/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("react")
			simulate_valve()
		if("eject_bomb")
			eject_bomb(usr)
		if("eject_core")
			eject_core(usr)
		if("start_implosion")
			start_test()
		if("swap")
			swap_target()

/obj/machinery/research/anomaly_refinery/ui_data(mob/user)
	var/list/data = list()
	var/list/parsed_gasmixes = list()
	var/obj/item/tank/other_tank

	if(inserted_bomb?.tank_one && inserted_bomb?.tank_two)
		other_tank = inserted_bomb.tank_one == tank_to_target ? inserted_bomb.tank_two : inserted_bomb.tank_one

	parsed_gasmixes += list(gas_mixture_parser(tank_to_target?.return_air(), tank_to_target?.name))
	parsed_gasmixes += list(gas_mixture_parser(other_tank?.return_air(), other_tank?.name))
	parsed_gasmixes += list(gas_mixture_parser(combined_gasmix, "Combined Gasmix"))

	data["gasList"] = parsed_gasmixes

	data["valvePresent"] = inserted_bomb ? TRUE : FALSE
	data["valveReady"] = (inserted_bomb?.tank_one && inserted_bomb?.tank_two) ? TRUE : FALSE
	data["reactionIncrement"] = reaction_increment

	data["core"] = inserted_core ? inserted_core.name : FALSE
	data["requiredRadius"] = inserted_core ? get_required_radius(inserted_core.anomaly_type) : null

	data["active"] = active

	return data

#undef MAX_RADIUS_REQUIRED
#undef MIN_RADIUS_REQUIRED
