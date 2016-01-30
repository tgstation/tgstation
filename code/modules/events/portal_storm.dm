/datum/round_event_control/portal_storm_syndicate
	name = "Portal Storm: Syndicate Shocktroops"
	typepath = /datum/round_event/portal_storm/syndicate_shocktroop
	weight = 10

/datum/round_event/portal_storm/syndicate_shocktroop
	boss_type = /mob/living/simple_animal/hostile/syndicate/mecha_pilot //DEATH
	hostile_type = /mob/living/simple_animal/hostile/syndicate/ranged/space
	hostiles_number = 50

/datum/round_event/portal_storm
	startWhen = 7
	endWhen = 999
	announceWhen = 1

	var/turf/boss_spawn
	var/boss_type
	var/list/hostiles_spawn = list()
	var/hostile_type
	var/hostiles_number = 0
	var/list/station_areas = list()
	var/image/storm

/datum/round_event/portal_storm/setup()
	storm = image('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", layer=FLY_LAYER)

	station_areas = get_areas_in_z(ZLEVEL_STATION)

	if(boss_type)
		boss_spawn = get_turf(safepick(generic_event_spawns))
		if(!boss_spawn)
			boss_spawn = safepick(get_area_turfs(safepick(station_areas)))

	if(hostile_type)
		var/list/possible_spawns = generic_event_spawns.Copy()
		while(hostiles_number > hostiles_spawn.len)
			var/turf/T = get_turf(pick_n_take(possible_spawns))
			if(!T)
				T = safepick(get_area_turfs(safepick(station_areas)))
			hostiles_spawn += T

/datum/round_event/portal_storm/announce()
	set waitfor = 0
	playsound_global('sound/magic/lightning_chargeup.ogg', repeat=0, channel=1, volume=100)
	sleep(80)
	priority_announce("Attention personnel of [world.name]: incoming portal storm!")
	sleep(20)
	playsound_global('sound/magic/lightningbolt.ogg', repeat=0, channel=1, volume=100)

/datum/round_event/portal_storm/tick()
	spawn_effects()
	if(IsMultiple(activeFor, 2))
		spawn_mob()
		if(!hostiles_spawn.len)
			spawn_mob(1)
			endWhen = activeFor

/datum/round_event/portal_storm/proc/spawn_mob(boss=0)
	if(boss)
		if(boss_type && boss_spawn)
			spawn_effects(boss_spawn)
			new boss_type(boss_spawn)
	else
		var/turf/T = pick_n_take(hostiles_spawn)
		if(hostile_type && T)
			spawn_effects(T)
			new hostile_type(T)

/datum/round_event/portal_storm/proc/spawn_effects(turf/T)
	if(T)
		flick_overlay_better(storm, T, 15)
		playsound(T, 'sound/magic/lightningbolt.ogg', 100, 1)
	else
		for(var/V in station_areas)
			var/area/A = V
			var/turf/F = get_turf(pick(A.contents))
			flick_overlay_better(storm, F, 15)
			playsound(F, 'sound/magic/lightningbolt.ogg', 100, 1)
