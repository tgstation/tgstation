/datum/game_mode/gang
	name = "Families"
	config_tag = "families"
	antag_flag = ROLE_TRAITOR
	false_report_weight = 5
	required_players = 30
	required_enemies = 3
	recommended_enemies = 3
	announce_span = "danger"
	announce_text = "Grove For Lyfe!"
	reroll_friendly = FALSE
	var/check_counter = 0
	var/endtime = null
	var/fuckingdone = FALSE
	var/time_to_end = 30 MINUTES
	var/gangs_to_generate = 3
	var/list/gangs_to_use
	var/list/datum/mind/gangbangers = list()
	var/list/gangs = list()
	var/gangs_still_alive = 0
	var/sent_announcement = FALSE
	var/list/gang_locations = list()
	var/gang_balance_cap = 5

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

		gangbanger.add_antag_datum(new_gangster)
		to_chat(gangbanger.current, "<B>As you're the first gangster, a gang signup point will spawn on your location in 2 minutes. Be prepared!</B>")
		to_chat(gangbanger.current, "<B><font size=3 color=red>Be sure to be in a public place! Your Signup Point is invincible, and you want to attract as many signups as possible.</font></B>")
		addtimer(CALLBACK(src, .proc/spawn_gang_point, new_gangster), 2 MINUTES)
	addtimer(CALLBACK(src, .proc/announce_gang_locations), 130 SECONDS)
	addtimer(CALLBACK(src, .proc/five_minute_warning), 25 MINUTES)
	gamemode_ready = TRUE
	SSshuttle.registerHostileEnvironment(src)
	..()

/datum/game_mode/gang/proc/spawn_gang_point(var/datum/antagonist/gang/new_gangster)
	if(new_gangster.owner && new_gangster.owner.current)
		to_chat(new_gangster.owner.current, "Your Gang Sigunp Point has been teleported into your location.<br>Encourage people to sign up with it!<br>You can use drugs/guns on the signup point to export them to the black market for Gang Points.<br>You've also been supplied with a free set of your gang's clothing.")
		var/obj/gang_signup_point/signup_point = new /obj/gang_signup_point(get_turf(new_gangster.owner.current))
		signup_point.name = "[new_gangster.name] Signup Point"
		signup_point.gang_to_use = new_gangster.type
		signup_point.team_to_use = new_gangster.get_team()
		signup_point.icon_state = "[new_gangster.gang_id]_gang_point"
		var/area/A = get_area(new_gangster.owner.current)
		gang_locations += list(signup_point.team_to_use.name = A.name)
		for(var/threads in new_gangster.free_clothes)
			new threads(get_turf(new_gangster.owner.current))

/datum/game_mode/gang/proc/announce_gang_locations()
	var/list/readable_gang_names = list()
	for(var/datum/team/gang/G in gangs)
		var/area_with_spawner = gang_locations[G.name]
		readable_gang_names += "[G.name] in the [area_with_spawner]"
	var/finalized_gang_names = english_list(readable_gang_names)
	priority_announce("Julio G coming to you live from Radio Los Spess! We've been hearing reports of gang activity on [station_name()], with the [finalized_gang_names] duking it out, looking for fresh territory and drugs to sling! Stay safe out there for the thirty minutes 'till the space cops get there, and keep it cool, yeah? Play music, not gunshots, I say. Peace out!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')


/datum/game_mode/gang/proc/five_minute_warning()
	priority_announce("Julio G coming to you live from Radio Los Spess! The space cops are closing in on [station_name()] and will arrive in about 5 minutes! Better clear on out of there if you don't want to get hurt!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')

/datum/game_mode/gang/check_win()
	for(var/datum/team/gang in gangs)
		if(gang.members.len)
			gangs_still_alive = 1
			SSticker.mode_result = "win - gangs survived"
			SSticker.news_report = GANG_OPERATING
			return gangs_still_alive
	SSticker.mode_result = "loss - gangs destroyed"
	SSticker.news_report = GANG_DESTROYED
	gangs_still_alive = 0

/datum/game_mode/gang/check_finished()
	if(fuckingdone)
		return TRUE
	else
		return ..()

/datum/game_mode/gang/process()
	check_counter++
	if(check_counter >= 5)
		if (world.time > endtime && !fuckingdone)
			fuckingdone = TRUE
		check_counter = 0
		SSticker.mode.check_win()

		check_tagged_turfs()
		check_gang_clothes()
		check_rollin_with_crews()
		// if we had an easy way to source what came from who, I'd add points for getting people addicted to drugs.


/datum/game_mode/gang/proc/check_tagged_turfs()
	for(var/obj/effect/decal/cleanable/crayon/gang/tag in GLOB.gang_tags)
		if(tag.my_gang)
			tag.my_gang.adjust_points(50)
		CHECK_TICK

/datum/game_mode/gang/proc/check_gang_clothes() // TODO: make this grab the sprite itself, average out what the primary color would be, then compare how close it is to the gang color so I don't have to manually fill shit out for 5 years for every gang type
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind)
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
			if(H.stat)
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
	report += "<span class='header'>The gangs in the round were:</span>"
	for(var/datum/team/gang/G in gangs)
		report += "<span class='header'>[G.name]:</span>"
		report += "The gangsters were:"
		report += printplayerlist(G.members)
		report += "<span class='header'>Points: [G.points]</span>"
		if(G.points >= highest_point_value)
			highest_point_value = G.points
			highest_gang = G.name
	report += "<span class='header greentext'>[highest_gang] won the round!</span>"
	return "<div class='panel redborder'>[report.Join("<br>")]</div>"