// To add a rev to the list of revolutionaries, make sure it's rev (with if(SSticker.mode.name == "revolution)),
// then call SSticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call SSticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the game somtimes isn't registering a win properly, then SSticker.mode.check_win() isn't being called somewhere.


/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	antag_flag = ROLE_REV
	false_report_weight = 10
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
	var/datum/objective_team/revolution/revolution
	var/list/datum/mind/headrev_candidates = list()

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = pick(antag_candidates)
		antag_candidates -= lenin
		headrev_candidates += lenin
		lenin.restricted_roles = restricted_jobs

	if(headrev_candidates.len < required_enemies)
		return FALSE

	return TRUE

/datum/game_mode/revolution/post_setup()
	var/list/heads = SSjob.get_living_heads()
	var/list/sec = SSjob.get_living_sec()
	var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headrevs)

	for(var/datum/mind/rev_mind in headrev_candidates)	//People with return to lobby may still be in the lobby. Let's pick someone else in that case.
		if(isnewplayer(rev_mind.current))
			headrev_candidates -= rev_mind
			var/list/newcandidates = shuffle(antag_candidates)
			if(newcandidates.len == 0)
				continue
			for(var/M in newcandidates)
				var/datum/mind/lenin = M
				antag_candidates -= lenin
				newcandidates -= lenin
				if(isnewplayer(lenin.current)) //We don't want to make the same mistake again
					continue
				else
					var/mob/Nm = lenin.current
					if(Nm.job in restricted_jobs)	//Don't make the HOS a replacement revhead
						antag_candidates += lenin	//Let's let them keep antag chance for other antags
						continue

					headrev_candidates += lenin
					break

	while(weighted_score < headrev_candidates.len) //das vi danya
		var/datum/mind/trotsky = pick(headrev_candidates)
		antag_candidates += trotsky
		headrev_candidates -= trotsky

	revolution = new()

	for(var/datum/mind/rev_mind in headrev_candidates)
		log_game("[rev_mind.key] (ckey) has been selected as a head rev")
		var/datum/antagonist/rev/head/new_head = new(rev_mind)
		new_head.give_flash = TRUE
		new_head.give_hud = TRUE
		new_head.remove_clumsy = TRUE
		rev_mind.add_antag_datum(new_head,revolution)

	revolution.update_objectives()
	revolution.update_heads()

	SSshuttle.registerHostileEnvironment(src)
	..()


/datum/game_mode/revolution/process()
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			SSticker.mode.check_win()
		check_counter = 0
	return FALSE

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
	if(CONFIG_GET(keyed_flag_list/continuous)["revolution"])
		if(finished)
			SSshuttle.clearHostileEnvironment(src)
		return ..()
	if(finished != 0)
		return TRUE
	else
		return ..()

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/proc/is_revolutionary(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/rev)

/proc/is_head_revolutionary(mob/M)
<<<<<<< HEAD
	return M && istype(M) && M.mind && SSticker && SSticker.mode && M.mind in SSticker.mode.head_revolutionaries

/proc/is_revolutionary_in_general(mob/M)
	return is_revolutionary(M) || is_head_revolutionary(M)

/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in GLOB.command_positions)
		return FALSE
	var/mob/living/carbon/human/H = rev_mind.current//Check to see if the potential rev is implanted
	if(H.isloyal())
		return FALSE
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return FALSE
	if(rev_mind.unconvertable)
		return FALSE
	revolutionaries += rev_mind
	if(iscarbon(rev_mind.current))
		var/mob/living/carbon/carbon_mob = rev_mind.current
		carbon_mob.silent = max(carbon_mob.silent, 5)
		carbon_mob.flash_act(1, 1)
	rev_mind.current.Stun(100)
	to_chat(rev_mind.current, "<span class='danger'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
	rev_mind.current.log_message("<font color='red'>Has been converted to the revolution!</font>", INDIVIDUAL_ATTACK_LOG)
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)
	if(jobban_isbanned(rev_mind.current, ROLE_REV) || jobban_isbanned(rev_mind.current, CATBAN) || jobban_isbanned(rev_mind.current, CLUWNEBAN))
		INVOKE_ASYNC(src, .proc/replace_jobbaned_player, rev_mind.current, ROLE_REV, ROLE_REV)
	return TRUE
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged, deconverter)
	var/remove_head = 0
	if(beingborged && (rev_mind in head_revolutionaries))
		head_revolutionaries -= rev_mind
		remove_head = 1

	if((rev_mind in revolutionaries) || remove_head)
		revolutionaries -= rev_mind
		rev_mind.special_role = null
		log_attack("[rev_mind.current] (Key: [key_name(rev_mind.current)]) has been deconverted from the revolution by [deconverter] (Key: [key_name(deconverter)])!")

		if(beingborged)
			rev_mind.current.visible_message("The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.", \
				"<span class='userdanger'><FONT size = 3>The frame's firmware detects and deletes your neural reprogramming! You remember nothing[remove_head ? "." : " but the name of the one who flashed you."]</FONT></span>")
			message_admins("[ADMIN_LOOKUPFLW(rev_mind.current)] has been borged while being a [remove_head ? "leader" : " member"] of the revolution.")
		else
			rev_mind.current.visible_message("[rev_mind.current] looks like they just remembered their real allegiance!", \
				"<span class='userdanger'><FONT size = 3>You are no longer a brainwashed revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</FONT></span>")
			rev_mind.current.Unconscious(100)
		update_rev_icons_removed(rev_mind)

/////////////////////////////////////
//Adds the rev hud to a new convert//
/////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = GLOB.huds[ANTAG_HUD_REV]
	revhud.join_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, ((rev_mind in head_revolutionaries) ? "rev_head" : "rev"))

/////////////////////////////////////////
//Removes the hud from deconverted revs//
/////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = GLOB.huds[ANTAG_HUD_REV]
	revhud.leave_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, null)
=======
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/rev/head)
>>>>>>> bfc5a2cca8... Datum rev & related upgrades to base datum antag (#31630)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in revolution.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in revolution.head_revolutionaries())
		var/turf/T = get_turf(rev_mind.current)
		if(!considered_afk(rev_mind) && considered_alive(rev_mind) && (T.z in GLOB.station_z_levels))
			if(ishuman(rev_mind.current))
				return FALSE
	return TRUE

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		SSticker.mode_result = "win - heads killed"
		to_chat(world, "<span class='redtext'>The heads of staff were killed or exiled! The revolutionaries win!</span>")

		SSticker.news_report = REVS_WIN

	else if(finished == 2)
		SSticker.mode_result = "loss - rev heads killed"
		to_chat(world, "<span class='redtext'>The heads of staff managed to stop the revolution!</span>")

		SSticker.news_report = REVS_LOSE
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()
	var/list/datum/mind/headrevs = get_antagonists(/datum/antagonist/rev/head)
	var/list/datum/mind/revs = get_antagonists(/datum/antagonist/rev,TRUE)
	if(headrevs.len)
		var/num_revs = 0
		var/num_survivors = 0
		for(var/mob/living/carbon/survivor in GLOB.living_mob_list)
			if(survivor.ckey)
				num_survivors++
				if(survivor.mind)
					if(is_revolutionary(survivor))
						num_revs++
		if(num_survivors)
			to_chat(world, "[GLOB.TAB]Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B>" )
		var/text = "<br><font size=3><b>The head revolutionaries were:</b></font>"
		for(var/datum/mind/headrev in headrevs)
			text += printplayer(headrev, 1)
		text += "<br>"
		to_chat(world, text)

	if(revs.len)
		var/text = "<br><font size=3><b>The revolutionaries were:</b></font>"
		for(var/datum/mind/rev in revs)
			text += printplayer(rev, 1)
		text += "<br>"
		to_chat(world, text)

	if(revs.len || headrevs.len)
		var/text = "<br><font size=3><b>The heads of staff were:</b></font>"
		var/list/heads = SSjob.get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<span class='boldannounce'>Target</span>"
			text += printplayer(head, 1)
		text += "<br>"
		to_chat(world, text)

/datum/game_mode/revolution/generate_report()
	return "Employee unrest has spiked in recent weeks, with several attempted mutinies on heads of staff. Some crew have been observed using flashbulb devices to blind their colleagues, \
		who then follow their orders without question and work towards dethroning departmental leaders. Watch for behavior such as this with caution. If the crew attempts a mutiny, you and \
		your heads of staff are fully authorized to execute them using lethal weaponry - they will be later cloned and interrogated at Central Command."
