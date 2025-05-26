
/turf/open/floor/engine
	name = "reinforced floor"
	desc = "Extremely sturdy."
	icon_state = "engine"
	holodeck_compatible = TRUE
	thermal_conductivity = 0.01
	heat_capacity = INFINITY
	floor_tile = /obj/item/stack/rods
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	rcd_proof = TRUE
	rust_resistance = RUST_RESISTANCE_REINFORCED


/turf/open/floor/engine/examine(mob/user)
	. += ..()
	. += span_notice("The reinforcement rods are <b>wrenched</b> firmly in place.")

/turf/open/floor/engine/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/engine/break_tile()
	return //unbreakable

/turf/open/floor/engine/burn_tile()
	return //unburnable

/turf/open/floor/engine/make_plating(force = FALSE)
	if(force)
		return ..()
	return //unplateable

/turf/open/floor/engine/try_replace_tile(obj/item/stack/tile/T, mob/user, list/modifiers)
	return

/turf/open/floor/engine/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/engine/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, span_notice("You begin removing rods..."))
	if(I.use_tool(src, user, 30, volume=80))
		if(!istype(src, /turf/open/floor/engine))
			return TRUE
		if(floor_tile)
			new floor_tile(src, 2)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/turf/open/floor/engine/ex_act(severity, target)
	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	if(severity < EXPLODE_DEVASTATE && is_shielded())
		return FALSE

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(prob(80))
				if (!ispath(baseturf_at_depth(2), /turf/open/floor))
					attempt_lattice_replacement()
				else
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
			else if(prob(50))
				ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
			else
				ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		if(EXPLODE_HEAVY)
			if(prob(50))
				ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

	return TRUE

/turf/open/floor/engine/singularity_pull(atom/singularity, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				new floor_tile(src)
				make_plating(TRUE)
		else if(prob(30))
			attempt_lattice_replacement()

/turf/open/floor/engine/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/open/floor/engine/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

//air filled floors; used in atmos pressure chambers

/turf/open/floor/engine/n2o
	article = "an"
	name = "\improper N2O floor"
	initial_gas_mix = ATMOS_TANK_N2O

/turf/open/floor/engine/co2
	name = "\improper CO2 floor"
	initial_gas_mix = ATMOS_TANK_CO2

/turf/open/floor/engine/plasma
	name = "plasma floor"
	initial_gas_mix = ATMOS_TANK_PLASMA

/turf/open/floor/engine/o2
	name = "\improper O2 floor"
	initial_gas_mix = ATMOS_TANK_O2

/turf/open/floor/engine/n2
	article = "an"
	name = "\improper N2 floor"
	initial_gas_mix = ATMOS_TANK_N2

/turf/open/floor/engine/bz
	name = "\improper BZ floor"
	initial_gas_mix = ATMOS_TANK_BZ

/turf/open/floor/engine/freon
	name = "\improper Freon floor"
	initial_gas_mix = ATMOS_TANK_FREON

/turf/open/floor/engine/halon
	name = "\improper Halon floor"
	initial_gas_mix = ATMOS_TANK_HALON

/turf/open/floor/engine/healium
	name = "\improper Healium floor"
	initial_gas_mix = ATMOS_TANK_HEALIUM

/turf/open/floor/engine/h2
	article = "an"
	name = "\improper H2 floor"
	initial_gas_mix = ATMOS_TANK_H2

/turf/open/floor/engine/hypernoblium
	name = "\improper Hypernoblium floor"
	initial_gas_mix = ATMOS_TANK_HYPERNOBLIUM

/turf/open/floor/engine/miasma
	name = "\improper Miasma floor"
	initial_gas_mix = ATMOS_TANK_MIASMA

/turf/open/floor/engine/nitrium
	name = "\improper nitrium floor"
	initial_gas_mix = ATMOS_TANK_NITRIUM

/turf/open/floor/engine/pluoxium
	name = "\improper Pluoxium floor"
	initial_gas_mix = ATMOS_TANK_PLUOXIUM

/turf/open/floor/engine/proto_nitrate
	name = "\improper Proto-Nitrate floor"
	initial_gas_mix = ATMOS_TANK_PROTO_NITRATE

/turf/open/floor/engine/tritium
	name = "\improper Tritium floor"
	initial_gas_mix = ATMOS_TANK_TRITIUM

/turf/open/floor/engine/h2o
	article = "an"
	name = "\improper H2O floor"
	initial_gas_mix = ATMOS_TANK_H2O

/turf/open/floor/engine/zauker
	name = "\improper Zauker floor"
	initial_gas_mix = ATMOS_TANK_ZAUKER

/turf/open/floor/engine/helium
	name = "\improper Helium floor"
	initial_gas_mix = ATMOS_TANK_HELIUM

/turf/open/floor/engine/antinoblium
	name = "\improper Antinoblium floor"
	initial_gas_mix = ATMOS_TANK_ANTINOBLIUM

/turf/open/floor/engine/air
	name = "air floor"
	initial_gas_mix = ATMOS_TANK_AIRMIX

/turf/open/floor/engine/xenobio
	name = "xenobio bz floor"
	initial_gas_mix = XENOBIO_BZ

/turf/open/floor/engine/cult
	name = "engraved floor"
	desc = "The air smells strange over this sinister flooring."
	icon_state = "cult"
	floor_tile = null
	var/obj/effect/cult_turf/realappearance


/turf/open/floor/engine/cult/Initialize(mapload)
	. = ..()
	icon_state = "plating" //we're redefining the base icon_state here so that the Conceal/Reveal Presence spell works for cultists

	if (!mapload)
		new /obj/effect/temp_visual/cult/turf/floor(src)

	realappearance = new /obj/effect/cult_turf(src)
	realappearance.linked = src

/turf/open/floor/engine/cult/Destroy()
	be_removed()
	return ..()

/turf/open/floor/engine/cult/ChangeTurf(path, new_baseturfs, flags)
	if(path != type)
		be_removed()
	return ..()

/turf/open/floor/engine/cult/proc/be_removed()
	QDEL_NULL(realappearance)

/turf/open/floor/engine/cult/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/engine/telecomms
	initial_gas_mix = TCOMMS_ATMOS
