var/datum/subsystem/air/SSair

/datum/subsystem/air
	name = "Air"
	priority = 20

	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_hotspots = 0
	var/cost_superconductivity = 0

	var/obj/effect/overlay/plasma_overlay			//overlay for plasma
	var/obj/effect/overlay/sleeptoxin_overlay		//overlay for sleeptoxin

	var/list/excited_groups = list()
	var/list/active_turfs = list()
	var/list/hotspots = list()

	//Special functions lists
	var/list/turf/simulated/active_super_conductivity = list()
	var/list/turf/simulated/high_pressure_delta = list()


/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)

	plasma_overlay	= new /obj/effect/overlay{icon='icons/effects/tile_effects.dmi';mouse_opacity=0;layer=5;icon_state="plasma"}()
	sleeptoxin_overlay	= new /obj/effect/overlay{icon='icons/effects/tile_effects.dmi';mouse_opacity=0;layer=5;icon_state="sleeping_agent"}()


/datum/subsystem/air/Initialize()
	setup_allturfs()
	..()

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))
/datum/subsystem/air/fire()
	var/timer = world.timeofday
	process_active_turfs()
	cost_turfs = MC_AVERAGE(cost_turfs, (world.timeofday - timer))

	timer = world.timeofday
	process_excited_groups()
	cost_groups = MC_AVERAGE(cost_groups, (world.timeofday - timer))

	timer = world.timeofday
	process_high_pressure_delta()
	cost_highpressure = MC_AVERAGE(cost_highpressure, (world.timeofday - timer))

	timer = world.timeofday
	process_hotspots()
	cost_hotspots = MC_AVERAGE(cost_hotspots, (world.timeofday - timer))

	timer = world.timeofday
	process_super_conductivity()
	cost_superconductivity = MC_AVERAGE(cost_superconductivity, (world.timeofday - timer))

#undef MC_AVERAGE


/datum/subsystem/air/proc/process_super_conductivity()
	for(var/turf/simulated/T in active_super_conductivity)
		T.super_conduct()


/datum/subsystem/air/proc/process_hotspots()
	for(var/obj/effect/hotspot/H in hotspots)
		H.process()


/datum/subsystem/air/proc/process_high_pressure_delta()
	for(var/turf/T in high_pressure_delta)
		T.high_pressure_movements()
		T.pressure_difference = 0
	high_pressure_delta.len = 0


/datum/subsystem/air/proc/process_active_turfs()
	for(var/turf/simulated/T in active_turfs)
		T.process_cell()


/datum/subsystem/air/proc/remove_from_active(var/turf/simulated/T)
	if(istype(T))
		T.excited = 0
		active_turfs -= T
		if(T.excited_group)
			T.excited_group.garbage_collect()


/datum/subsystem/air/proc/add_to_active(var/turf/simulated/T, var/blockchanges = 1)
	if(istype(T) && T.air)
		T.excited = 1
		active_turfs |= T
		if(blockchanges && T.excited_group)
			T.excited_group.garbage_collect()
	else
		for(var/direction in cardinal)
			if(!(T.atmos_adjacent_turfs & direction))
				continue
			var/turf/simulated/S = get_step(T, direction)
			if(istype(S))
				add_to_active(S)


/datum/subsystem/air/proc/setup_allturfs()
	for(var/turf/simulated/T in world)
		T.CalculateAdjacentTurfs()
		if(!T.blocks_air)
			if(T.air.check_tile_graphic())
				T.update_visuals(T.air)
			for(var/direction in cardinal)
				if(!(T.atmos_adjacent_turfs & direction))
					continue
				var/turf/enemy_tile = get_step(T, direction)
				if(istype(enemy_tile,/turf/simulated/))
					var/turf/simulated/enemy_simulated = enemy_tile
					if(!T.air.compare(enemy_simulated.air))
						T.excited = 1
						active_turfs |= T
						break
				else
					if(!T.air.check_turf_total(enemy_tile))
						T.excited = 1
						active_turfs |= T

/datum/subsystem/air/proc/process_excited_groups()
	for(var/datum/excited_group/EG in excited_groups)
		EG.breakdown_cooldown ++
		if(EG.breakdown_cooldown == 10)
			EG.self_breakdown()
			return
		if(EG.breakdown_cooldown > 20)
			EG.dismantle()