//gang.dm
//Gang War Game Mode

/datum/game_mode
	var/list/datum/mind/A_bosses = list() //gang A bosses
	var/list/datum/mind/A_gangsters = list() //gang A Members
	var/list/datum/mind/B_bosses = list() //gang B bosses
	var/list/datum/mind/B_gangsters = list() //gang B Members

/datum/game_mode/gang
	name = "gang war"
	config_tag = "gang"
	antag_flag = BE_GANG
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 20
	required_enemies = 2
	recommended_enemies = 4

	var/finished = 0
	var/checkwin_counter = 0
///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/gang/announce()
	world << "<B>The current game mode is - Gang War!</B>"
	world << "<B>A violent turf war has erupted on the station!<BR>Gangsters -  Take over the station by killing the rival gang's bosses! Recruit gangsters by flashing them! <BR>Security - Protect the Crew! Identify and stop the mob bosses!</B>"


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/gang/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	if(antag_candidates.len > 2)
		assign_bosses()
		if(antag_candidates.len > 20)
			assign_bosses()

	if(!A_bosses.len || !B_bosses.len)
		return 0

//Set a temporary special_role so the job controller doesn't hand out invalid jobs for these antags
	for(var/datum/mind/boss_mind in A_bosses)
		boss_mind.special_role = "Gang member"
	for(var/datum/mind/boss_mind in B_bosses)
		boss_mind.special_role = "Gang member"

	return 1


/datum/game_mode/gang/post_setup()
	spawn(rand(10,100))
		for(var/datum/mind/boss_mind in A_bosses)
			update_gang_icons_added(boss_mind, "A")
			forge_gang_objectives(boss_mind, "A")
			greet_gang(boss_mind)
			equip_gang(boss_mind.current)

		for(var/datum/mind/boss_mind in B_bosses)
			update_gang_icons_added(boss_mind, "B")
			forge_gang_objectives(boss_mind, "B")
			greet_gang(boss_mind)
			equip_gang(boss_mind.current)

	modePlayer += A_bosses
	modePlayer += B_bosses
	..()


/datum/game_mode/gang/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/gang/proc/assign_bosses()
	var/datum/mind/boss = pick(antag_candidates)
	A_bosses += boss
	antag_candidates -= boss
	boss.special_role = "[gang_name("A")] Gang (A) Boss"
	log_game("[boss.key] has been selected as a boss for the [gang_name("A")] Gang (A)")

	boss = pick(antag_candidates)
	B_bosses += boss
	antag_candidates -= boss
	boss.special_role = "[gang_name("B")] Gang (B) Boss"
	log_game("[boss.key] has been selected as a boss for the [gang_name("B")] Gang (B)")

/datum/game_mode/proc/forge_gang_objectives(var/datum/mind/boss_mind)
	var/datum/objective/rival_obj = new
	rival_obj.owner = boss_mind
	rival_obj.explanation_text = "Assassinate or exile the [(boss_mind in A_bosses) ? gang_name("B") : gang_name("A")] Gang's bosses."
	boss_mind.objectives += rival_obj


/datum/game_mode/proc/greet_gang(var/datum/mind/boss_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		boss_mind.current << "<FONT size=3 color=red><B>You are a [(boss_mind in A_bosses) ? gang_name("A") : gang_name("B")] Gang Boss!</B></FONT>"
	for(var/datum/objective/objective in boss_mind.objectives)
		boss_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

///////////////////////////////////////////////////////////////////////////
//This equips the bosses with their gear, and makes the clown not clumsy//
///////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_gang(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.mutations.Remove(CLUMSY)


	var/obj/item/device/flash/T = new(mob)
	var/obj/item/device/recaller/recaller = new(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	. = 0

	var/where2 = mob.equip_in_one_of_slots(recaller, slots)
	if (!where2)
		mob << "Your Syndicate benefactors were unfortunately unable to get you a Recaller."
	else
		mob << "The <b>Recaller</b> in your [where2] will allow you to prevent the station from prematurely evacuating. Use it to recall the emergency shuttle from anywhere on the station."
		. += 2

	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		mob << "Your Syndicate benefactors were unfortunately unable to get you a flash."
	else
		mob << "The <b>flash</b> in your [where] will help you to persuade the crew to work for you. Keep in mind that your underlings can only identify their bosses, but not each other."
		. += 1

	mob.update_icons()

	return .

/////////////////////////////////////////////
//Checks if the either gang have won or not//
/////////////////////////////////////////////
/datum/game_mode/gang/check_win()
	var/A_victory = check_gang_victory(B_bosses) //Check if B bosses are dead or exiled
	var/B_victory = check_gang_victory(A_bosses) //Check if A bosses are dead or exiled

	if(A_victory && B_victory)
		finished = "Draw" //Both teams fail. Allow for draws in case they're all incapacitated at the same time.

	else if(A_victory)
		finished = "A" //Gang A wins

	else if(B_victory)
		finished = "B" //Gang B wins

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/gang/check_finished()
	if(finished) //Check for Gang Boss death
		return 1
	return ..() //Check for evacuation/nuke

///////////////////////////////////////////
//Deals with converting players to a gang//
///////////////////////////////////////////
/datum/game_mode/proc/add_gangster(datum/mind/gangster_mind, var/gang, var/check = 1)
	if(check && isloyal(gangster_mind.current)) //Check to see if the potential gangster is implanted
		return 0
	if((gangster_mind in A_bosses) || (gangster_mind in A_gangsters) || (gangster_mind in B_bosses) || (gangster_mind in B_gangsters))
		return 0
	if(gang == "A")
		A_gangsters += gangster_mind
	else
		B_gangsters += gangster_mind
	gangster_mind.current << "<FONT size=3 color=red><B>You are now a member of the [gang=="A" ? gang_name("A") : gang_name("B")] Gang!</B></FONT>"
	gangster_mind.current << "<font color='red'>Help your bosses take over the station by defeating their rivals. You can identify your bosses by the brown \"B\" icons, but only they know who is in your gang! Work with your boss to avoid attacking your own gang.</font>"
	gangster_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the [gang=="A" ? "[gang_name("A")] Gang (A)" : "[gang_name("B")] Gang (B)"]!</font>"
	gangster_mind.special_role = "[gang=="A" ? "[gang_name("A")] Gang (A)" : "[gang_name("B")] Gang (B)"]"
	update_gang_icons_added(gangster_mind,gang)
	return 1
//////////////////////////////////////////////////////////////
//Deals with players going straight (Not a gangster anymore)//
//////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_gangster(datum/mind/gangster_mind, var/beingborged, var/silent)
	var/gang

	if(gangster_mind in A_bosses)
		A_bosses -= gangster_mind
		gang = "A"

	else if(gangster_mind in A_gangsters)
		A_gangsters -= gangster_mind
		gang = "A"

	else if(gangster_mind in B_bosses)
		B_bosses -= gangster_mind
		gang = "B"

	else if(gangster_mind in B_gangsters)
		B_gangsters -= gangster_mind
		gang = "B"

	if(!gang) //not a valid gangster
		return

	gangster_mind.special_role = null
	if(silent < 2)
		gangster_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has reformed and defected from the [gang=="A" ? "[gang_name("A")] Gang (A)" : "[gang_name("B")] Gang (B)"]!</font>"

		if(beingborged)
			if(!silent)
				gangster_mind.current.visible_message("The frame beeps contentedly from the MMI before initalizing it.")
			gangster_mind.current << "<FONT size=3 color=red><B>The frame's firmware detects and deletes your criminal behavior! You are no longer a gangster!</B></FONT>"
			message_admins("[key_name_admin(gangster_mind.current)] <A HREF='?_src_=holder;adminmoreinfo=\ref[gangster_mind.current]'>?</A> has been borged while being a member of the [gang=="A" ? "[gang_name("A")] Gang (A)" : "[gang_name("B")] Gang (B)"] Gang. They are no longer a gangster.")
		else
			if(!silent)
				gangster_mind.current.visible_message("[gangster_mind.current] looks like they've given up the life of crime!")
			gangster_mind.current << "<FONT size=3 color=red><B>You have been reformed! You are no longer a gangster!</B></FONT>"

	update_gang_icons_removed(gangster_mind)


/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_gang_icons()
	spawn(0)
		var/list/all_gangsters = A_bosses + B_bosses + A_gangsters + B_gangsters

		//Delete all gang icons
		for(var/datum/mind/gang_mind in all_gangsters)
			if(gang_mind.current)
				if(gang_mind.current.client)
					for(var/image/I in gang_mind.current.client.images)
						if(I.icon_state == "gangster" || I.icon_state == "gang_boss")
							del(I)

		update_gang_icons("A")
		update_gang_icons("B")

/datum/game_mode/proc/update_gang_icons(var/gang)
	var/list/bosses
	var/list/gangsters
	if(gang == "A")
		bosses = A_bosses
		gangsters = A_gangsters
	else if(gang == "B")
		bosses = B_bosses
		gangsters = B_gangsters
	else
		world << "ERROR: Invalid gang in update_gang_icons()"

	//Update gang icons for boss' visions
	for(var/datum/mind/boss_mind in bosses)
		if(boss_mind.current)
			if(boss_mind.current.client)
				for(var/datum/mind/gangster_mind in gangsters)
					if(gangster_mind.current)
						var/I = image('icons/mob/mob.dmi', loc = gangster_mind.current, icon_state = "gangster")
						boss_mind.current.client.images += I
				for(var/datum/mind/boss2_mind in bosses)
					if(boss2_mind.current)
						var/I = image('icons/mob/mob.dmi', loc = boss2_mind.current, icon_state = "gang_boss")
						boss_mind.current.client.images += I

	//Update boss and self icons for gangsters' visions
	for(var/datum/mind/gangster_mind in gangsters)
		if(gangster_mind.current)
			if(gangster_mind.current.client)
				for(var/datum/mind/boss_mind in bosses)
					if(boss_mind.current)
						var/I = image('icons/mob/mob.dmi', loc = boss_mind.current, icon_state = "gang_boss")
						gangster_mind.current.client.images += I
					//Tag themselves to see
					var/K
					if(gangster_mind in bosses) //If the new gangster is a boss himself
						K = image('icons/mob/mob.dmi', loc = gangster_mind.current, icon_state = "gang_boss")
					else
						K = image('icons/mob/mob.dmi', loc = gangster_mind.current, icon_state = "gangster")
					gangster_mind.current.client.images += K

/////////////////////////////////////////////////
//Assigns icons when a new gangster is recruited//
/////////////////////////////////////////////////
/datum/game_mode/proc/update_gang_icons_added(datum/mind/recruit_mind, var/gang)
	var/list/bosses
	if(gang == "A")
		bosses = A_bosses
	else if(gang == "B")
		bosses = B_bosses
	if(!gang)
		world << "ERROR: Invalid gang in update_gang_icons_added()"

	spawn(0)
		for(var/datum/mind/boss_mind in bosses)
			//Tagging the new gangster for the bosses to see
			if(boss_mind.current)
				if(boss_mind.current.client)
					var/I
					if(recruit_mind in bosses) //If the new gangster is a boss himself
						I = image('icons/mob/mob.dmi', loc = recruit_mind.current, icon_state = "gang_boss")
					else
						I = image('icons/mob/mob.dmi', loc = recruit_mind.current, icon_state = "gangster")
					boss_mind.current.client.images += I
			//Tagging every boss for the new gangster to see
			if(recruit_mind.current)
				if(recruit_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = boss_mind.current, icon_state = "gang_boss")
					recruit_mind.current.client.images += J
		//Tag themselves to see
		if(recruit_mind.current)
			if(recruit_mind.current.client)
				var/K
				if(recruit_mind in bosses) //If the new gangster is a boss himself
					K = image('icons/mob/mob.dmi', loc = recruit_mind.current, icon_state = "gang_boss")
				else
					K = image('icons/mob/mob.dmi', loc = recruit_mind.current, icon_state = "gangster")
				recruit_mind.current.client.images += K

////////////////////////////////////////
//Keeps track of deconverted gangsters//
////////////////////////////////////////
/datum/game_mode/proc/update_gang_icons_removed(datum/mind/defector_mind)
	var/list/all_gangsters = A_bosses + B_bosses + A_gangsters + B_gangsters

	spawn(0)
		//Remove defector's icon from gangsters' visions
		for(var/datum/mind/boss_mind in all_gangsters)
			if(boss_mind.current)
				if(boss_mind.current.client)
					for(var/image/I in boss_mind.current.client.images)
						if((I.icon_state == "gangster" || I.icon_state == "gang_boss") && I.loc == defector_mind.current)
							del(I)

		//Remove gang icons from defector's vision
		if(defector_mind.current)
			if(defector_mind.current.client)
				for(var/image/I in defector_mind.current.client.images)
					if(I.icon_state == "gangster" || I.icon_state == "gang_boss")
						del(I)

///////////////////////////
//Checks for gang victory//
///////////////////////////
/datum/game_mode/gang/proc/check_gang_victory(var/list/boss_list)
	if(!boss_list.len)
		return 0
	for(var/datum/mind/boss_mind in boss_list)
		if(boss_mind.current)
			if(boss_mind.current.stat == DEAD || !ishuman(boss_mind.current) || !boss_mind.current.ckey || !boss_mind.current.client)
				return 1
			var/turf/T = get_turf(boss_mind.current)
			if(T && (T.z != 1))			//If they leave the station they count as dead for this
				return 1
			return 0
		return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/gang/declare_completion()
	if(!finished)
		world << "<FONT size=3 color=red><B>The station was [station_was_nuked ? "destroyed!" : "evacuated before either gang could claim it!"]</B></FONT>"
	if(finished == "Draw")
		world << "<FONT size=3 color=red><B>All gang bosses have been killed or exiled!</B></FONT>"
	else
		world << "<FONT size=3 color=red><B>The [finished=="A" ? gang_name("A") : gang_name("B")] Gang defeated their rivals!</B></FONT>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_gang()
	var/winner
	var/datum/game_mode/gang/game_mode = ticker.mode
	if(istype(game_mode))
		winner = game_mode.finished

	var/num_ganga = 0
	var/list/agang = A_gangsters + A_bosses
	for(var/datum/mind/agangster in agang)
		if(agangster.current)
			if(agangster.current in living_mob_list)
				num_ganga++

	var/num_gangb = 0
	var/list/bgang = B_gangsters + B_bosses
	for(var/datum/mind/bgangster in bgang)
		if(bgangster.current)
			if(bgangster.current in living_mob_list)
				num_gangb++

	var/num_survivors = 0
	for(var/mob/living/carbon/survivor in living_mob_list)
		if(survivor.key)
			num_survivors++

	if(A_bosses.len || A_gangsters.len)
		if(winner == "A" || winner == "B")
			world << "<br><b>The [gang_name("A")] Gang was [winner=="A" ? "<font color=green>victorious</font>" : "<font color=red>defeated</font>"] with [round((num_ganga/num_survivors)*100, 0.1)]% strength.</b>"
		world << "<br><font size=2><b>The [gang_name("A")] Gang bosses were:</b></font>"
		gang_membership_report(A_bosses)
		world << "<br><font size=2><b>The [gang_name("A")] Gangsters were:</b></font>"
		gang_membership_report(A_gangsters)

	if(B_bosses.len || B_gangsters.len)
		if(winner == "A" || winner == "B")
			world << "<br><b>The [gang_name("B")] Gang was [winner=="B" ? "<font color=green>victorious</font>" : "<font color=red>defeated</font>"] with [round((num_gangb/num_survivors)*100, 0.1)]% strength</b>"
		world << "<br><font size=2><b>The [gang_name("B")] Gang bosses were:</b></font>"
		gang_membership_report(B_bosses)
		world << "<br><font size=2><b>The [gang_name("B")] Gangsters were:</b></font>"
		gang_membership_report(B_gangsters)

/datum/game_mode/proc/gang_membership_report(var/list/membership)
	var/text = ""
	for(var/datum/mind/gang_mind in membership)
		text += "<br><b>[gang_mind.key]</b> was <b>[gang_mind.name]</b> ("
		if(gang_mind.current)
			if(gang_mind.current.stat == DEAD || isbrain(gang_mind.current))
				text += "died"
			else if(gang_mind.current.z != 1)
				text += "fled the station"
			else
				text += "survived"
			if(gang_mind.current.real_name != gang_mind.name)
				text += " as <b>[gang_mind.current.real_name]</b>"
		else
			text += "body destroyed"
		text += ")"
	text += "<br>"

	world << text
