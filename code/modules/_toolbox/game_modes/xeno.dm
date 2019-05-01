#define ALIENS_WIN 25

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

	var/mob/living/carbon/alien/humanoid/royal/queen/queen = null // Teh Qeen

	var/digital_camo_time = 9000 //aliens have digital camo for 15 minutes
	var/digital_camo_timer = 0

	var/start_time = 0
	var/alien_victory_timer = 40 //how many minutes in to the round untill aliens can win

	var/list/important_jobs = list("Warden", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer") //All of these jobs must be dead in order to gain victory for the aliens

	var/Ayys_win = 0

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
		var/datum/mind/alien = pick_n_take(antag_candidates)
		alien.assigned_role = ROLE_ALIEN
		alien.special_role = ROLE_ALIEN
		log_game("[alien.key] (ckey) has been selected as an alien larva")

	return num_aliens

/datum/game_mode/ayylmaos/post_setup()
	src.start_time = world.time
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
	for(var/mob/living/M in GLOB.mob_list)
		if(istype(M,/mob/living/carbon/alien))
			continue
		if(M.ckey && M.mind && M.mind.assigned_role == ROLE_ALIEN)
			the_aliens += spawn_the_alien(M)
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
			if(A.digitalcamo || A.digitalinvis)
				to_chat(A,"Your digital camo fades.")
		digital_camo_timer = 0
	if(queen)
		if(!istype(queen,/mob/living/carbon/alien/humanoid/royal/queen) || !queen.client || QDELETED(queen) || !queen.loc || queen.stat == DEAD)
			SSshuttle.clearHostileEnvironment(queen)
			queen = null
	if(!queen)
		for(var/mob/living/carbon/alien/humanoid/royal/queen/Q in SSshuttle.hostileEnvironments)
			SSshuttle.clearHostileEnvironment(Q)

/datum/game_mode/ayylmaos/check_finished()
	var/alien_count = 0
	var/living_count = 0
	var/list/important_jobs_still_active = list()
	for(var/mob/living/M in GLOB.player_list)
		if(!M.client || !istype(M,/mob/living) || M.stat == DEAD || QDELETED(M) || !M.loc )
			continue
		else if(istype(M,/mob/living/carbon/alien/humanoid))
			if(istype(M,/mob/living/carbon/alien/humanoid/royal/queen) && !queen)
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z))
					queen = M
					SSshuttle.registerHostileEnvironment(queen)
			alien_count++
		else if((M.mind && M.mind in GLOB.Original_Minds) && (istype(M,/mob/living/carbon/human)))
			if(M.client && (M.mind.assigned_role in src.important_jobs))
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z))
					important_jobs_still_active += M.mind
			living_count++
	if(world.time+src.start_time >= ((alien_victory_timer*60)*10))
		var/threshold = round(alien_count*0.7,1)
		if((queen) && (living_count <= threshold) && (!important_jobs_still_active.len))
			if(!Ayys_win)
				for(var/client/C in GLOB.admins)
					spawn(0)
						C << sound('sound/misc/notice2.ogg',0,0,0,50)
						sleep(5)
						C << sound('sound/misc/notice2.ogg',0,0,0,50)
						sleep(5)
						C << sound('sound/misc/notice2.ogg',0,0,0,50)
				message_admins("DEBUG: The xenomorph game mode has completed. living_count = \"[living_count]\", alien_count = \"[alien_count]\", threshold = \"[threshold]\"")
				message_admins("DEBUG: Click <A href='?src=[REF(src)];debugfinish=1'>Here</A> call proc /proc/end_xeno_round to end the round.")
				Ayys_win = 1
	if(Ayys_win == 2)
		return TRUE
	return ..()

/datum/game_mode/ayylmaos/Topic(href, href_list)
	..()
	if(href_list["debugfinish"])
		var/thechoice = alert(usr,"This will end the round. Are you sure?","End Xenomorph Gamoemode","Yes","No")
		if(thechoice == "Yes")
			Ayys_win = 2

/datum/game_mode/ayylmaos/set_round_result()
	..()
	if(Ayys_win)
		SSticker.mode_result = "Alien Victory"
		SSticker.news_report = ALIENS_WIN

/datum/game_mode/ayylmaos/special_report()
	if(Ayys_win)
		return "<span class='redtext big'>The Aliens have taken over the station!</span>"
	else
		return "<span class='greentext big'>The crew managed to stop the Aliens from taking over the station.</span>"

/datum/game_mode/ayylmaos/generate_report()
	return "An alien infestation has been detected on the station. The crew will to have arm themselves and seek out and destroy the aliens. Remember to wear head protection to protect against facehuggers. Medical staff may have to remove alien parasites surgically. The ultimate goal is to destroy the Alien Queen."

/datum/game_mode/ayylmaos/proc/spawn_the_alien(mob/M)
	if(istype(M) && M.ckey)
		var/mob/living/carbon/alien/larva/L = new()
		L.sync_mind()
		if(digital_camo_timer > world.time)
			L.digitalcamo = 1
			L.digitalinvis = 1
		L.ckey = M.ckey
		qdel(M)
		return L
	return null