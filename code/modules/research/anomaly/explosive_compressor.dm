#define MAX_RADIUS_REQUIRED 20 //maxcap
#define MIN_RADIUS_REQUIRED 4 //1, 2, 4
/**
 * # Explosive compressor machines
 *
 * The explosive compressor machine used in anomaly core production.
 *
 * Uses the standard toxins/tank explosion scaling to compress raw anomaly cores into completed ones. The required explosion radius increases as more cores of that type are created.
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
	/// The last time we did say_requirements(), because someone will inevitably click spam this.
	var/last_requirements_say = 0

/obj/machinery/research/explosive_compressor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl-Click to remove an inserted core.</span>"
	. += "<span class='notice'>Click with an empty hand to gather information about the required radius of an inserted core. Insert a ready TTV to start the implosion process if a core is inserted.</span>"

/obj/machinery/research/explosive_compressor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!inserted_core)
		to_chat(user, "<span class='warning'>There is no core inserted.</span>")
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
		to_chat(user, "<span class='warning'>There is no core inserted.</span>")
		return
	inserted_core.forceMove(get_turf(user))
	to_chat(user, "<span class='notice'>You remove [inserted_core] from [src].</span>")
	user.put_in_hands(inserted_core)
	inserted_core = null

/**
 * Says (no, literally) the data of required explosive power for a certain anomaly type.
 */
/obj/machinery/research/explosive_compressor/proc/say_requirements(obj/item/raw_anomaly_core/C)
	var/required = get_required_radius(C.anomaly_type)
	if(isnull(required))
		say("Unfortunately, due to diminishing supplies of condensed anomalous matter, [C] and any cores of its type are no longer of a sufficient quality level to be compressed into a working core.")
	else
		say("[C] requires a minimum of a theoretical radius of [required] to successfully implode into a charged anomaly core.")

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

/obj/machinery/research/explosive_compressor/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/raw_anomaly_core))
		if(inserted_core)
			to_chat(user, "<span class='warning'>There is already a core in [src].</span>")
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand.</span>")
			return
		inserted_core = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		return
	if(istype(I, /obj/item/transfer_valve))
		// If they don't have a bomb core inserted, don't let them insert this. If they do, insert and do implosion.
		if(!inserted_core)
			to_chat(user, "<span class='warning'>There is no core inserted in [src]. What would be the point of detonating an implosion without a core?</span>")
			return
		var/obj/item/transfer_valve/valve = I
		if(!valve.ready())
			to_chat(user, "<span class='warning'>[valve] is incomplete.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand.</span>")
			return
		inserted_bomb = I
		to_chat(user, "<span class='notice'>You insert [I] and press the start button.</span>")
		do_implosion()

/**
 * The ""explosion"" proc.
 */
/obj/machinery/research/explosive_compressor/proc/do_implosion()
	var/required_radius = get_required_radius(inserted_core.anomaly_type)
	// By now, we should be sure that we have a core, a TTV, and that the TTV has both tanks in place.
	var/datum/gas_mixture/mix1 = inserted_bomb.tank_one.air_contents
	var/datum/gas_mixture/mix2 = inserted_bomb.tank_two.air_contents
	// Snowflaked tank explosion
	var/datum/gas_mixture/mix = new(70) // Standard tank volume, 70L
	mix.merge(mix1)
	mix.merge(mix2)
	mix.react()
	if(mix.return_pressure() < TANK_FRAGMENT_PRESSURE)
		// They failed so miserably we're going to give them their bomb back.
		inserted_bomb.forceMove(drop_location())
		inserted_bomb = null
		inserted_core.forceMove(drop_location())
		inserted_core = null
		say("Transfer valve resulted in negligible explosive power. Items ejected.")
		return
	mix.react() // build more pressure
	var/pressure = mix.return_pressure()
	var/range = (pressure - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE
	if(range < required_radius)
		inserted_bomb.forceMove(src)
		say("Resultant detonation failed to produce enough implosive power to compress [inserted_core]. Core ejected.")
		return
	QDEL_NULL(inserted_bomb) // bomb goes poof
	inserted_core.create_core(drop_location(), TRUE, TRUE)
	inserted_core = null
	say("Success. Resultant detonation has theoretical range of [range]. Required radius was [required_radius]. Core production complete.")

#undef MAX_RADIUS_REQUIRED
#undef MIN_RADIUS_REQUIRED
