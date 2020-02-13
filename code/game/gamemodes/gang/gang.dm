#define LOWPOP_FAMILIES_COUNT 50

#define TWO_STARS_HIGHPOP 11
#define THREE_STARS_HIGHPOP 16
#define FOUR_STARS_HIGHPOP 21
#define FIVE_STARS_HIGHPOP 31

#define TWO_STARS_LOW 6
#define THREE_STARS_LOW 9
#define FOUR_STARS_LOW 12
#define FIVE_STARS_LOW 15


GLOBAL_VAR_INIT(deaths_during_shift, 0)
/datum/game_mode/gang
	name = "Families"
	config_tag = "families"
	antag_flag = ROLE_TRAITOR
	false_report_weight = 5
	required_players = 0
	required_enemies = 1
	recommended_enemies = 3
	announce_span = "danger"
	announce_text = "Grove For Lyfe!"
	reroll_friendly = FALSE
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Prisoner","Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	var/check_counter = 0
	var/endtime = null
	var/fuckingdone = FALSE
	var/time_to_end = 60 MINUTES
	var/gangs_to_generate = 3
	var/list/gangs_to_use
	var/list/datum/mind/gangbangers = list()
	var/list/datum/mind/pigs = list()
	var/list/gangs = list()
	var/gangs_still_alive = 0
	var/sent_announcement = FALSE
	var/list/gang_locations = list()
	var/lock_stars = FALSE
	var/cops_arrived = FALSE
	var/gang_balance_cap = 3
	var/current_stars = "wanted_0"

/datum/game_mode/gang/pre_setup()
	gangs_to_use = subtypesof(/datum/antagonist/gang)
	for(var/j = 0, j < gangs_to_generate, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/gangbanger = antag_pick(antag_candidates)
		gangbangers += gangbanger
		log_game("[key_name(gangbanger)] has been selected as a starting gangster!")
		antag_candidates.Remove(gangbanger)
	endtime = world.time + time_to_end
	return TRUE

/datum/game_mode/gang/post_setup()
	for(var/datum/mind/gangbanger in gangbangers)
		var/gang_to_use = pick_n_take(gangs_to_use)
		var/datum/antagonist/gang/new_gangster = new gang_to_use()
		var/datum/team/gang/ballas = new /datum/team/gang()
		new_gangster.my_gang = ballas
		gangs += ballas
		ballas.add_member(gangbanger)
		ballas.name = new_gangster.gang_name

		ballas.acceptable_clothes = new_gangster.acceptable_clothes.Copy()
		ballas.free_clothes = new_gangster.free_clothes.Copy()

		for(var/C in ballas.free_clothes)
			var/obj/O = new C(gangbanger.current)
			var/list/slots = list (
				"backpack" = ITEM_SLOT_BACKPACK,
				"left pocket" = ITEM_SLOT_LPOCKET,
				"right pocket" = ITEM_SLOT_RPOCKET
			)
			var/mob/living/carbon/human/H = gangbanger.current
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(gangbanger.current, "Unfortunately, you could not bring your [O] to this shift. You will need to find one.")
				qdel(O)

		gangbanger.add_antag_datum(new_gangster)
		gangbanger.current.playsound_local(get_turf(gangbanger.current), 'sound/ambience/antag/thatshowfamiliesworks.ogg', 100, FALSE, pressure_affected = FALSE)
		to_chat(gangbanger.current, "<B>As you're the first gangster, your uniform and spraycan are in your inventory!</B>")
	addtimer(CALLBACK(src, .proc/announce_gang_locations), 5 MINUTES)
	addtimer(CALLBACK(src, .proc/five_minute_warning), time_to_end - 5 MINUTES)
	gamemode_ready = TRUE
	SSshuttle.registerHostileEnvironment(src)
	..()

/datum/game_mode/gang/proc/announce_gang_locations()
	var/list/readable_gang_names = list()
	for(var/datum/team/gang/G in gangs)
		readable_gang_names += "[G.name]"
	var/finalized_gang_names = english_list(readable_gang_names)
	priority_announce("Julio G coming to you live from Radio Los Spess! We've been hearing reports of gang activity on [station_name()], with the [finalized_gang_names] duking it out, looking for fresh territory and drugs to sling! Stay safe out there for the hour 'till the space cops get there, and keep it cool, yeah? Play music, not gunshots, I say. Peace out!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')
	sent_announcement = TRUE

/datum/game_mode/gang/proc/five_minute_warning()
	priority_announce("Julio G coming to you live from Radio Los Spess! The space cops are closing in on [station_name()] and will arrive in about 5 minutes! Better clear on out of there if you don't want to get hurt!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')

/datum/game_mode/gang/check_win()
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/datum/mind/gangbanger in gangbangers)
		if(gangbanger.current)
			if(!ishuman(gangbanger.current))
				continue
			var/mob/living/carbon/human/H = gangbanger.current
			if(H.stat)
				continue
			alive_gangsters++
	for(var/datum/mind/bacon in pigs)
		if(bacon.current)
			if(!ishuman(bacon.current)) // always returns false
				continue
			var/mob/living/carbon/human/H = bacon.current
			if(H.stat)
				continue
			alive_cops++
	if(alive_gangsters > alive_cops)
		SSticker.mode_result = "win - gangs survived"
		SSticker.news_report = GANG_OPERATING
		return TRUE
	else
		SSticker.mode_result = "loss - police destroyed the gangs"
		SSticker.news_report = GANG_DESTROYED
		return FALSE

/datum/game_mode/gang/process()
	if(sent_announcement)
		for(var/mob/M in GLOB.mob_list)
			if(M.client)
				if(M.hud_used)
					var/datum/hud/H = M.hud_used
					var/icon_state_to_use = "wanted_1"
					if(lock_stars)
						H.wanted_lvl.icon_state = current_stars
					else
						if(GLOB.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
							switch(GLOB.deaths_during_shift)
								if(0 to TWO_STARS_HIGHPOP-1)
									icon_state_to_use = "wanted_1"
								if(TWO_STARS_HIGHPOP to THREE_STARS_HIGHPOP-1)
									icon_state_to_use = "wanted_2"
								if(THREE_STARS_HIGHPOP to FOUR_STARS_HIGHPOP-1)
									icon_state_to_use = "wanted_3"
								if(FOUR_STARS_HIGHPOP to FIVE_STARS_HIGHPOP-1)
									icon_state_to_use = "wanted_4"
								if(FIVE_STARS_HIGHPOP to INFINITY)
									icon_state_to_use = "wanted_5"
						else
							switch(GLOB.deaths_during_shift)
								if(0 to TWO_STARS_LOW-1)
									icon_state_to_use = "wanted_1"
								if(TWO_STARS_LOW to THREE_STARS_LOW-1)
									icon_state_to_use = "wanted_2"
								if(THREE_STARS_LOW to FOUR_STARS_LOW-1)
									icon_state_to_use = "wanted_3"
								if(FOUR_STARS_LOW to FIVE_STARS_LOW-1)
									icon_state_to_use = "wanted_4"
								if(FIVE_STARS_LOW to INFINITY)
									icon_state_to_use = "wanted_5"
						if(cops_arrived)
							icon_state_to_use += "_active"
							lock_stars = TRUE
						current_stars = icon_state_to_use
						H.wanted_lvl.icon_state = icon_state_to_use

	check_counter++
	if(check_counter >= 5)
		if (world.time > endtime && !fuckingdone)
			fuckingdone = TRUE
			send_in_the_fuzz()
		check_counter = 0
		SSticker.mode.check_win()

		check_tagged_turfs()
		check_gang_clothes()
		check_rollin_with_crews()

/datum/game_mode/gang/proc/send_in_the_fuzz()
	var/team_size
	var/cops_to_send
	if(GLOB.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		switch(GLOB.deaths_during_shift)
			if(0 to TWO_STARS_HIGHPOP-1)
				team_size = 8
				cops_to_send = /datum/antagonist/ert/families/beatcop
			if(TWO_STARS_HIGHPOP to THREE_STARS_HIGHPOP-1)
				team_size = 9
				cops_to_send = /datum/antagonist/ert/families/beatcop/armored
			if(THREE_STARS_HIGHPOP to FOUR_STARS_HIGHPOP-1)
				team_size = 10
				cops_to_send = /datum/antagonist/ert/families/beatcop/swat
			if(FOUR_STARS_HIGHPOP to FIVE_STARS_HIGHPOP-1)
				team_size = 11
				cops_to_send = /datum/antagonist/ert/families/beatcop/fbi
			if(FIVE_STARS_HIGHPOP to INFINITY)
				team_size = 12
				cops_to_send = /datum/antagonist/ert/families/beatcop/military
	else
		switch(GLOB.deaths_during_shift)
			if(0 to TWO_STARS_LOW-1)
				team_size = 5
				cops_to_send = /datum/antagonist/ert/families/beatcop
			if(TWO_STARS_LOW to THREE_STARS_LOW-1)
				team_size = 6
				cops_to_send = /datum/antagonist/ert/families/beatcop/armored
			if(THREE_STARS_LOW to FOUR_STARS_LOW-1)
				team_size = 7
				cops_to_send = /datum/antagonist/ert/families/beatcop/swat
			if(FOUR_STARS_LOW to FIVE_STARS_LOW-1)
				team_size = 8
				cops_to_send = /datum/antagonist/ert/families/beatcop/fbi
			if(FIVE_STARS_LOW to INFINITY)
				team_size = 10
				cops_to_send = /datum/antagonist/ert/families/beatcop/military

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to help clean up crime on this station?", "deathsquad", null)

	if(candidates.len > 0)
		//Pick the (un)lucky players
		var/numagents = min(team_size,candidates.len)

		var/list/spawnpoints = GLOB.emergencyresponseteamspawn
		var/index = 0
		while(numagents && candidates.len)
			var/spawnloc = spawnpoints[index+1]
			//loop through spawnpoints one at a time
			index = (index + 1) % spawnpoints.len
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/cop = new(spawnloc)
			chosen_candidate.client.prefs.copy_to(cop)
			cop.key = chosen_candidate.key

			//Give antag datum
			var/datum/antagonist/ert/ert_antag = new cops_to_send

			cop.mind.add_antag_datum(ert_antag)
			cop.mind.assigned_role = ert_antag.name
			SSjob.SendToLateJoin(cop)

			//Logging and cleanup
			log_game("[key_name(cop)] has been selected as an [ert_antag.name]")
			numagents--
		cops_arrived = TRUE
		addtimer(CALLBACK(src, .proc/end_hostile_sit), 10 MINUTES)
		return TRUE
	else
		cops_arrived = TRUE
		addtimer(CALLBACK(src, .proc/end_hostile_sit), 10 MINUTES)
		return FALSE

/datum/game_mode/gang/proc/end_hostile_sit()
	SSshuttle.clearHostileEnvironment(src)

/datum/game_mode/gang/proc/check_tagged_turfs()
	for(var/obj/effect/decal/cleanable/crayon/gang/tag in GLOB.gang_tags)
		if(tag.my_gang)
			tag.my_gang.adjust_points(50)
		CHECK_TICK

/datum/game_mode/gang/proc/check_gang_clothes() // TODO: make this grab the sprite itself, average out what the primary color would be, then compare how close it is to the gang color so I don't have to manually fill shit out for 5 years for every gang type
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind || !H.client)
			continue
		var/datum/antagonist/gang/is_gangster = H.mind.has_antag_datum(/datum/antagonist/gang)
		for(var/clothing in list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.back, H.gloves, H.shoes, H.belt, H.s_store, H.glasses, H.ears, H.wear_id))
			if(is_gangster)
				if(is_type_in_list(clothing, is_gangster.acceptable_clothes))
					is_gangster.add_gang_points(10)
			else
				for(var/datum/team/gang/gang_clothes in gangs)
					if(is_type_in_list(clothing, gang_clothes.acceptable_clothes))
						gang_clothes.adjust_points(5)

		CHECK_TICK

/datum/game_mode/gang/proc/check_rollin_with_crews()
	for(var/area/A in GLOB.sortedAreas)
		var/list/gang_members = list()
		for(var/mob/living/carbon/human/H in A)
			if(H.stat || !H.mind || !H.client)
				continue
			var/datum/antagonist/gang/is_gangster = H.mind.has_antag_datum(/datum/antagonist/gang)
			if(is_gangster)
				gang_members[is_gangster.my_gang]++
			CHECK_TICK
		if(gang_members.len)
			for(var/datum/team/gang/gangsters in gang_members)
				if(gang_members[gangsters] >= 4)
					if(gang_members[gangsters] >= 8)
						gangsters.adjust_points(5) // Discourage larger clumps, spread ur people out
					else
						gangsters.adjust_points(10)


/datum/game_mode/gang/generate_report()
	return "Something something grove street home at least until I fucked everything up idk nobody reads these reports."

/datum/game_mode/gang/send_intercept(report = 0)
	return

/datum/game_mode/gang/special_report()
	var/list/report = list()
	var/highest_point_value = 0
	var/highest_gang = "Leet Like Jeff K"
	report += "<span class='header'>The families in the round were:</span>"
	for(var/datum/team/gang/G in gangs)
		report += "<span class='header'>[G.name]:</span>"
		if(G.members.len)
			report += "The gangsters were:"
			report += printplayerlist(G.members)
			report += "<span class='header'>Points: [G.points]</span>"
		else
			report += "<span class='redtext'>The family was wiped out!</span>"
		if(G.points >= highest_point_value && G.members.len)
			highest_point_value = G.points
			highest_gang = G.name
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/datum/mind/gangbanger in gangbangers)
		if(gangbanger.current)
			if(!ishuman(gangbanger.current))
				continue
			var/mob/living/carbon/human/H = gangbanger.current
			if(H.stat)
				continue
			alive_gangsters++
	for(var/datum/mind/bacon in pigs)
		if(bacon.current)
			if(!ishuman(bacon.current)) // always returns false
				continue
			var/mob/living/carbon/human/H = bacon.current
			if(H.stat)
				continue
			alive_cops++
	if(alive_gangsters > alive_cops)
		report += "<span class='header greentext'>[highest_gang] won the round!</span>"
	else if(alive_gangsters == alive_cops)
		report += "<span class='header redtext'>Legend has it the police and the families are still duking it out to this day!</span>"
	else
		report += "<span class='header greentext'>The police put the boots to the families, medium style!</span>"


	return "<div class='panel redborder'>[report.Join("<br>")]</div>"
