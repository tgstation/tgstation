// zap needs to be over this amount to get power
#define TESLA_COIL_THRESHOLD 80
// each zap power unit produces 400 joules
#define ZAP_TO_ENERGY(p) (joules_to_energy((p) * 400))

/obj/machinery/power/energy_accumulator/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	circuit = /obj/item/circuitboard/machine/tesla_coil

	///Flags of the zap that the coil releases when the wire is pulsed
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN
	///Multiplier for power conversion
	var/input_power_multiplier = 1
	///Cooldown between pulsed zaps
	var/zap_cooldown = 100
	///Reference to the last zap done
	var/last_zap = 0

	//Variables to calculate sound based on stored_energy to give engineers an audioclue of the magnitude of energy production.
	///Calculated range of zap sounds based on power
	var/zap_sound_range = 0
	///Calculated volume of zap sounds based on power
	var/zap_sound_volume = 0

/obj/machinery/power/energy_accumulator/tesla_coil/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/tesla_coil/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/tesla_coil(src)

/obj/machinery/power/energy_accumulator/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
		zap_cooldown -= (C.rating * 20)
	input_power_multiplier = (0.85 * (power_multiplier / 4)) //Max out at 85% efficency.

/obj/machinery/power/energy_accumulator/tesla_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>" + \
		  "Power generation at <b>[input_power_multiplier*100]%</b>.<br>" + \
			"Shock interval at <b>[zap_cooldown*0.1]</b> seconds.<br>" + \
			"Stored <b>[display_joules(get_stored_joules())]</b>.<br>" + \
			"Processing <b>[display_power(get_power_output())]</b>.")

/obj/machinery/power/energy_accumulator/tesla_coil/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "coil_open[anchored]"
		else
			icon_state = "coil[anchored]"
		update_cable_icons_on_turf(get_turf(src))

/obj/machinery/power/energy_accumulator/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return

	return ..()

/obj/machinery/power/energy_accumulator/tesla_coil/process(delta_time)
	. = ..()
	zap_sound_volume = min(energy_to_joules(stored_energy)/200000, 100)
	zap_sound_range = min(energy_to_joules(stored_energy)/4000000, 10)

/obj/machinery/power/energy_accumulator/tesla_coil/zap_act(power, zap_flags)
	if(!anchored || panel_open)
		return ..()
	obj_flags |= BEING_SHOCKED
	addtimer(CALLBACK(src, .proc/reset_shocked), 1 SECONDS)
	flick("coilhit", src)
	if(!(zap_flags & ZAP_GENERATES_POWER)) //Prevent infinite recursive power
		return 0
	if(zap_flags & ZAP_LOW_POWER_GEN)
		power /= 10
	zap_buckle_check(power)
	var/power_removed = powernet ? power * input_power_multiplier : power
	stored_energy += max(ZAP_TO_ENERGY(power_removed - TESLA_COIL_THRESHOLD), 0)
	return max(power - power_removed, 0) //You get back the amount we didn't use

/obj/machinery/power/energy_accumulator/tesla_coil/proc/zap()
	if((last_zap + zap_cooldown) > world.time || !powernet)
		return FALSE
	last_zap = world.time
	var/power = (powernet.avail) * 0.2 * input_power_multiplier  //Always always always use more then you output for the love of god
	power = min(surplus(), power) //Take the smaller of the two
	add_load(power)
	playsound(src.loc, 'sound/magic/lightningshock.ogg', zap_sound_volume, TRUE, zap_sound_range)
	tesla_zap(src, 10, power, zap_flags)
	zap_buckle_check(power)

/obj/machinery/power/energy_accumulator/grounding_rod
	name = "grounding rod"
	desc = "Keeps an area from being fried by Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = FALSE
	density = TRUE
	wants_powernet = FALSE

	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

/obj/machinery/power/energy_accumulator/grounding_rod/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/grounding_rod/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>" + \
		  "Recently grounded <b>[display_joules(get_stored_joules())]</b>.<br>" + \
			"This energy would sustainably release <b>[display_power(get_power_output())]</b>.")

/obj/machinery/power/energy_accumulator/grounding_rod/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "grounding_rod_open[anchored]"
		else
			icon_state = "grounding_rod[anchored]"

/obj/machinery/power/energy_accumulator/grounding_rod/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/power/energy_accumulator/grounding_rod/zap_act(power, zap_flags)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
		zap_buckle_check(power)
		stored_energy += ZAP_TO_ENERGY(power)
		return 0
	else
		. = ..()

#undef TESLA_COIL_THRESHOLD
#undef ZAP_TO_ENERGY
