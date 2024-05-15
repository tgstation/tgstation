/datum/round_event_control/portal_storm_syndicate
	name = "Portal Storm: Syndicate Shocktroops"
	typepath = /datum/round_event/portal_storm/syndicate_shocktroop
	weight = 2
	min_players = 15
	earliest_start = 30 MINUTES
	category = EVENT_CATEGORY_ENTITIES
	description = "Syndicate troops pour out of portals."

/datum/round_event/portal_storm/syndicate_shocktroop
	boss_types = list(/mob/living/basic/trooper/syndicate/melee/space/stormtrooper = 2)
	hostile_types = list(
		/mob/living/basic/trooper/syndicate/melee/space = 8,
		/mob/living/basic/trooper/syndicate/ranged/space = 2,
	)

/datum/round_event_control/portal_storm_narsie
	name = "Portal Storm: Constructs"
	typepath = /datum/round_event/portal_storm/portal_storm_narsie
	weight = 0
	max_occurrences = 0
	category = EVENT_CATEGORY_ENTITIES
	description = "Nar'sie constructs pour out of portals."
	min_wizard_trigger_potency = 5
	max_wizard_trigger_potency = 7

/datum/round_event/portal_storm/portal_storm_narsie
	boss_types = list(/mob/living/basic/construct/artificer/hostile = 6)
	hostile_types = list(
		/mob/living/basic/construct/juggernaut/hostile = 8,
		/mob/living/basic/construct/wraith/hostile = 6,
	)

/datum/round_event/portal_storm
	start_when = 7
	end_when = 999
	announce_when = 1

	var/list/boss_spawn = list()
	var/list/boss_types = list() //only configure this if you have hostiles
	var/number_of_bosses
	var/next_boss_spawn
	var/list/hostiles_spawn = list()
	var/list/hostile_types = list()
	var/number_of_hostiles
	/// List of mutable appearances in the form (plane offset + 1 -> appearance)
	var/list/mutable_appearance/storm_appearances

/datum/round_event/portal_storm/setup()
	storm_appearances = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		var/mutable_appearance/storm = mutable_appearance('icons/obj/machines/engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
		SET_PLANE_W_SCALAR(storm, ABOVE_GAME_PLANE, offset)
		storm.color = COLOR_VIBRANT_LIME
		storm_appearances += storm

	number_of_bosses = 0
	for(var/boss in boss_types)
		number_of_bosses += boss_types[boss]

	number_of_hostiles = 0
	for(var/hostile in hostile_types)
		number_of_hostiles += hostile_types[hostile]

	while(number_of_bosses > boss_spawn.len)
		boss_spawn += get_random_station_turf()

	while(number_of_hostiles > hostiles_spawn.len)
		hostiles_spawn += get_random_station_turf()

	next_boss_spawn = start_when + CEILING(2 * number_of_hostiles / number_of_bosses, 1)

/datum/round_event/portal_storm/announce(fake)
	set waitfor = 0
	sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
	sleep(8 SECONDS)
	priority_announce("Massive bluespace anomaly detected en route to [station_name()]. Brace for impact.")
	sleep(2 SECONDS)
	sound_to_playing_players('sound/magic/lightningbolt.ogg')

/datum/round_event/portal_storm/tick()
	spawn_effects(get_random_station_turf())

	if(spawn_hostile() && length(hostile_types))
		var/type = pick(hostile_types)
		hostile_types[type] = hostile_types[type] - 1
		spawn_mob(type, hostiles_spawn)
		if(!hostile_types[type])
			hostile_types -= type

	if(spawn_boss() && length(boss_types))
		var/type = pick(boss_types)
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
	if(!T)
		log_game("Portal Storm failed to spawn effect due to an invalid location.")
		return
	T = get_step(T, SOUTHWEST) //align center of image with turf
	T.flick_overlay_static(storm_appearances[GET_TURF_PLANE_OFFSET(T) + 1], 15)
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), TRUE)

/datum/round_event/portal_storm/proc/spawn_hostile()
	if(!hostile_types || !hostile_types.len)
		return 0
	return ISMULTIPLE(activeFor, 2)

/datum/round_event/portal_storm/proc/spawn_boss()
	if(!boss_types || !boss_types.len)
		return FALSE

	if(activeFor == next_boss_spawn)
		next_boss_spawn += CEILING(number_of_hostiles / number_of_bosses, 1)
		return TRUE
	return FALSE

/datum/round_event/portal_storm/proc/time_to_end()
	if(!hostile_types.len && !boss_types.len)
		end_when = activeFor

	if(!number_of_hostiles && number_of_bosses)
		end_when = activeFor
