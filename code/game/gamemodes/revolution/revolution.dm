// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
<<<<<<< HEAD
=======
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
<<<<<<< HEAD
	antag_flag = ROLE_REV
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 20
	required_enemies = 1
	recommended_enemies = 3
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Some crewmembers are attempting a coup!\n\
	<span class='danger'>Revolutionaries</span>: Expand your cause and overthrow the heads of staff by execution or otherwise.\n\
	<span class='notice'>Crew</span>: Prevent the revolutionaries from taking over the station."

	var/finished = 0
	var/check_counter = 0
	var/max_headrevs = 3
	var/list/datum/mind/heads_to_kill = list()

=======
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Mobile MMI","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
	required_players = 4
	required_players_secret = 25
	required_enemies = 3
	recommended_enemies = 3


	uplink_welcome = "Revolutionary Uplink Console:"
	uplink_uses = 10

	var/finished = 0
	var/checkwin_counter = 0
	var/max_headrevs = 3
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
<<<<<<< HEAD
	world << "<B>The current game mode is - Revolution!</B>"
	world << "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>"
=======
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

<<<<<<< HEAD
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = pick(antag_candidates)
		antag_candidates -= lenin
		head_revolutionaries += lenin
		lenin.restricted_roles = restricted_jobs

	if(head_revolutionaries.len < required_enemies)
		return 0

=======
	var/list/datum/mind/possible_headrevs = get_players_for_role(ROLE_REV)

	var/head_check = 0
	for(var/mob/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check++

	for(var/datum/mind/player in possible_headrevs)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				possible_headrevs -= player

	for (var/i=1 to max_headrevs)
		if (possible_headrevs.len==0)
			break
		var/datum/mind/lenin = pick(possible_headrevs)
		possible_headrevs -= lenin
		head_revolutionaries += lenin

	if((head_revolutionaries.len==0)||(!head_check))
		log_admin("Failed to set-up a round of revolution. Couldn't find any heads of staffs or any volunteers to be head revolutionaries.")
		message_admins("Failed to set-up a round of revolution. Couldn't find any heads of staffs or any volunteers to be head revolutionaries.")
		return 0

	log_admin("Starting a round of revolution with [head_revolutionaries.len] head revolutionaries and [head_check] heads of staff.")
	message_admins("Starting a round of revolution with [head_revolutionaries.len] head revolutionaries and [head_check] heads of staff.")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 1


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()
<<<<<<< HEAD
	var/list/sec = get_living_sec()
	var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headrevs)

	while(weighted_score < head_revolutionaries.len) //das vi danya
		var/datum/mind/trotsky = pick(head_revolutionaries)
		antag_candidates += trotsky
		head_revolutionaries -= trotsky
		update_rev_icons_removed(trotsky)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		log_game("[rev_mind.key] (ckey) has been selected as a head rev")
		for(var/datum/mind/head_mind in heads)
			mark_for_death(rev_mind, head_mind)

		spawn(rand(10,100))
		//	equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO
		//	Removing revolutionary uplinks.	-Pete
			equip_revolutionary(rev_mind.current)
=======

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

	//	equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO
	//	Removing revolutionary uplinks.	-Pete
		equip_revolutionary(rev_mind.current)
		update_rev_icons_added(rev_mind)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
<<<<<<< HEAD
	SSshuttle.registerHostileEnvironment(src)
=======
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1
	spawn (rand(waittime_l, waittime_h))
		if(!mixed) send_intercept()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()


/datum/game_mode/revolution/process()
<<<<<<< HEAD
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			check_heads()
			ticker.mode.check_win()
		check_counter = 0
	return 0


/datum/game_mode/proc/forge_revolutionary_objectives(datum/mind/rev_mind)
=======
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0


/datum/game_mode/proc/forge_revolutionary_objectives(var/datum/mind/rev_mind)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
<<<<<<< HEAD
		rev_obj.explanation_text = "Assassinate or exile [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(datum/mind/rev_mind, you_are=1)
	update_rev_icons_added(rev_mind)
	if (you_are)
		rev_mind.current << "<span class='userdanger'>You are a member of the revolutionaries' leadership!</span>"
	rev_mind.special_role = "Head Revolutionary"
	rev_mind.announce_objectives()
=======
		rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='notice'>You are a member of the revolutionaries' leadership!</span>")
	for(var/datum/objective/objective in rev_mind.objectives)
		to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		rev_mind.special_role = "Head Revolutionary"
		obj_count++
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
<<<<<<< HEAD
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.dna.remove_mutation(CLOWNMUT)


	var/obj/item/device/assembly/flash/T = new(mob)
	var/obj/item/toy/crayon/spraycan/R = new(mob)
	var/obj/item/clothing/glasses/hud/security/chameleon/C = new(mob)
=======
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(M_CLUMSY)


	var/obj/item/device/flash/T = new(mob)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
<<<<<<< HEAD
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	var/where2 = mob.equip_in_one_of_slots(C, slots)
	mob.equip_in_one_of_slots(R,slots)

	mob.update_icons()

	if (!where2)
		mob << "The Syndicate were unfortunately unable to get you a chameleon security HUD."
	else
		mob << "The chameleon security HUD in your [where2] will help you keep track of who is mindshield-implanted, and unable to be recruited."

	if (!where)
		mob << "The Syndicate were unfortunately unable to get you a flash."
	else
		mob << "The flash in your [where] will help you to persuade the crew to join your cause."
		return 1

/////////////////////////////////
//Gives head revs their targets//
/////////////////////////////////
/datum/game_mode/revolution/proc/mark_for_death(datum/mind/rev_mind, datum/mind/head_mind)
	var/datum/objective/mutiny/rev_obj = new
	rev_obj.owner = rev_mind
	rev_obj.target = head_mind
	rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
	rev_mind.objectives += rev_obj
	heads_to_kill += head_mind

////////////////////////////////////////////
//Checks if new heads have joined midround//
////////////////////////////////////////////
/datum/game_mode/revolution/proc/check_heads()
	var/list/heads = get_all_heads()
	var/list/sec = get_all_sec()
	if(heads_to_kill.len < heads.len)
		var/list/new_heads = heads - heads_to_kill
		for(var/datum/mind/head_mind in new_heads)
			for(var/datum/mind/rev_mind in head_revolutionaries)
				mark_for_death(rev_mind, head_mind)

	if(head_revolutionaries.len < max_headrevs && head_revolutionaries.len < round(heads.len - ((8 - sec.len) / 3)))
		latejoin_headrev()

///////////////////////////////
//Adds a new headrev midround//
///////////////////////////////
/datum/game_mode/revolution/proc/latejoin_headrev()
	if(revolutionaries) //Head Revs are not in this list
		var/list/promotable_revs = list()
		for(var/datum/mind/khrushchev in revolutionaries)
			if(khrushchev.current && khrushchev.current.client && khrushchev.current.stat != DEAD)
				if(ROLE_REV in khrushchev.current.client.prefs.be_special)
					promotable_revs += khrushchev
		if(promotable_revs.len)
			var/datum/mind/stalin = pick(promotable_revs)
			revolutionaries -= stalin
			head_revolutionaries += stalin
			log_game("[stalin.key] (ckey) has been promoted to a head rev")
			equip_revolutionary(stalin.current)
			forge_revolutionary_objectives(stalin)
			greet_revolutionary(stalin)

=======
	)
	var/where = mob.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 1)

	if (!where)
		to_chat(mob, "The Syndicate were unfortunately unable to get you a flash.")
	else
		to_chat(mob, "The flash in your [where] will help you to persuade the crew to join your cause.")
		mob.update_icons()
		return 1

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
<<<<<<< HEAD
	if(config.continuous["revolution"])
		if(finished)
			SSshuttle.clearHostileEnvironment(src)
=======
	if(config.continous_rounds)
		if(finished != 0)
			if(emergency_shuttle)
				emergency_shuttle.always_fake_recall = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return ..()
	if(finished != 0)
		return 1
	else
<<<<<<< HEAD
		return ..()
=======
		return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
<<<<<<< HEAD
/proc/is_revolutionary(mob/M)
	return M && istype(M) && M.mind && ticker && ticker.mode && M.mind in ticker.mode.revolutionaries

/proc/is_head_revolutionary(mob/M)
	return M && istype(M) && M.mind && ticker && ticker.mode && M.mind in ticker.mode.head_revolutionaries

/proc/is_revolutionary_in_general(mob/M)
	return is_revolutionary(M) || is_head_revolutionary(M)

/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in command_positions)
		return 0
	var/mob/living/carbon/human/H = rev_mind.current//Check to see if the potential rev is implanted
	if(isloyal(H))
		return 0
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return 0
	revolutionaries += rev_mind
	if(iscarbon(rev_mind.current))
		var/mob/living/carbon/carbon_mob = rev_mind.current
		carbon_mob.silent = max(carbon_mob.silent, 5)
		carbon_mob.flash_eyes(1, 1)
	rev_mind.current.Stun(5)
	rev_mind.current << "<span class='danger'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>"
	rev_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the revolution!</font>"
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)
	if(jobban_isbanned(rev_mind.current, ROLE_REV))
		replace_jobbaned_player(rev_mind.current, ROLE_REV, ROLE_REV)
=======
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in command_positions)
		return -1

	var/mob/living/carbon/human/H = rev_mind.current

	if(jobban_isbanned(H, "revolutionary"))
		return -2

	for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
		if(L.imp_in == H) // a check if it's actually implanted
			return -3

	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return -4

	revolutionaries += rev_mind
	to_chat(rev_mind.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
<<<<<<< HEAD
	var/remove_head = 0
	if(beingborged && (rev_mind in head_revolutionaries))
		head_revolutionaries -= rev_mind
		remove_head = 1

	if((rev_mind in revolutionaries) || remove_head)
		revolutionaries -= rev_mind
		rev_mind.special_role = null
		rev_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has renounced the revolution!</font>"

		if(beingborged)
			rev_mind.current << "<span class='danger'><FONT size = 3>The frame's firmware detects and deletes your neural reprogramming! You remember nothing[remove_head ? "." : " but the name of the one who flashed you."]</FONT></span>"
			message_admins("[ADMIN_LOOKUPFLW(rev_mind.current)] has been borged while being a [remove_head ? "leader" : " member"] of the revolution.")

		else
			rev_mind.current.Paralyse(5)
			rev_mind.current << "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</FONT></span>"
=======
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null

		if(beingborged)
			to_chat(rev_mind.current, "<span class='danger'><FONT size = 3>The frame's firmware detects and deletes your neural reprogramming!  You remember nothing from the moment you were flashed until now.</FONT></span>")

		else
			to_chat(rev_mind.current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</FONT></span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			if(beingborged)
<<<<<<< HEAD
				M << "The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it."

			else
				M << "[rev_mind.current] looks like they just remembered their real allegiance!"

/////////////////////////////////////
//Adds the rev hud to a new convert//
/////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = huds[ANTAG_HUD_REV]
	revhud.join_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, ((rev_mind in head_revolutionaries) ? "rev_head" : "rev"))

/////////////////////////////////////////
//Removes the hud from deconverted revs//
/////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = huds[ANTAG_HUD_REV]
	revhud.leave_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, null)
=======
				to_chat(M, "The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.")

			else
				to_chat(M, "[rev_mind.current] looks like they just remembered their real allegiance!")
		log_admin("[rev_mind.current] ([ckey(rev_mind.current.key)] has been deconverted from the revolution")


/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
//CURRENTLY CONTAINS BUGS:///////////////////////////////////////////////////////////////////////
//-PLAYERS THAT HAVE BEEN REVS FOR AWHILE OBTAIN THE BLUE ICON WHILE STILL NOT BEING A REV HEAD//
// -Possibly caused by cloning of a standard rev/////////////////////////////////////////////////
//-UNCONFIRMED: DECONVERTED REVS NOT LOSING THEIR ICON properLY//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_rev_icons()
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							//del(I)
							head_rev_mind.current.client.images -= I

		for(var/datum/mind/rev_mind in revolutionaries)
			if(rev_mind.current)
				if(rev_mind.current.client)
					for(var/image/I in rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							//del(I)
							rev_mind.current.client.images -= I

		for(var/datum/mind/head_rev in head_revolutionaries)
			if(head_rev.current)
				if(head_rev.current.client)
					for(var/datum/mind/rev in revolutionaries)
						if(rev.current)
							var/imageloc = rev.current
							if(istype(rev.current.loc,/obj/mecha))
								imageloc = rev.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev", layer = 13)
							head_rev.current.client.images += I
					for(var/datum/mind/head_rev_1 in head_revolutionaries)
						if(head_rev_1.current)
							var/imageloc = head_rev_1.current
							if(istype(head_rev_1.current.loc,/obj/mecha))
								imageloc = head_rev_1.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev_head", layer = 13)
							head_rev.current.client.images += I

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				if(rev.current.client)
					for(var/datum/mind/head_rev in head_revolutionaries)
						if(head_rev.current)
							var/imageloc = head_rev.current
							if(istype(head_rev.current.loc,/obj/mecha))
								imageloc = head_rev.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev_head", layer = 13)
							rev.current.client.images += I
					for(var/datum/mind/rev_1 in revolutionaries)
						if(rev_1.current)
							var/imageloc = rev_1.current
							if(istype(rev_1.current.loc,/obj/mecha))
								imageloc = rev_1.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev", layer = 13)
							rev.current.client.images += I

////////////////////////////////////////////////////
//Keeps track of converted revs icons///////////////
//Refer to above bugs. They may apply here as well//
////////////////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					var/imageloc = rev_mind.current
					if(istype(rev_mind.current.loc,/obj/mecha))
						imageloc = rev_mind.current.loc
					var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev", layer = 13)
					head_rev_mind.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/imageloc = head_rev_mind.current
					if(istype(head_rev_mind.current.loc,/obj/mecha))
						imageloc = head_rev_mind.current.loc
					var/image/J = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev_head", layer = 13)
					rev_mind.current.client.images += J

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					var/imageloc = rev_mind.current
					if(istype(rev_mind.current.loc,/obj/mecha))
						imageloc = rev_mind.current.loc
					var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev", layer = 13)
					rev_mind_1.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/imageloc = rev_mind_1.current
					if(istype(rev_mind_1.current.loc,/obj/mecha))
						imageloc = rev_mind_1.current.loc
					var/image/J = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "rev", layer = 13)
					rev_mind.current.client.images += J

///////////////////////////////////
//Keeps track of deconverted revs//
///////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && ((I.loc == rev_mind.current) || (I.loc == rev_mind.current.loc)))
							//del(I)
							head_rev_mind.current.client.images -= I

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					for(var/image/I in rev_mind_1.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && ((I.loc == rev_mind.current) || (I.loc == rev_mind.current.loc)))
							//del(I)
							rev_mind_1.current.client.images -= I

		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						//del(I)
						rev_mind.current.client.images -= I
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
<<<<<<< HEAD
		for(var/datum/objective/mutiny/objective in rev_mind.objectives)
=======
		for(var/datum/objective/objective in rev_mind.objectives)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(!(objective.check_completion()))
				return 0

		return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
<<<<<<< HEAD
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2) && T && (T.z == ZLEVEL_STATION))
=======
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2) && T && (T.z == 1))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - heads killed")
<<<<<<< HEAD
		world << "<span class='redtext'>The heads of staff were killed or exiled! The revolutionaries win!</span>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		world << "<span class='redtext'>The heads of staff managed to stop the revolution!</span>"
=======
		completion_text = "<br><span class='danger'><FONT size = 3> The heads of staff were killed or abandoned the station! The revolutionaries win!</FONT></span>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		completion_text = "<br><span class='danger'><FONT size = 3> The heads of staff managed to stop the revolution!</FONT></span>"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()
<<<<<<< HEAD
	if(head_revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/num_revs = 0
		var/num_survivors = 0
		for(var/mob/living/carbon/survivor in living_mob_list)
			if(survivor.ckey)
				num_survivors++
				if(survivor.mind)
					if((survivor.mind in head_revolutionaries) || (survivor.mind in revolutionaries))
						num_revs++
		if(num_survivors)
			world << "[TAB]Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B>" // % of loyal crew
		var/text = "<br><font size=3><b>The head revolutionaries were:</b></font>"
		for(var/datum/mind/headrev in head_revolutionaries)
			text += printplayer(headrev, 1)
		text += "<br>"
		world << text

	if(revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/text = "<br><font size=3><b>The revolutionaries were:</b></font>"
		for(var/datum/mind/rev in revolutionaries)
			text += printplayer(rev, 1)
		text += "<br>"
		world << text

	if( head_revolutionaries.len || revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution) )
		var/text = "<br><font size=3><b>The heads of staff were:</b></font>"
=======
	var/text = ""
	if(head_revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/icon/logo1 = icon('icons/mob/mob.dmi', "rev_head-logo")
		end_icons += logo1
		var/tempstate = end_icons.len
		text += {"<img src="logo_[tempstate].png"> <FONT size = 2><B>The head revolutionaries were:</B></FONT> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/headrev in head_revolutionaries)
			if(headrev.current)
				var/icon/flat = getFlatIcon(headrev.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				if(headrev.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(headrev.current.z != 1)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as [headrev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				text += "body destroyed"
			text += ")"
			if(headrev.total_TC)
				if(headrev.spent_TC)
					text += "<br><span class='sinister'>TC Remaining: [headrev.total_TC - headrev.spent_TC]/[headrev.total_TC] - The tools used by the Head Revolutionary were:"
					for(var/entry in headrev.uplink_items_bought)
						text += "<br>[entry]"
					text += "</span>"
				else
					text += "<br><span class='sinister'>The Head Revolutionary was a smooth operator this round (did not purchase any uplink items)</span>"

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target


	if(revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/icon/logo2 = icon('icons/mob/mob.dmi', "rev-logo")
		end_icons += logo2
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The revolutionaries were:</B></FONT> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				var/icon/flat = getFlatIcon(rev.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				if(rev.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(rev.current.z != 1)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(rev.current.real_name != rev.name)
					text += " as [rev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				text += "body destroyed"
			text += ")"



	if( head_revolutionaries.len || revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution) )
		var/icon/logo3 = icon('icons/mob/mob.dmi', "nano-logo")
		end_icons += logo3
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The heads of staff were:</B></FONT> <img src="logo_[tempstate].png">"}

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
<<<<<<< HEAD
				text += "<span class='boldannounce'>Target</span>"
			text += printplayer(head, 1)
		text += "<br>"
		world << text
=======
				text += "<font color='red'>"
			if(head.current)
				var/icon/flat = getFlatIcon(head.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[head.key]</b> was <b>[head.name]</b> ("}
				if(head.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(head.current.z != 1)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(head.current.real_name != head.name)
					text += " as [head.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[head.key]</b> was <b>[head.name]</b> ("}
				text += "body destroyed"
			text += ")"
			if(target)
				text += "</font>"

		text += "<BR><HR>"
	return text

/proc/is_convertable_to_rev(datum/mind/mind)
	return istype(mind) && \
		istype(mind.current, /mob/living/carbon/human) && \
		!(mind.assigned_role in command_positions) && \
		!(mind.assigned_role in list("Security Officer", "Detective", "Warden"))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
