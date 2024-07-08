/datum/action/cooldown/spell/conjure/void_conduit
	name = "Void Conduit"
	desc = "Opens a gate to the Void; it quickly lowers the temperature and pressure of the room while siphoning all gasses. \
		The gate releases an intermittent pulse that damages windows and airlocks, \
		applies a stack of void chill to non heretics, \
		Heretics receive a small heal and are granted the cold resistance and low pressure resistance trait."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "icebeam"

	sound = null
	school = SCHOOL_FORBIDDEN
	invocation = "Conduit!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/void_conduit)
	summon_respects_density = TRUE
	summon_respects_prev_spawn_points = TRUE

/datum/action/cooldown/spell/conjure/void_conduit/cast(atom/cast_on)
	. = ..()

/obj/structure/void_conduit
	name = "Void Conduit"
	desc = "An open gate which leads to nothingness. Pulls in air and energy to release pulses."
	icon = 'icons/effects/effects.dmi'
	icon_state = "void_conduit"

/obj/structure/void_conduit/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/void_conduit/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/void_conduit/process(seconds_per_tick)
	var/turf/our_turf = get_turf(src)
	var/adjacent_turfs = our_turf.get_atmos_adjacent_turfs(alldir = TRUE)
	for(var/turf/tile in adjacent_turfs)
		do_conduit_freeze(tile)

///Siphons out and freezes nearby turfs
/obj/structure/void_conduit/proc/do_conduit_freeze(turf/tile)
	var/datum/gas_mixture/environment = tile.return_air()
	environment.temperature = 0
	tile.remove_air(environment.total_moles() * 0.8)


/*
How many rifts can you have open at once:
like 1

how long do they last?
Forever?

New one replaces the old one

Cooldown: 1 minute

*/






