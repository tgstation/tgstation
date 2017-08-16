//gang.dm
//Gang War Game Mode

GLOBAL_LIST_INIT(gang_name_pool, list("Clandestine", "Prima", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Donk", "Gene", "Gib", "Tunnel", "Diablo", "Psyke", "Osiron", "Sirius", "Sleeping Carp"))
GLOBAL_LIST_INIT(gang_colors_pool, list("red","orange","yellow","green","blue","purple", "white"))
GLOBAL_LIST_INIT(gang_outfit_pool, list(/obj/item/clothing/suit/jacket/leather, /obj/item/clothing/suit/jacket/leather/overcoat, /obj/item/clothing/suit/jacket/puffer, /obj/item/clothing/suit/jacket/miljacket, /obj/item/clothing/suit/jacket/puffer, /obj/item/clothing/suit/pirate, /obj/item/clothing/suit/poncho, /obj/item/clothing/suit/apron/overalls, /obj/item/clothing/suit/jacket/letterman))

/datum/game_mode
	var/list/datum/gang/gangs = list()
	var/datum/gang_points/gang_points

/proc/is_gangster(var/mob/living/M)
	return istype(M) && M.mind && M.mind.gang_datum

/proc/is_in_gang(var/mob/living/M, var/gang_type)
	if(!is_gangster(M) || !gang_type)
		return 0
	var/datum/gang/G = M.mind.gang_datum
	if(G.name == gang_type)
		return 1
	return 0

/datum/game_mode/gang
	name = "gang war"
	config_tag = "gang"
	antag_flag = ROLE_GANG
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 20
	required_enemies = 2
	recommended_enemies = 2
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "A violent turf war has erupted on the station!\n\
	<span class='danger'>Gangsters</span>: Take over the station with a dominator.\n\
	<span class='notice'>Crew</span>: Prevent the gangs from expanding and initiating takeover."

///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/gang/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	//Spawn more bosses depending on server population
	var/gangs_to_create = 2
	if(prob(num_players() * 2))
		gangs_to_create ++

	for(var/i=1 to gangs_to_create)
		if(!antag_candidates.len)
			break

		//Create the gang
		var/datum/gang/G = new()
		gangs += G

		//Now assign a boss for the gang
		for(var/n in 1 to 3)
			var/datum/mind/boss = pick(antag_candidates)
			antag_candidates -= boss
			G.bosses[boss] = GANGSTER_BOSS_STARTING_INFLUENCE
			boss.gang_datum = G
			var/title
			if(n == 1)
				title = "Boss"
			else
				title = "Lieutenant"
			boss.special_role = "[G.name] Gang [title]"
			boss.restricted_roles = restricted_jobs
			log_game("[boss.key] has been selected as the [title] for the [G.name] Gang")

	if(gangs.len < 2) //Need at least two gangs
		return 0

	return 1


/datum/game_mode/gang/post_setup()
	set waitfor = FALSE
	..()
	sleep(rand(10,100))
	for(var/datum/gang/G in gangs)
		for(var/datum/mind/boss_mind in G.bosses)
			G.bosses[boss_mind] = GANGSTER_BOSS_STARTING_INFLUENCE			//Force influence to be put on it.
			G.add_gang_hud(boss_mind)
			forge_gang_objectives(boss_mind)
			greet_gang(boss_mind)
			equip_gang(boss_mind.current,G)
			modePlayer += boss_mind


/datum/game_mode/proc/forge_gang_objectives(datum/mind/boss_mind)
	var/datum/objective/rival_obj = new
	rival_obj.owner = boss_mind
	rival_obj.explanation_text = "Be the first gang to successfully takeover the station with a Dominator."
	boss_mind.objectives += rival_obj

/datum/game_mode/proc/greet_gang(datum/mind/boss_mind, you_are=1)
	if (you_are)
		to_chat(boss_mind.current, "<FONT size=3 color=red><B>You are the Boss of the [boss_mind.gang_datum.name] Gang!</B></FONT>")
	boss_mind.announce_objectives()

///////////////////////////////////////////////////////////////////////////
//This equips the bosses with their gear, and makes the clown not clumsy//
///////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_gang(mob/living/carbon/human/mob, gang)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.dna.remove_mutation(CLOWNMUT)

	var/obj/item/device/gangtool/gangtool = new(mob)
	var/obj/item/pen/gang/T = new(mob)
	var/obj/item/toy/crayon/spraycan/gang/SC = new(mob,gang)
	var/obj/item/clothing/glasses/hud/security/chameleon/C = new(mob,gang)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store
	)

	. = 0

	var/where = mob.equip_in_one_of_slots(gangtool, slots)
	if (!where)
		to_chat(mob, "Your Syndicate benefactors were unfortunately unable to get you a Gangtool.")
		. += 1
	else
		gangtool.register_device(mob)
		to_chat(mob, "The <b>Gangtool</b> in your [where] will allow you to purchase weapons and equipment, send messages to your gang, and recall the emergency shuttle from anywhere on the station.")
		to_chat(mob, "As the gang boss, you can also promote your gang members to <b>lieutenant</b>. Unlike regular gangsters, Lieutenants cannot be deconverted and are able to use recruitment pens and gangtools.")

	var/where2 = mob.equip_in_one_of_slots(T, slots)
	if (!where2)
		to_chat(mob, "Your Syndicate benefactors were unfortunately unable to get you a recruitment pen to start.")
		. += 1
	else
		to_chat(mob, "The <b>recruitment pen</b> in your [where2] will help you get your gang started. Stab unsuspecting crew members with it to recruit them.")

	var/where3 = mob.equip_in_one_of_slots(SC, slots)
	if (!where3)
		to_chat(mob, "Your Syndicate benefactors were unfortunately unable to get you a territory spraycan to start.")
		. += 1
	else
		to_chat(mob, "The <b>territory spraycan</b> in your [where3] can be used to claim areas of the station for your gang. The more territory your gang controls, the more influence you get. All gangsters can use these, so distribute them to grow your influence faster.")

	var/where4 = mob.equip_in_one_of_slots(C, slots)
	if (!where4)
		to_chat(mob, "Your Syndicate benefactors were unfortunately unable to get you a chameleon security HUD.")
		. += 1
	else
		to_chat(mob, "The <b>chameleon security HUD</b> in your [where4] will help you keep track of who is mindshield-implanted, and unable to be recruited.")
	return .


///////////////////////////////////////////
//Deals with converting players to a gang//
///////////////////////////////////////////
/datum/game_mode/proc/add_gangster(datum/mind/gangster_mind, datum/gang/G, check = 1)
	if(!G || (gangster_mind in get_all_gangsters()) || (gangster_mind.enslaved_to && !is_gangster(gangster_mind.enslaved_to)))
		if(is_in_gang(gangster_mind.current, G.name) && !(gangster_mind in get_gang_bosses()))
			return 3
		return 0
	if(check && gangster_mind.current.isloyal()) //Check to see if the potential gangster is implanted
		return 1
	G.gangsters[gangster_mind] = GANGSTER_SOLDIER_STARTING_INFLUENCE
	gangster_mind.gang_datum = G
	if(check)
		if(iscarbon(gangster_mind.current))
			var/mob/living/carbon/carbon_mob = gangster_mind.current
			carbon_mob.silent = max(carbon_mob.silent, 5)
			carbon_mob.flash_act(1, 1)
		gangster_mind.current.Stun(100)
	if(G.is_deconvertible)
		to_chat(gangster_mind.current, "<FONT size=3 color=red><B>You are now a member of the [G.name] Gang!</B></FONT>")
		to_chat(gangster_mind.current, "<font color='red'>Help your bosses take over the station by claiming territory with <b>special spraycans</b> only they can provide. Simply spray on any unclaimed area of the station.</font>")
		to_chat(gangster_mind.current, "<font color='red'>Their ultimate objective is to take over the station with a Dominator machine.</font>")
		to_chat(gangster_mind.current, "<font color='red'>You can identify your bosses by their <b>large, bright [G.color] \[G\] icon</b>.</font>")
		gangster_mind.store_memory("You are a member of the [G.name] Gang!")
	gangster_mind.current.log_message("<font color='red'>Has been converted to the [G.name] Gang!</font>", INDIVIDUAL_ATTACK_LOG)
	gangster_mind.special_role = "[G.name] Gangster"

	G.add_gang_hud(gangster_mind)
	if(jobban_isbanned(gangster_mind.current, ROLE_GANG))
		INVOKE_ASYNC(src, /datum/game_mode.proc/replace_jobbaned_player, gangster_mind.current, ROLE_GANG, ROLE_GANG)
	return 2
////////////////////////////////////////////////////////////////////
//Deals with players reverting to neutral (Not a gangster anymore)//
////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_gangster(datum/mind/gangster_mind, beingborged, silent, remove_bosses=0)
	var/datum/gang/gang = gangster_mind.gang_datum
	for(var/obj/O in gangster_mind.current.contents)
		if(istype(O, /obj/item/device/gangtool/soldier))
			qdel(O)

	if(!gang)
		return 0

	var/removed

	for(var/datum/gang/G in gangs)
		if(!G.is_deconvertible && !remove_bosses)
			return 0
		if(gangster_mind in G.gangsters)
			G.reclaim_points(G.gangsters[gangster_mind])
			G.gangsters -= gangster_mind
			removed = 1
		if(remove_bosses && (gangster_mind in G.bosses))
			G.reclaim_points(G.bosses[gangster_mind])
			G.bosses -= gangster_mind
			removed = 1
		if(G.tags_by_mind[gangster_mind] && islist(G.tags_by_mind[gangster_mind]))
			var/list/tags_cache = G.tags_by_mind[gangster_mind]
			for(var/v in tags_cache)
				var/obj/effect/decal/cleanable/crayon/gang/c = v
				c.set_mind_owner(null)
			G.tags_by_mind -= gangster_mind

	if(!removed)
		return 0


	gangster_mind.special_role = null
	gangster_mind.gang_datum = null

	if(silent < 2)
		gangster_mind.current.log_message("<font color='red'>Has reformed and defected from the [gang.name] Gang!</font>", INDIVIDUAL_ATTACK_LOG)

		if(beingborged)
			if(!silent)
				gangster_mind.current.visible_message("The frame beeps contentedly from the MMI before initalizing it.")
			to_chat(gangster_mind.current, "<FONT size=3 color=red><B>The frame's firmware detects and deletes your criminal behavior! You are no longer a gangster!</B></FONT>")
			message_admins("[ADMIN_LOOKUPFLW(gangster_mind.current)] has been borged while being a member of the [gang.name] Gang. They are no longer a gangster.")
		else
			if(!silent)
				gangster_mind.current.Unconscious(100)
				gangster_mind.current.visible_message("<FONT size=3><B>[gangster_mind.current] looks like they've given up the life of crime!<B></font>")
			to_chat(gangster_mind.current, "<FONT size=3 color=red><B>You have been reformed! You are no longer a gangster!</B><BR>You try as hard as you can, but you can't seem to recall any of the identities of your former gangsters...</FONT>")
			gangster_mind.memory = ""

	gang.remove_gang_hud(gangster_mind)
	return 1

////////////////
//Helper Procs//
////////////////

/datum/game_mode/proc/get_all_gangsters()
	var/list/all_gangsters = list()
	all_gangsters += get_gangsters()
	all_gangsters += get_gang_bosses()
	return all_gangsters

/datum/game_mode/proc/get_gangsters()
	var/list/gangsters = list()
	for(var/datum/gang/G in gangs)
		gangsters += G.gangsters
	return gangsters

/datum/game_mode/proc/get_gang_bosses()
	var/list/gang_bosses = list()
	for(var/datum/gang/G in gangs)
		gang_bosses += G.bosses
	return gang_bosses

/datum/game_mode/proc/shuttle_check()
	if(SSshuttle.emergencyNoRecall)
		return
	var/alive = 0
	for(var/mob/living/L in GLOB.player_list)
		if(L.stat != DEAD)
			alive++

	if((alive < (GLOB.joined_player_list.len * 0.4)) && ((SSshuttle.emergency.timeLeft(1) > (SSshuttle.emergencyCallTime * 0.4))))

		SSshuttle.emergencyNoRecall = TRUE
		SSshuttle.emergency.request(null, set_coefficient = 0.4)
		priority_announce("Catastrophic casualties detected: crisis shuttle protocols activated - jamming recall signals across all frequencies.")

/proc/determine_domination_time(var/datum/gang/G)
	return max(180,480 - (round((G.territory.len/GLOB.start_state.num_territories)*100, 1) * 9))


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/auto_declare_completion_gang(datum/gang/winner)
	if(!gangs.len)
		return
	if(!winner)
		to_chat(world, "<span class='redtext'>The station was [station_was_nuked ? "destroyed!" : "evacuated before a gang could claim it! The station wins!"]</span><br>")
		SSticker.mode_result = "loss - gangs failed takeover"

		SSticker.news_report = GANG_LOSS
	else
		to_chat(world, "<span class='redtext'>The [winner.name] Gang successfully performed a hostile takeover of the station!</span><br>")
		SSticker.mode_result = "win - gang domination complete"

		SSticker.news_report = GANG_TAKEOVER

	for(var/datum/gang/G in gangs)
		var/text = "<b>The [G.name] Gang was [winner==G ? "<span class='greenannounce'>victorious</span>" : "<span class='boldannounce'>defeated</span>"] with [round((G.territory.len/GLOB.start_state.num_territories)*100, 1)]% control of the station!</b>"
		text += "<br>The [G.name] Gang Bosses were:"
		for(var/datum/mind/boss in G.bosses)
			text += printplayer(boss, 1)
		text += "<br>The [G.name] Gangsters were:"
		for(var/datum/mind/gangster in G.gangsters)
			text += printplayer(gangster, 1)
		text += "<br>"
		to_chat(world, text)

//////////////////////////////////////////////////////////
//Handles influence, territories, and the victory checks//
//////////////////////////////////////////////////////////

/datum/gang_points
	var/next_point_interval = 1800
	var/next_point_time

/datum/gang_points/New()
	next_point_time = world.time + next_point_interval
	START_PROCESSING(SSobj, src)

/datum/gang_points/process(seconds)
	var/list/winners = list() //stores the winners if there are any

	for(var/datum/gang/G in SSticker.mode.gangs)
		if(world.time > next_point_time)
			G.income()

		if(G.is_dominating)
			if(G.domination_time_remaining() < 0)
				winners += G

	if(world.time > next_point_time)
		next_point_time = world.time + next_point_interval

	if(winners.len)
		if(winners.len > 1) //Edge Case: If more than one dominator complete at the same time
			for(var/datum/gang/G in winners)
				G.domination(0.5)
			priority_announce("Multiple station takeover attempts have made simultaneously. Conflicting takeover attempts appears to have restarted.","Network Alert")
		else
			var/datum/gang/G = winners[1]
			G.is_dominating = FALSE
			SSticker.mode.explosion_in_progress = 1
			SSticker.station_explosion_cinematic(1,"gang war", null)
			SSticker.mode.explosion_in_progress = 0
			SSticker.force_ending = TRUE

