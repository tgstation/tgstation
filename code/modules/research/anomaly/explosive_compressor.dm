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
/obj/machinery/research/explosive_compressor
	name = "implosion compressor"
	desc = "An advanced machine capable of implosion-compressing raw anomaly cores into finished artifacts."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "explosive_compressor"
	density = TRUE

	/// The raw core inserted in the machine.
	var/obj/item/raw_anomaly_core/inserted_core
	/// The TTV inserted in the machine.
	var/obj/item/transfer_valve/inserted_bomb
	/// The timer that lets us timeout the test.
	var/datum/timedevent/timeout_timer
	/// Whether we are currently testing a bomb and core.
	var/testing = FALSE
	/// The message produced by the explosive compressor at the end of the compression test.
	var/test_status = null
	/// The last time we did say_requirements(), because someone will inevitably click spam this.
	var/last_requirements_say = 0

/obj/machinery/research/explosive_compressor/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION, .proc/check_test)

/obj/machinery/research/explosive_compressor/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION)
	return ..()

/obj/machinery/research/explosive_compressor/examine(mob/user)
	. = ..()
	. += span_notice("Ctrl-Click to remove an inserted core.")
	. += span_notice("Click with an empty hand to gather information about the required radius of an inserted core. Insert a ready TTV to start the implosion process if a core is inserted.")

/obj/machinery/research/explosive_compressor/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null // Required to make the TTV not vent directly into the air.

/obj/machinery/research/explosive_compressor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!inserted_core)
		to_chat(user, span_warning("There is no core inserted."))
		return
	if(last_requirements_say + 3 SECONDS > world.time)
		return
	last_requirements_say = world.time
	say_requirements(inserted_core)

/obj/machinery/research/explosive_compressor/CtrlClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.Adjacent(src) || !(user.mobility_flags & MOBILITY_USE))
		return
	if(!inserted_core)
		to_chat(user, span_warning("There is no core inserted."))
		return
	if(testing)
		to_chat(user, span_warning("You can't remove [inserted_core] from [src] while [p_theyre()] in testing mode."))
		return
	inserted_core.forceMove(get_turf(user))
	to_chat(user, span_notice("You remove [inserted_core] from [src]."))
	user.put_in_hands(inserted_core)
	inserted_core = null

/**
 * Says (no, literally) the data of required explosive power for a certain anomaly type.
 */
/obj/machinery/research/explosive_compressor/proc/say_requirements(obj/item/raw_anomaly_core/core)
	var/required = get_required_radius(core.anomaly_type)
	if(isnull(required))
		say("Unfortunately, due to diminishing supplies of condensed anomalous matter, [core] and any cores of its type are no longer of a sufficient quality level to be compressed into a working core.")
	else
		say("[core] requires a minimum of a theoretical radius of [required] to successfully implode into a charged anomaly core.")

/**
 * Determines how much explosive power (last value, so light impact theoretical radius) is required to make a certain anomaly type.
 *
 * Returns null if the max amount has already been reached.
 *
 * Arguments:
 * * anomaly_type - anomaly type define
 */
/obj/machinery/research/explosive_compressor/proc/get_required_radius(anomaly_type)
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

/obj/machinery/research/explosive_compressor/attackby(obj/item/tool, mob/living/user, params)
	. = ..()
	if(istype(tool, /obj/item/raw_anomaly_core))
		if(inserted_core)
			to_chat(user, span_warning("There is already a core in [src]."))
			return
		if(testing)
			to_chat(user, span_warning("You can't insert [tool] into [src] while [p_theyre()] in testing mode."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		inserted_core = tool
		to_chat(user, span_notice("You insert [tool] into [src]."))
		return
	if(istype(tool, /obj/item/transfer_valve))
		// If they don't have a bomb core inserted, don't let them insert this. If they do, insert and do implosion.
		if(!inserted_core)
			to_chat(user, span_warning("There is no core inserted in [src]. What would be the point of detonating an implosion without a core?"))
			return
		if(testing)
			to_chat(user, span_warning("You can't insert [tool] into [src] while [p_theyre()] in testing mode."))
			return
		var/obj/item/transfer_valve/valve = tool
		if(!valve.ready())
			to_chat(user, span_warning("[valve] is incomplete."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		inserted_bomb = tool
		to_chat(user, span_notice("You insert [tool] and press the start button."))
		start_test()


/**
 * Starts a compression test.
 */
/obj/machinery/research/explosive_compressor/proc/start_test()
	if(!istype(inserted_core) || !istype(inserted_bomb))
		end_test("ERROR: Missing equpment. Items ejected.")
		return

	say("Beginning compression test. Opening transfer valve.")
	testing = TRUE
	test_status = null
	inserted_bomb.toggle_valve()
	timeout_timer = addtimer(CALLBACK(src, .proc/timeout_test), COMPRESSION_TEST_TIME, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT)
	return

/**
 * Ends a compression test.
 *
 * Arguments:
 * - message: A message for the compressor to say when the test ends.
 */
/obj/machinery/research/explosive_compressor/proc/end_test(message)
	if(inserted_core)
		inserted_core.forceMove(drop_location())
		inserted_core = null
	if(inserted_bomb)
		inserted_bomb.forceMove(drop_location())
		inserted_bomb = null
	if(timeout_timer)
		QDEL_NULL(timeout_timer)
	if(message)
		say(message)
	testing = FALSE
	return

/**
 * Checks whether an internal explosion was sufficient to compress the core.
 */
/obj/machinery/research/explosive_compressor/proc/check_test(atom/source, list/arguments)
	SIGNAL_HANDLER
	. = COMSIG_CANCEL_EXPLOSION
	if(!inserted_core)
		test_status = "ERROR: No core present during detonation."
		return

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
		test_status = "Resultant detonation failed to produce enough implosive power to compress [inserted_core]. Core ejected."
		return

	if(test_status)
		return
	inserted_core = inserted_core.create_core(src, TRUE, TRUE)
	test_status = "Success. Resultant detonation has theoretical range of [explosion_range]. Required radius was [required_range]. Core production complete."
	return

/**
 * Handles timing out the test after a while.
 */
/obj/machinery/research/explosive_compressor/proc/timeout_test()
	timeout_timer = null
	if(!test_status)
		test_status = "Transfer valve resulted in negligible explosive power. Items ejected."
	end_test(test_status)

#undef MAX_RADIUS_REQUIRED
#undef MIN_RADIUS_REQUIRED
