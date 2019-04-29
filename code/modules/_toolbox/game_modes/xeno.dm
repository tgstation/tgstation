/datum/game_mode/ayylmaos
	name = "xenomorphs"
	config_tag = "aliens"
	antag_flag = ROLE_ALIEN
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 18
	required_enemies = 1
	recommended_enemies = 2
	var/maximum_enmies = 3
	minimum_enemies = 1

	announce_span = "green"
	announce_text = "The station is infested with Xenomorphs!\n\
	<span class='green'>Xenomorphs</span>: Take control of the station.\n\
	<span class='notice'>Crew</span>: Exterminate all alien life."

	var/list/starter_aliens = list()
	var/digital_camo_time = 6000 //aliens have digital camo for 10 minutes
	var/digital_camo_timer = 0

/datum/game_mode/ayylmaos/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/num_aliens = 0
	if(antag_candidates.len)
		num_aliens = min(rand(recommended_enemies,maximum_enmies),antag_candidates.len)


	for(var/j = 0, j < num_aliens, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/alien = antag_pick(antag_candidates)
		alien.assigned_role = ROLE_ALIEN
		alien.special_role = ROLE_ALIEN
		starter_aliens += alien
		log_game("[alien.key] (ckey) has been selected as an alien larva")

	return num_aliens

/datum/game_mode/ayylmaos/post_setup()
	var/list/safe_vents = list()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(temp_vent_parent.other_atmosmch.len > 20)
				var/too_close = 0
				for(var/mob/living/M in GLOB.player_list)
					if(M.mind && M.mind.assigned_role != ROLE_ALIEN && get_dist(temp_vent,M) <= 15)
						too_close = 1
						break
				if(too_close)
					safe_vents += temp_vent
				vents += temp_vent
	digital_camo_timer = world.time+digital_camo_time
	var/list/the_aliens = list()
	for(var/i=1,i<=starter_aliens.len,i++)
		var/datum/mind/alien = pick(starter_aliens)
		starter_aliens -= alien
		the_aliens += spawn_the_alien(alien)
	var/list/chosen_vents = list()
	for(var/i=1,i<=the_aliens.len,i++)
		var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent
		if(safe_vents.len)
			temp_vent = pick(safe_vents)
			safe_vents -= temp_vent
			vents -= temp_vent
		else if(vents.len)
			temp_vent = pick(vents)
			vents -= temp_vent
		if(temp_vent)
			chosen_vents += temp_vent
	if(chosen_vents.len >= the_aliens.len)
		for(var/mob/living/carbon/alien/larva/L in the_aliens)
			var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent = pick(chosen_vents)
			chosen_vents -= temp_vent
			L.forceMove(temp_vent.loc)
	else
		for(var/mob/living/carbon/alien/larva/L in the_aliens)
			var/turf/T = find_safe_turf(SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
			if(T)
				L.forceMove(T)

/datum/game_mode/ayylmaos/process()
	if(digital_camo_timer && digital_camo_timer <= world.time)
		for(var/mob/living/carbon/alien/A in GLOB.mob_list)
			A.digitalcamo = initial(A.digitalcamo)
			A.digitalinvis = initial(A.digitalinvis)
		digital_camo_timer = 0

/datum/game_mode/ayylmaos/proc/spawn_the_alien(datum/mind/alien)
	if(istype(alien) && alien.current)
		var/mob/living/M = alien.current
		var/theckey = M.ckey
		M.mind = null
		qdel(M.mind)
		var/mob/living/carbon/alien/larva/L = new()
		if(digital_camo_timer > world.time)
			L.digitalcamo = 1
			L.digitalinvis = 1
		L.ckey = theckey
		qdel(M)
		return L
	return null