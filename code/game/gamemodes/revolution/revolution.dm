// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	antag_flag = BE_REV
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 20
	required_enemies = 1
	recommended_enemies = 3
	enemy_minimum_age = 14

	var/finished = 0
	var/check_counter = 0
	var/max_headrevs = 3
	var/list/datum/mind/heads_to_kill = list()

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	world << "<B>The current game mode is - Revolution!</B>"
	world << "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>"


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

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

	return 1


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()

	while(heads.len < head_revolutionaries.len) //das vi danya
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
			update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
	SSshuttle.emergencyNoEscape = 1
	..()


/datum/game_mode/revolution/process()
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			check_heads()
			ticker.mode.check_win()
		check_counter = 0
	return 0


/datum/game_mode/proc/forge_revolutionary_objectives(datum/mind/rev_mind)
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate or exile [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(datum/mind/rev_mind, you_are=1)
	var/obj_count = 1
	if (you_are)
		rev_mind.current << "<span class='userdanger'>You are a member of the revolutionaries' leadership!</span>"
	for(var/datum/objective/objective in rev_mind.objectives)
		rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.dna.remove_mutation(CLOWNMUT)


	var/obj/item/device/flash/T = new(mob)
	var/obj/item/toy/crayon/spraycan/R = new(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	mob.equip_in_one_of_slots(R,slots)

	mob.update_icons()

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
	if(heads_to_kill.len < heads.len)
		var/list/new_heads = heads - heads_to_kill
		for(var/datum/mind/head_mind in new_heads)
			for(var/datum/mind/rev_mind in head_revolutionaries)
				mark_for_death(rev_mind, head_mind)

	if(head_revolutionaries.len < max_headrevs && head_revolutionaries.len < heads.len)
		latejoin_headrev()

///////////////////////////////
//Adds a new headrev midround//
///////////////////////////////
/datum/game_mode/revolution/proc/latejoin_headrev()
	if(revolutionaries) //Head Revs are not in this list
		var/list/promotable_revs = list()
		for(var/datum/mind/khrushchev in revolutionaries)
			if(khrushchev.current && khrushchev.current.client && khrushchev.current.stat != DEAD)
				if(khrushchev.current.client.prefs.be_special & BE_REV)
					promotable_revs += khrushchev
		if(promotable_revs)
			var/datum/mind/stalin = pick(promotable_revs)
			revolutionaries -= stalin
			head_revolutionaries += stalin
			log_game("[stalin.key] (ckey) has been promoted to a head rev")
			equip_revolutionary(stalin.current)
			forge_revolutionary_objectives(stalin)
			greet_revolutionary(stalin)

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
	if(config.continuous["revolution"])
		if(finished != 0)
			SSshuttle.emergencyNoEscape = 0
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/shuttledock.ogg', "Priority")
		return ..()
	if(finished != 0)
		return 1
	else
		return ..()

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
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
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null
		rev_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has renounced the revolution!</font>"

		if(beingborged)
			rev_mind.current << "<span class='danger'><FONT size = 3>The frame's firmware detects and deletes your neural reprogramming!  You remember nothing but the name of the one who flashed you.</FONT></span>"
			message_admins("[key_name_admin(rev_mind.current)] <A HREF='?_src_=holder;adminmoreinfo=\ref[rev_mind.current]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[rev_mind.current]'>FLW</A>) has been borged while being a member of the revolution.")

		else
			rev_mind.current.Paralyse(5)
			rev_mind.current << "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</FONT></span>"

		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			if(beingborged)
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

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/mutiny/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2) && rev_mind.current.client && T && (T.z == ZLEVEL_STATION))
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - heads killed")
		world << "<span class='danger'><FONT size = 3>The heads of staff were killed or exiled! The revolutionaries win!</FONT></span>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		world << "<span class='danger'><FONT size = 3>The heads of staff managed to stop the revolution!</FONT></span>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()

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
			text += "<br><b>[headrev.key]</b> was <b>[headrev.name]</b> ("
			if(headrev.current)
				if(headrev.current.stat == DEAD)
					text += "died"
				else if(headrev.current.z > ZLEVEL_STATION)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as <b>[headrev.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target
		text += "<br>"

		world << text

	if(revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/text = "<br><font size=3><b>The revolutionaries were:</b></font>"

		for(var/datum/mind/rev in revolutionaries)
			text += "<br><b>[rev.key]</b> was <b>[rev.name]</b> ("
			if(rev.current)
				if(rev.current.stat == DEAD || isbrain(rev.current))
					text += "died"
				else if(rev.current.z > ZLEVEL_STATION)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(rev.current.real_name != rev.name)
					text += " as <b>[rev.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
		text += "<br>"

		world << text


	if( head_revolutionaries.len || revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution) )
		var/text = "<br><font size=3><b>The heads of staff were:</b></font>"

		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<font color='red'>"
			text += "<br><b>[head.key]</b> was <b>[head.name]</b> ("
			if(head.current)
				if(head.current.stat == DEAD || isbrain(head.current))
					text += "died"
				else if(head.current.z > ZLEVEL_STATION)
					text += "fled the station"
				else
					text += "survived the revolution"
				if(head.current.real_name != head.name)
					text += " as <b>[head.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
			if(target)
				text += "</font>"
		text += "<br>"

		world << text
