/datum/game_mode/epidemic
	name = "epidemic"
	config_tag = "epidemic"
	required_players = 6

	var/const/waittime_l = 300 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 600 //upper bound on time before intercept arrives (in tenths of seconds)
	var/checkwin_counter =0
	var/finished = 0

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/epidemic/announce()
	world << "<B>The current game mode is - Epidemic!</B>"
	world << "<B>A deadly epidemic is spreading on the station. Find a cure as fast as possible, and keep your distance to anyone who speaks in a hoarse voice!</B>"


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/epidemic/pre_setup()
	var/doctors = 0
	for(var/mob/new_player/player in world)
		if(player.mind.assigned_role in list("Chief Medical Officer","Medical Doctor"))
			doctors++
			break

	if(doctors < 1)
		return 0

	return 1


/datum/game_mode/epidemic/post_setup()
	var/list/crew = list()
	for(var/mob/living/carbon/human/H in world) if(H.client)
		crew += H

	if(crew.len < 2)
		world << "\red There aren't enough players for this mode!"
		return

	var/datum/disease2/disease/lethal = new
	lethal.makerandom(1)
	lethal.infectionchance = 5

	var/datum/disease2/disease/nonlethal = new
	nonlethal.makerandom(0)
	nonlethal.infectionchance = 0

	for(var/i = 0, i < crew.len / 3, i++)
		var/mob/living/carbon/human/H = pick(crew)
		if(H.virus2)
			i--
			continue
		H.virus2 = lethal.getcopy()

	for(var/i = 0, i < crew.len / 3, i++)
		var/mob/living/carbon/human/H = pick(crew)
		if(H.virus2)
			continue
		H.virus2 = nonlethal.getcopy()

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

		spawn(10 * 60 * 30)
			command_alert("Unknown pathogen detected in routine biological scans.", "Biohazard Alert")
			spawn(300)
				command_alert("Pathogen identified as level 7 biohazard. All crew, take precaution immediately. Avoid contact with other biological personnel when necessary. Initiate quarantine immediately.", "Biohazard Alert")

	..()


/datum/game_mode/epidemic/process()
	checkwin_counter++
	if(checkwin_counter >= 20)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/epidemic/check_win()
	var/alive = 0
	var/sick = 0
	for(var/mob/living/carbon/human/H in world)
		if(H.key && H.stat != 2) alive++
		if(H.virus2 && H.stat != 2) sick++

	if(alive == 0)
		finished = 2
	if(sick == 0)
		finished = 1
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/epidemic/check_finished()
	if(finished != 0)
		return 1
	else
		return 0

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/epidemic/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - epidemic cured")
		world << "\red <FONT size = 3><B> The virus outbreak was contained! The crew wins!</B></FONT>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		world << "\red <FONT size = 3><B> The crew succumbed to the epidemic!</B></FONT>"
	..()
	return 1