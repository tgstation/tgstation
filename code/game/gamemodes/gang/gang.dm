//gang.dm
//Gang War Game Mode

var/list/gang_name_pool = list("Clandestine", "Prima", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Donk", "Gene", "Gib", "Tunnel", "Diablo", "Psyke", "Osiron", "Sirius", "Sleeping Carp")
var/list/gang_colors_pool = list("red","orange","yellow","green","blue","purple")

/datum/game_mode
	var/list/datum/gang/gangs = list()
	var/datum/gang_points/gang_points


/datum/game_mode/gang
	name = "gang war"
	config_tag = "gang"
	antag_flag = BE_GANG
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 20
	required_enemies = 2
	recommended_enemies = 2
	enemy_minimum_age = 14

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/gang/announce()
	world << "<B>The current game mode is - Gang War!</B>"
	world << "<B>A violent turf war has erupted on the station!<BR>Gangsters -  Take over the station by activating and defending a Dominator! <BR>Crew - The gangs will try to keep you on the station. Successfully evacuate the station to win!</B>"


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
		var/datum/mind/boss = pick(antag_candidates)
		antag_candidates -= boss
		G.bosses += boss
		boss.gang_datum = G
		boss.special_role = "[G.name] Gang Boss"
		boss.restricted_roles = restricted_jobs
		log_game("[boss.key] has been selected as the Boss for the [G.name] Gang")

	if(gangs.len < 2) //Need at least two gangs
		return 0

	return 1


/datum/game_mode/gang/post_setup()
	spawn(rand(10,100))
		for(var/datum/gang/G in gangs)
			for(var/datum/mind/boss_mind in G.bosses)
				G.add_gang_hud(boss_mind)
				forge_gang_objectives(boss_mind)
				greet_gang(boss_mind)
				equip_gang(boss_mind.current,G)
				modePlayer += boss_mind
	..()


/datum/game_mode/proc/forge_gang_objectives(datum/mind/boss_mind)
	var/datum/objective/rival_obj = new
	rival_obj.owner = boss_mind
	rival_obj.explanation_text = "Be the first gang to successfully takeover the station with a Dominator."
	boss_mind.objectives += rival_obj

/datum/game_mode/proc/greet_gang(datum/mind/boss_mind, you_are=1)
	var/obj_count = 1
	if (you_are)
		boss_mind.current << "<FONT size=3 color=red><B>You are the Boss of the [boss_mind.gang_datum.name] Gang!</B></FONT>"
	for(var/datum/objective/objective in boss_mind.objectives)
		boss_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

///////////////////////////////////////////////////////////////////////////
//This equips the bosses with their gear, and makes the clown not clumsy//
///////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_gang(mob/living/carbon/human/mob, gang)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.dna.remove_mutation(CLOWNMUT)

	var/obj/item/device/gangtool/gangtool = new(mob)
	var/obj/item/weapon/pen/gang/T = new(mob)
	var/obj/item/toy/crayon/spraycan/gang/SC = new(mob,gang)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	. = 0

	var/where = mob.equip_in_one_of_slots(gangtool, slots)
	if (!where)
		mob << "Your Syndicate benefactors were unfortunately unable to get you a Gangtool."
		. += 1
	else
		gangtool.register_device(mob)
		mob << "The <b>Gangtool</b> in your [where] will allow you to purchase weapons and equipment, send messages to your gang, and recall the emergency shuttle from anywhere on the station."
		mob << "As the gang boss, you can also promote your gang members to <b>lieutenant</b>. Unlike regular gangsters, Lieutenants cannot be deconverted and are able to use recruitment pens and gangtools."

	var/where2 = mob.equip_in_one_of_slots(T, slots)
	if (!where2)
		mob << "Your Syndicate benefactors were unfortunately unable to get you a recruitment pen to start."
		. += 1
	else
		mob << "The <b>recruitment pen</b> in your [where2] will help you get your gang started. Stab unsuspecting crew members with it to recruit them."

	var/where3 = mob.equip_in_one_of_slots(SC, slots)
	if (!where3)
		mob << "Your Syndicate benefactors were unfortunately unable to get you a territory spraycan to start."
		. += 1
	else
		mob << "The <b>territory spraycan</b> in your [where3] can be used to claim areas of the station for your gang. The more territory your gang controls, the more influence you get. All gangsters can use these, so distribute them to grow your influence faster."
	mob.update_icons()

	return .


///////////////////////////////////////////
//Deals with converting players to a gang//
///////////////////////////////////////////
/datum/game_mode/proc/add_gangster(datum/mind/gangster_mind, datum/gang/G, check = 1)
	if(!G || (gangster_mind in get_all_gangsters()))
		return 0
	if(check && isloyal(gangster_mind.current)) //Check to see if the potential gangster is implanted
		return 1
	G.gangsters += gangster_mind
	gangster_mind.gang_datum = G
	if(check)
		if(iscarbon(gangster_mind.current))
			var/mob/living/carbon/carbon_mob = gangster_mind.current
			carbon_mob.silent = max(carbon_mob.silent, 5)
			carbon_mob.flash_eyes(1, 1)
		gangster_mind.current.Stun(5)
	gangster_mind.current << "<FONT size=3 color=red><B>You are now a member of the [G.name] Gang!</B></FONT>"
	gangster_mind.current << "<font color='red'>Help your bosses take over the station by claiming territory with <b>special spraycans</b> only they can provide. Simply spray on any unclaimed area of the station.</font>"
	gangster_mind.current << "<font color='red'>Their ultimate objective is to take over the station with a Dominator machine.</font>"
	gangster_mind.current << "<font color='red'>You can identify your bosses by their <b>red \[G\] icon</b>.</font>"
	gangster_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the [G.name] Gang!</font>"
	gangster_mind.special_role = "[G.name] Gangster"
	G.add_gang_hud(gangster_mind)
	return 2
////////////////////////////////////////////////////////////////////
//Deals with players reverting to neutral (Not a gangster anymore)//
////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_gangster(datum/mind/gangster_mind, beingborged, silent, remove_bosses=0)
	var/datum/gang/gang = gangster_mind.gang_datum
	if(!gang)
		return 0

	var/removed

	for(var/datum/gang/G in gangs)
		if(gangster_mind in G.gangsters)
			G.gangsters -= gangster_mind
			removed = 1
		if(remove_bosses && (gangster_mind in G.bosses))
			G.bosses -= gangster_mind
			removed = 1

	if(!removed)
		return 0

	gangster_mind.special_role = null
	gangster_mind.gang_datum = null

	if(silent < 2)
		gangster_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has reformed and defected from the [gang.name] Gang!</font>"

		if(beingborged)
			if(!silent)
				gangster_mind.current.visible_message("The frame beeps contentedly from the MMI before initalizing it.")
			gangster_mind.current << "<FONT size=3 color=red><B>The frame's firmware detects and deletes your criminal behavior! You are no longer a gangster!</B></FONT>"
			message_admins("[key_name_admin(gangster_mind.current)] <A HREF='?_src_=holder;adminmoreinfo=\ref[gangster_mind.current]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[gangster_mind.current]'>FLW</A>) has been borged while being a member of the [gang.name] Gang. They are no longer a gangster.")
		else
			if(!silent)
				gangster_mind.current.Paralyse(5)
				gangster_mind.current.visible_message("<FONT size=3><B>[gangster_mind.current] looks like they've given up the life of crime!<B></font>")
			gangster_mind.current << "<FONT size=3 color=red><B>You have been reformed! You are no longer a gangster!</B><BR>You try as hard as you can, but you can't seem to recall any of the identities of your former gangsters...</FONT>"

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

/proc/get_domination_time(var/datum/gang/G)
	return max(180,900 - (round((G.territory.len/start_state.num_territories)*100, 1) * 12))

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/auto_declare_completion_gang(datum/gang/winner)
	if(gangs.len)
		if(!winner)
			world << "<FONT size=3 color=red><B>The station was [station_was_nuked ? "destroyed!" : "evacuated before a gang could claim it! The station wins!"]</B></FONT><br>"
		else
			world << "<FONT size=3 color=red><B>The [winner.name] Gang successfully performed a hostile takeover of the station!</B></FONT><br>"

	for(var/datum/gang/G in gangs)
		world << "<br><b>The [G.name] Gang was [winner==G ? "<font color=green>victorious</font>" : "<font color=red>defeated</font>"] with [round((G.territory.len/start_state.num_territories)*100, 1)]% control of the station!</b>"
		world << "<br>The [G.name] Gang Bosses were:"
		gang_membership_report(G.bosses)
		world << "<br>The [G.name] Gangsters were:"
		gang_membership_report(G.gangsters)
		world << "<br>"



/datum/game_mode/proc/gang_membership_report(list/membership)
	var/text = ""
	for(var/datum/mind/gang_mind in membership)
		text += "<br><b>[gang_mind.key]</b> was <b>[gang_mind.name]</b> ("
		if(gang_mind.current)
			if(gang_mind.current.stat == DEAD || isbrain(gang_mind.current))
				text += "died"
			else if(gang_mind.current.z > ZLEVEL_STATION)
				text += "fled the station"
			else
				text += "survived"
			if(gang_mind.current.real_name != gang_mind.name)
				text += " as <b>[gang_mind.current.real_name]</b>"
		else
			text += "body destroyed"
		text += ")"

	world << text


//////////////////////////////////////////////////////////
//Handles influence, territories, and the victory checks//
//////////////////////////////////////////////////////////

/datum/gang_points
	var/next_point_interval = 1800
	var/next_point_time

/datum/gang_points/New()
	next_point_time = world.time + next_point_interval
	SSobj.processing += src

/datum/gang_points/process(seconds)
	var/list/winners = list() //stores the winners if there are any

	for(var/datum/gang/G in ticker.mode.gangs)
		if(world.time > next_point_time)
			G.income()

		if(isnum(G.dom_timer))
			G.dom_timer -= seconds/10
			if(G.dom_timer < 0)
				winners += G

	if(world.time > next_point_time)
		next_point_time = world.time + next_point_interval

	if(winners.len)
		if(winners.len > 1) //Edge Case: If more than one dominator complete at the same time
			for(var/datum/gang/G in winners)
				G.domination(0.5)
			priority_announce("Multiple station takeover attempts have made simultaneously. Conflicting takeover attempts appears to have restarted.","Network Alert")
		else
			ticker.mode.explosion_in_progress = 1
			ticker.station_explosion_cinematic(1)
			ticker.mode.explosion_in_progress = 0
			ticker.force_ending = pick(winners)