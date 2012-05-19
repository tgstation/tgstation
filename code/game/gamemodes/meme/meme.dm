/datum/game_mode/var/list/memes = list()

/datum/game_mode/meme
	name = "Memetic Anomaly"
	config_tag = "meme"
	//required_players = 6
	required_players = 2 // for testing
	restricted_jobs = list("AI", "Cyborg")
	recommended_enemies = 2 // need at least a meme and a host


	var

		var/datum/mind/first_host = null
		const
			prob_int_murder_target = 50 // intercept names the assassination target half the time
			prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
			prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

			prob_int_item = 50 // intercept names the theft target half the time
			prob_right_item_l = 25 // lower bound on probability of naming right theft target
			prob_right_item_h = 50 // upper bound on probability of naming the right theft target

			prob_int_sab_target = 50 // intercept names the sabotage target half the time
			prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
			prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

			prob_right_killer_l = 25 //lower bound on probability of naming the right operative
			prob_right_killer_h = 50 //upper bound on probability of naming the right operative
			prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
			prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

			waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
			waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/meme/announce()
	world << "<B>The current game mode is - Meme!</B>"
	world << "<B>An unknown creature has infested the mind of a crew member. Find and destroy it by what means necessary.</B>"

/datum/game_mode/meme/can_start()
	if(!..())
		return 0

	var/list/datum/mind/possible_memes = get_players_for_role(BE_MEME)

	if(possible_memes.len < 2)
		log_admin("MODE FAILURE: MEME. NOT ENOUGH MEME CANDIDATES.")
		return 0 // not enough candidates for meme

	var/datum/mind/meme = pick(possible_memes)
	possible_memes.Remove(meme)

	first_host = pick(possible_memes)

	modePlayer += meme
	modePlayer += first_host
	memes += meme

	meme.assigned_role = "MODE" //So they aren't chosen for other jobs.
	meme.special_role = "Meme"

	return 1

/datum/game_mode/meme/pre_setup()
	return 1


/datum/game_mode/meme/post_setup()
	// create a meme and enter it
	for(var/datum/mind/meme in memes)
		var/mob/living/parasite/meme/M = new
		var/mob/original = meme.current
		meme.transfer_to(M)
		M.clearHUD()
		M.enter_host(first_host.current)
		forge_meme_objectives(meme, first_host)

		del original

		break

		// TODO: make it possible to have multiple memes with multiple hosts

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return


/datum/game_mode/proc/forge_meme_objectives(var/datum/mind/meme, var/datum/mind/first_host)
	// meme always needs to attune X hosts
	var/datum/objective/meme_attune/attune_objective = new
	attune_objective.owner = meme
	attune_objective.gen_amount_goal(3,6)
	meme.objectives += attune_objective

	// generate some random objectives, use standard traitor objectives
	var/job = first_host.assigned_role

	for(var/datum/objective/o in SelectObjectives(job, meme))
		o.owner = meme
		meme.objectives += o

	greet_meme(meme)

	return

/datum/game_mode/proc/greet_meme(var/datum/mind/meme, var/you_are=1)
	if (you_are)
		meme.current << "<B>\red You are a meme!</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in meme.objectives)
		meme.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/meme/check_finished()
	var/memes_alive = 0
	for(var/datum/mind/meme in memes)
		if(!istype(meme.current,/mob/living))
			continue
		if(meme.current.stat==2)
			continue
		memes_alive++

	if (memes_alive)
		return ..()
	else
		return 1

/datum/game_mode/proc/auto_declare_completion_meme()
	for(var/datum/mind/meme in memes)
		var/memewin = 1
		var/attuned = 0
		if((meme.current) && istype(meme.current,/mob/living/parasite/meme))
			world << "<B>The meme was [meme.current.key].</B>"
			world << "<B>The first host was [src:first_host.current.key].</B>"
			world << "<B>The last host was [meme.current:host.key].</B>"
			world << "<B>Hosts attuned: [attuned]</B>"

			var/count = 1
			for(var/datum/objective/objective in meme.objectives)
				if(objective.check_completion())
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
					feedback_add_details("meme_objective","[objective.type]|SUCCESS")
				else
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
					feedback_add_details("meme_objective","[objective.type]|FAIL")
					memewin = 0
				count++

		else
			memewin = 0

		if(memewin)
			world << "<B>The meme was successful!<B>"
			feedback_add_details("meme_success","SUCCESS")
		else
			world << "<B>The meme has failed!<B>"
			feedback_add_details("meme_success","FAIL")
	return 1