// Radioisotope Thermoelectric Generator (RTG)
// Simple power generator that would replace "magic SMES" on various derelicts.

/obj/machinery/power/rtg
	name = "radioisotope thermoelectric generator"
	desc = "A simple nuclear power generator, used in small outposts to reliably provide power for decades."
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "rtg"
	base_icon_state = "rtg"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/rtg

	// You can buckle someone to RTG, then open its panel. Fun stuff.
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	/// Whether stock parts affect power generated
	var/affected_by_parts = TRUE
	/// Free power generated every tick
	var/power_gen = 1 KILO WATTS
	/// Base power gen level, potentially modified by parts
	VAR_PRIVATE/base_power_gen

/obj/machinery/power/rtg/Initialize(mapload)
	base_power_gen = power_gen
	. = ..()
	connect_to_network()
	RefreshParts()

/obj/machinery/power/rtg/process()
	add_avail(power_to_energy(power_gen))

/obj/machinery/power/rtg/RefreshParts()
	. = ..()
	var/new_power_gen = get_base_power_gen()
	if(affected_by_parts)
		var/part_level = 0
		for(var/datum/stock_part/stock_part in component_parts)
			part_level += stock_part.tier

		new_power_gen = base_power_gen * (part_level || 1)

	power_gen = new_power_gen

/obj/machinery/power/rtg/proc/get_base_power_gen()
	return base_power_gen

/obj/machinery/power/rtg/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Power generation at <b>[display_power(power_gen, convert = FALSE)]</b>.")

/obj/machinery/power/rtg/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]-open", initial(icon_state), tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/power/rtg/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return panel_open ? ITEM_INTERACT_BLOCKING : NONE

/obj/machinery/power/rtg/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, power_gen) || vname == NAMEOF(src, base_power_gen) || vname == NAMEOF(src, affected_by_parts))
		RefreshParts()

/obj/machinery/power/rtg/advanced
	desc = "An advanced RTG capable of moderating isotope decay, increasing power output but reducing lifetime. It uses plasma-fueled radiation collectors to increase output even further."
	power_gen = 1.25 KILO WATTS
	circuit = /obj/item/circuitboard/machine/rtg/advanced

// Void Core, power source for Abductor ships and bases.
// Provides a lot of power, but tends to explode when mistreated.

/obj/machinery/power/rtg/abductor
	name = "void core"
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "core"
	base_icon_state = "core"
	desc = "An alien power source that produces energy seemingly out of nowhere."
	circuit = /obj/item/circuitboard/machine/abductor/core
	power_gen = 20 KILO WATTS
	can_buckle = FALSE
	SET_BASE_PIXEL(0, 7)
	/// Is it about to explode?
	VAR_PRIVATE/going_kaboom = FALSE

/obj/machinery/power/rtg/abductor/proc/overload()
	if(going_kaboom)
		return
	going_kaboom = TRUE
	visible_message(
		message = span_danger("[src] lets out a shower of sparks as it starts to lose stability!"),
		blind_message = span_hear("You hear a loud electrical crack!"),
	)
	playsound(src, 'sound/effects/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
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
	name = "debug " + parent_type::name
	desc = "You really shouldn't be seeing this if you're not a coder or jannie."
	power_gen = 20 KILO WATTS
	circuit = null
	affected_by_parts = FALSE

/obj/machinery/power/rtg/lavaland
	name = "lava powered " + parent_type::name
	desc = "A power generator that uses the heat and atmosphere of Lavaland to generate power. Won't generate squat anywhere else."
	circuit = null
	power_gen = 20 KILO WATTS
	anchored = TRUE
	resistance_flags = LAVA_PROOF

/obj/machinery/power/rtg/lavaland/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	RefreshParts()

/obj/machinery/power/rtg/lavaland/get_base_power_gen()
	var/turf/our_turf = get_turf(src)
	if(islava(our_turf) && is_mining_level(our_turf.z))
		return base_power_gen
	return 0

/obj/machinery/power/rtg/old_station
	name = "old " + parent_type::name
	desc = "A very old " + parent_type::name + ". It seems on the verge of being destroyed."
	circuit = null
	power_gen = 0.75 KILO WATTS
	anchored = TRUE

/obj/machinery/power/rtg/old_station/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	if(.)
		to_chat(user, span_warning("You feel it crumbling under your hands!"))

/obj/machinery/power/rtg/old_station/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct, mob/user)
	to_chat(user, span_warning("As you pry, [src] starts to fall apart!"))
	if(!crowbar.use_tool(src, user, 3 SECONDS, volume = 50))
		return FALSE
	to_chat(user, span_warning("You feel like you made a mistake."))
	new /obj/effect/decal/cleanable/ash/large(drop_location())
	deconstruct(FALSE)
	return TRUE
