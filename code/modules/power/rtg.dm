// Radioisotope Thermoelectric Generator (RTG)
// Simple power generator that would replace "magic SMES" on various derelicts.

/obj/machinery/power/rtg
	name = "radioisotope thermoelectric generator"
	desc = "A simple nuclear power generator, used in small outposts to reliably provide power for decades."
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "rtg"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/rtg

	// You can buckle someone to RTG, then open its panel. Fun stuff.
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	var/power_gen = 1000 // Enough to power a single APC. 4000 output with T4 capacitor.

/obj/machinery/power/rtg/Initialize(mapload)
	. = ..()
	connect_to_network()

/obj/machinery/power/rtg/process()
	add_avail(power_to_energy(power_gen))

/obj/machinery/power/rtg/RefreshParts()
	. = ..()
	var/part_level = 0
	for(var/datum/stock_part/stock_part in component_parts)
		part_level += stock_part.tier

	power_gen = initial(power_gen) * part_level

/obj/machinery/power/rtg/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Power generation at <b>[display_power(power_gen, convert = FALSE)]</b>.")

/obj/machinery/power/rtg/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-open", initial(icon_state), I))
		return
	else if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/power/rtg/advanced
	desc = "An advanced RTG capable of moderating isotope decay, increasing power output but reducing lifetime. It uses plasma-fueled radiation collectors to increase output even further."
	power_gen = 1250 // 2500 on T1, 10000 on T4.
	circuit = /obj/item/circuitboard/machine/rtg/advanced

// Void Core, power source for Abductor ships and bases.
// Provides a lot of power, but tends to explode when mistreated.

/obj/machinery/power/rtg/abductor
	name = "Void Core"
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "core"
	desc = "An alien power source that produces energy seemingly out of nowhere."
	circuit = /obj/item/circuitboard/machine/abductor/core
	power_gen = 20000 // 280 000 at T1, 400 000 at T4. Starts at T4.
	can_buckle = FALSE
	pixel_y = 7
	var/going_kaboom = FALSE // Is it about to explode?

/obj/machinery/power/rtg/abductor/proc/overload()
	if(going_kaboom)
		return
	going_kaboom = TRUE
	visible_message(span_danger("\The [src] lets out a shower of sparks as it starts to lose stability!"),\
		span_hear("You hear a loud electrical crack!"))
	playsound(src.loc, 'sound/effects/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
	tesla_zap(source = src, zap_range = 5, power = power_gen * 20)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), src, 2, 3, 4, null, 8), 10 SECONDS) // Not a normal explosion.

/obj/machinery/power/rtg/abductor/bullet_act(obj/projectile/proj)
	. = ..()
	if(!going_kaboom && istype(proj) && proj.damage > 0 && ((proj.damage_type == BURN) || (proj.damage_type == BRUTE)))
		log_bomber(proj.firer, "triggered a", src, "explosion via projectile")
		overload()

/obj/machinery/power/rtg/abductor/blob_act(obj/structure/blob/B)
	overload()

/obj/machinery/power/rtg/abductor/ex_act()
	if(going_kaboom)
		qdel(src)
	else
		overload()

	return TRUE

/obj/machinery/power/rtg/abductor/fire_act(exposed_temperature, exposed_volume)
	overload()

/obj/machinery/power/rtg/abductor/zap_act(power, zap_flags)
	. = ..() //extend the zap
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		overload()

/obj/machinery/power/rtg/debug
	name = "Debug RTG"
	desc = "You really shouldn't be seeing this if you're not a coder or jannie."
	power_gen = 20000
	circuit = null

/obj/machinery/power/rtg/debug/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/machinery/power/rtg/lavaland
	name = "Lava powered RTG"
	desc = "This device only works when exposed to the toxic fumes of Lavaland"
	circuit = null
	power_gen = 20000
	anchored = TRUE
	resistance_flags = LAVA_PROOF

/obj/machinery/power/rtg/lavaland/Initialize(mapload)
	. = ..()
	var/turf/our_turf = get_turf(src)
	if(!islava(our_turf))
		power_gen = 0
	if(!is_mining_level(z))
		power_gen = 0

/obj/machinery/power/rtg/lavaland/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/turf/our_turf = get_turf(src)
	if(!islava(our_turf))
		power_gen = 0
		return
	if(!is_mining_level(z))
		power_gen = 0
		return
	power_gen = initial(power_gen)

/obj/machinery/power/rtg/old_station
	name = "Old RTG"
	desc = "A very old RTG, it seems on the verge of being destroyed"
	circuit = null
	power_gen = 750
	anchored = TRUE

/obj/machinery/power/rtg/old_station/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-open", initial(icon_state), I))
		to_chat(user,span_warning("You feel it crumbling under your hands!"))
		return
	else if(default_deconstruction_crowbar(I, user = user))
		return
	return ..()

/obj/machinery/power/rtg/old_station/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct, mob/user)
	to_chat(user,span_warning("It's starting to fall off!"))
	if(!do_after(user, 3 SECONDS, src))
		return TRUE
	to_chat(user,span_notice("You feel like you made a mistake"))
	new /obj/effect/decal/cleanable/ash/large(loc)
	qdel(src)
