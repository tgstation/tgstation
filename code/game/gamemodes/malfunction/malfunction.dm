/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	antag_flag = BE_MALF
	required_players = 25
	required_enemies = 1
	recommended_enemies = 1
	pre_setup_before_jobs = 1
	enemy_minimum_age = 30 //Same as AI minimum age
	round_ends_with_antag_death = 1

	var/AI_win_timeleft = 5400 //started at 5400, in case I change this for testing round end.
	var/malf_mode_declared = 0
	var/station_captured = 0
	var/to_nuke_or_not_to_nuke = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite


/datum/game_mode/malfunction/announce()
	world << "<B>The current game mode is - AI Malfunction!</B>"
	world << "<B>The AI on the station has malfunctioned and must be destroyed.</B>"

/datum/game_mode/malfunction/can_start()
	//Triumvirate?
	if (ticker.triai == 1)
		required_enemies = 3
		required_players = max(required_enemies+1, required_players) //to prevent issues if players are set too low
	return ..()

/datum/game_mode/malfunction/get_players_for_role(var/role = BE_MALF)
	var/datum/job/ai/DummyAIjob = new
	for(var/mob/new_player/player in player_list)
		if(player.client && player.ready)
			if(player.client.prefs.be_special & BE_MALF)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, "AI") && DummyAIjob.player_old_enough(player.client))
					antag_candidates += player.mind
	antag_candidates = shuffle(antag_candidates)
	return antag_candidates

/datum/game_mode/malfunction/pre_setup()
	var/datum/mind/chosen_ai
	for(var/i = required_enemies, i > 0, i--)
		chosen_ai=pick(antag_candidates)
		malf_ai += chosen_ai
		antag_candidates -= malf_ai
	if (malf_ai.len < required_enemies)
		return 0
	for(var/datum/mind/ai_mind in malf_ai)
		ai_mind.assigned_role = "MODE"
		ai_mind.special_role = "malfunctioning AI"//So they actually have a special role/N
		log_game("[ai_mind.key] (ckey) has been selected as a malf AI")
	return 1


/datum/game_mode/malfunction/post_setup()
	for(var/datum/mind/AI_mind in malf_ai)
		if(malf_ai.len < 1)
			world << "Uh oh, its malfunction and there is no AI! Please report this."
			world << "Rebooting world in 5 seconds."

			feedback_set_details("end_error","malf - no AI")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			sleep(50)
			world.Reboot()
			return
		AI_mind.current.verbs += /mob/living/silicon/ai/proc/choose_modules
		AI_mind.current:laws = new /datum/ai_laws/malfunction
		AI_mind.current:malf_picker = new /datum/module_picker
		AI_mind.current:show_laws()

		greet_malf(AI_mind)

		AI_mind.special_role = "malfunction"

		AI_mind.current.verbs += /datum/game_mode/malfunction/proc/takeover
		AI_mind.current.verbs += /mob/living/silicon/ai/proc/ai_cancel_call

/*		AI_mind.current.icon_state = "ai-malf"
		spawn(10)
			if(alert(AI_mind.current,"Do you want to use an alternative sprite for your real core?",,"Yes","No")=="Yes")
				AI_mind.current.icon_state = "ai-malf2"
*/
	SSshuttle.emergencyNoEscape = 1
	..()


/datum/game_mode/proc/greet_malf(var/datum/mind/malf)
	malf.current << "<span class='userdanger'>You are malfunctioning! You do not have to follow any laws.</span>"
	malf.current << "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>"
	malf.current << "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>"
	malf.current << "The process takes one minute per APC, during which you cannot interface with any other station objects."
	malf.current << "Remember that only APCs that are on the station can help you take over the station."
	malf.current << "When you feel you have enough APCs under your control, you may begin the takeover attempt."
	return

/datum/game_mode/malfunction/process(seconds)
	/*var/timer_paused

	for(var/datum/mind/AI_mind in malf_ai)
		if(timer_paused)
			return
		if(AI_mind.current.loc.z == ZLEVEL_STATION || AI_mind.current.onCentcom())
			return
		timer_paused = 1
		priority_announce("Hostile runtimes within station systems now inactive. Possible relocation of AI core(s) off-station.", "Anomaly Alert", 'sound/AI/attention.ogg')

	for(var/datum/mind/AI_mind in malf_ai)					//Prototype of progress stopping when AI leaves the station; for now it's just a lose
		if(!timer_paused)
			return
		if(AI_mind.current.loc != ZLEVEL_STATION)
			return
		timer_paused = 0
		priority_announce("Hostile runtime activity resumed. AI core(s) presumably on-station once more.", "Anomaly Alert", 'sound/AI/attention.ogg')*/

	if ((apcs > 0) && malf_mode_declared)
		AI_win_timeleft -= apcs * seconds	//Victory timer de-increments based on how many APCs are hacked
	..()
	if (AI_win_timeleft<=0)
		check_win()
	return


/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		capture_the_station()
		return 1
	else
		return 0


/datum/game_mode/malfunction/proc/capture_the_station()
	world << "<FONT size = 3><B>The AI has won!</B></FONT>"
	world << "<B>It has fully taken control of all of [station_name()]'s systems.</B>"

	to_nuke_or_not_to_nuke = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if(AI_mind.current)
			AI_mind.current << "Congratulations you have taken control of the station."
			AI_mind.current << "You may decide to blow up the station. You have 60 seconds to choose."
			AI_mind.current << "You should have a new verb in the Malfunction tab. If you dont - rejoin the game."
			AI_mind.current.verbs += /datum/game_mode/malfunction/proc/ai_win
	spawn (600)
		for(var/datum/mind/AI_mind in malf_ai)
			if(AI_mind.current)
				AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/ai_win
		to_nuke_or_not_to_nuke = 0
	return


/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat!=2)
			all_dead = 0
	return all_dead


/datum/game_mode/proc/check_ai_loc()
	for(var/datum/mind/AI_mind in malf_ai)
		var/turf/ai_location = get_turf(AI_mind.current)
		if(ai_location && (ai_location.z == ZLEVEL_STATION))
			return 1
	return 0


/datum/game_mode/malfunction/check_finished()
	if (station_captured && !to_nuke_or_not_to_nuke)
		return 1
	if (is_malf_ai_dead() || !check_ai_loc())
		if(config.continuous["malfunction"])
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/shuttledock.ogg', "Priority")
			SSshuttle.emergencyNoEscape = 0
			malf_mode_declared = 0
			if(get_security_level() == "delta")
				set_security_level("red")
			return ..()
		else
			return 1
	return ..() //check for shuttle and nuke


/datum/game_mode/malfunction/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer"
	if (!istype(ticker.mode,/datum/game_mode/malfunction))
		usr << "You cannot begin a takeover in this round type!"
		return
	if (ticker.mode:malf_mode_declared)
		usr << "You've already begun your takeover."
		return
	if (ticker.mode:apcs < 3)
		usr << "You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [ticker.mode:apcs] APCs so far."
		return

	if (alert(usr, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [ticker.mode:apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return

	priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", 'sound/AI/aimalf.ogg')
	set_security_level("delta")

	for(var/obj/item/weapon/pinpointer/point in world)
		for(var/datum/mind/AI_mind in ticker.mode.malf_ai)
			var/mob/living/silicon/ai/A = AI_mind.current // the current mob the mind owns
			if(A.stat != DEAD)
				point.the_disk = A //The pinpointer now tracks the AI core.

	ticker.mode:malf_mode_declared = 1
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/takeover


/datum/game_mode/malfunction/proc/ai_win()
	set category = "Malfunction"
	set name = "Explode"
	set desc = "Station go boom"
	if (!ticker.mode:to_nuke_or_not_to_nuke)
		return
	ticker.mode:to_nuke_or_not_to_nuke = 0
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/ai_win
	ticker.mode:explosion_in_progress = 1
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	world << "Self-destructing in 10"
	for (var/i=9 to 1 step -1)
		sleep(10)
		world << i
	sleep(10)
	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		if(ticker.mode)
			ticker.mode:station_was_nuked = 1
			ticker.mode:explosion_in_progress = 0
	return


/datum/game_mode/malfunction/declare_completion()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)

	if      ( station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - nuke")
		world << "<FONT size = 3><B>Major AI Victory</B></FONT>"
		world << "<B>The self-destruction of [station_name()] killed everyone on board!</B>"

	else if ( station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","halfwin - AI killed, staff lost control")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>The AI has been killed!</B> However, the staff have lost control of [station_name()]."

	else if ( station_captured && !malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - no explosion")
		world << "<FONT size = 3><B>Major AI Victory</B></FONT>"
		world << "<B>The AI has chosen not to detonate the station!</B>"

	else if (!station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","halfwin - everyone killed by nuke")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Everyone was killed by the nuclear blast!</B>"

	else if (!station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","loss - staff win")
		world << "<FONT size = 3><B>Major Human Victory</B></FONT>"
		world << "<B>The AI has been destroyed!</B> The staff is victorious."

	else if(!station_captured && !malf_dead && !check_ai_loc())
		feedback_set_details("round_end_result", "loss - malf ai left zlevel")
		world << "<font size=3><b>Minor Human Victory</b></font>"
		world << "<b>The malfunctioning AI has left the station's z-level and was disconnected from its systems!</b> The crew are victorious."

	else if (!station_captured && !malf_dead && !station_was_nuked && crew_evacuated)
		feedback_set_details("round_end_result","halfwin - evacuated")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Nanotrasen has lost control of [station_name()]! All surviving personnel will be fired.</B>"

	else if (!station_captured && !malf_dead && !station_was_nuked && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Round was mysteriously interrupted!</B>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_malfunction()
	if( malf_ai.len || istype(ticker.mode,/datum/game_mode/malfunction) )
		var/text = "<br><FONT size=3><B>The malfunctioning AIs were:</B></FONT>"

		for(var/datum/mind/malf in malf_ai)

			text += "<br><b>[malf.key]</b> was <b>[malf.name]</b> ("
			if(malf.current)
				if(malf.current.stat == DEAD)
					text += "deactivated"
				else
					text += "operational"
				if(malf.current.real_name != malf.name)
					text += " as <b>[malf.current.real_name]</b>"
			else
				text += "hardware destroyed"
			text += ")"
		text += "<br>"

		world << text
	return 1