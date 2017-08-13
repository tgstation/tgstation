/datum/round_event_control/portal_storm_syndicate
	name = "Portal Storm: Syndicate Shocktroops"
	typepath = /datum/round_event/portal_storm/syndicate_shocktroop
	weight = 2
	min_players = 15
	earliest_start = 18000

/datum/round_event/portal_storm/syndicate_shocktroop
	boss_types = list(/mob/living/simple_animal/hostile/syndicate/melee/space/stormtrooper = 2)
	hostile_types = list(/mob/living/simple_animal/hostile/syndicate/melee/space = 8,\
						/mob/living/simple_animal/hostile/syndicate/ranged/space = 2)

/datum/round_event_control/portal_storm_narsie
	name = "Portal Storm: Constructs"
	typepath = /datum/round_event/portal_storm/portal_storm_narsie
	weight = 0
	max_occurrences = 0

/datum/round_event/portal_storm/portal_storm_narsie
	boss_types = list(/mob/living/simple_animal/hostile/construct/builder = 6)
	hostile_types = list(/mob/living/simple_animal/hostile/construct/armored/hostile = 8,\
						/mob/living/simple_animal/hostile/construct/wraith/hostile = 6)

/datum/round_event/portal_storm
	startWhen = 7
	endWhen = 999
	announceWhen = 1

	var/list/boss_spawn = list()
	var/list/boss_types = list() //only configure this if you have hostiles
	var/number_of_bosses
	var/next_boss_spawn
	var/list/hostiles_spawn = list()
	var/list/hostile_types = list()
	var/number_of_hostiles
	var/list/station_areas = list()
	var/mutable_appearance/storm

/datum/round_event/portal_storm/setup()
	storm = 	storm = mutable_appearance('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
	storm.color = "#00FF00"

	station_areas = get_areas_in_z(ZLEVEL_STATION)

	number_of_bosses = 0
	for(var/boss in boss_types)
		number_of_bosses += boss_types[boss]

	number_of_hostiles = 0
	for(var/hostile in hostile_types)
		number_of_hostiles += hostile_types[hostile]

	var/list/b_spawns = GLOB.generic_event_spawns.Copy()
	while(number_of_bosses > boss_spawn.len)
		var/turf/F = get_turf(pick_n_take(b_spawns))
		if(!F)
			F = safepick(get_area_turfs(pick(station_areas)))
		boss_spawn += F

	var/list/h_spawns = GLOB.generic_event_spawns.Copy()
	while(number_of_hostiles > hostiles_spawn.len)
		var/turf/T = get_turf(pick_n_take(h_spawns))
		if(!T)
			T = safepick(get_area_turfs(pick(station_areas)))
		hostiles_spawn += T

	next_boss_spawn = startWhen + Ceiling(2 * number_of_hostiles / number_of_bosses)

/datum/round_event/portal_storm/announce()
	set waitfor = 0
	sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
	sleep(80)
	priority_announce("Massive bluespace anomaly detected en route to [station_name()]. Brace for impact.")
	sleep(20)
	sound_to_playing_players('sound/magic/lightningbolt.ogg')

/datum/round_event/portal_storm/tick()
	spawn_effects()

	if(spawn_hostile())
		var/type = safepick(hostile_types)
		hostile_types[type] = hostile_types[type] - 1
		spawn_mob(type, hostiles_spawn)
		if(!hostile_types[type])
			hostile_types -= type

	if(spawn_boss())
		var/type = safepick(boss_types)
		boss_types[type] = boss_types[type] - 1
		spawn_mob(type, boss_spawn)
		if(!boss_types[type])
			boss_types -= type

	time_to_end()

/datum/round_event/portal_storm/proc/spawn_mob(type, spawn_list)
	if(!type)
		return
	var/turf/T = pick_n_take(spawn_list)
	if(!T)
		return
	new type(T)
	spawn_effects(T)

/datum/round_event/portal_storm/proc/spawn_effects(turf/T)
	if(T)
		T = get_step(T, SOUTHWEST) //align center of image with turf
		flick_overlay_static(storm, T, 15)
		playsound(T, 'sound/magic/lightningbolt.ogg', 100, 1)
	else
		for(var/V in station_areas)
			var/area/A = V
			var/turf/F = get_turf(pick(A.contents))
			flick_overlay_static(storm, F, 15)
			playsound(F, 'sound/magic/lightningbolt.ogg', 80, 1)

/datum/round_event/portal_storm/proc/spawn_hostile()
	if(!hostile_types || !hostile_types.len)
		return 0
	return IsMultiple(activeFor, 2)

/datum/round_event/portal_storm/proc/spawn_boss()
	if(!boss_types || !boss_types.len)
		return 0

	if(activeFor == next_boss_spawn)
		next_boss_spawn += Ceiling(number_of_hostiles / number_of_bosses)
		return 1

/datum/round_event/portal_storm/proc/time_to_end()
	if(!hostile_types.len && !boss_types.len)
		endWhen = activeFor

	if(!number_of_hostiles && number_of_bosses)
		endWhen = activeFor
