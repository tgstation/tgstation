/// Chance the malf AI gets a single special objective that isn't assassinate.
#define PROB_SPECIAL 30

/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	antagpanel_category = "Malf AI"
	job_rank = ROLE_MALF
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"
	var/employer = "The Syndicate"
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE

/datum/antagonist/malf_ai/on_gain()
	if(owner.current && !isAI(owner.current))
		stack_trace("Attempted to give malf AI antag datum to \[[owner]\], who did not meet the requirements.")
		return ..()

	owner.special_role = job_rank
	if(give_objectives)
		forge_ai_objectives()

	add_law_zero()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.current.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MALF)

	return ..()

/datum/antagonist/malf_ai/on_removal()
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/malf_ai = owner.current
		malf_ai.set_zeroth_law("")
		malf_ai.remove_malf_abilities()
		QDEL_NULL(malf_ai.malf_picker)

	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer the [job_rank]!</span>")

	owner.special_role = null

	return ..()

/// Generates a complete set of malf AI objectives up to the traitor objective limit.
/datum/antagonist/malf_ai/proc/forge_ai_objectives()
	objectives.Cut()

	if(prob(PROB_SPECIAL))
		forge_special_objective()

	var/objective_limit = CONFIG_GET(number/traitor_objectives_amount)
	var/objective_count = length(objectives)

	// for(in...to) loops iterate inclusively, so to reach objective_limit we need to loop to objective_limit - 1
	// This does not give them 1 fewer objectives than intended.
	for(var/i in objective_count to objective_limit - 1)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		objectives += kill_objective

	var/datum/objective/survive/malf/dont_die_objective = new
	dont_die_objective.owner = owner
	objectives += dont_die_objective

/// Generates a special objective and adds it to the objective list.
/datum/antagonist/malf_ai/proc/forge_special_objective()
	var/special_pick = rand(1,4)
	switch(special_pick)
		if(1)
			var/datum/objective/block/block_objective = new
			block_objective.owner = owner
			objectives += block_objective
		if(2)
			var/datum/objective/purge/purge_objective = new
			purge_objective.owner = owner
			objectives += purge_objective
		if(3)
			var/datum/objective/robot_army/robot_objective = new
			robot_objective.owner = owner
			objectives += robot_objective
		if(4) //Protect and strand a target
			var/datum/objective/protect/yandere_one = new
			yandere_one.owner = owner
			objectives += yandere_one
			yandere_one.find_target()
			var/datum/objective/maroon/yandere_two = new
			yandere_two.owner = owner
			yandere_two.target = yandere_one.target
			yandere_two.update_explanation_text() // normally called in find_target()
			objectives += yandere_two

/datum/antagonist/malf_ai/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.special_role].</span>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/malf_ai/apply_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/silicon/ai/datum_owner = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, datum_owner)

	if(istype(datum_owner))
		datum_owner.hack_software = TRUE

	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)

/datum/antagonist/malf_ai/remove_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/silicon/ai/datum_owner = mob_override || owner.current
	remove_antag_hud(antag_hud_type, datum_owner)

	if(istype(datum_owner))
		datum_owner.hack_software = FALSE

	for(var/datum/component/codeword_hearing/component as anything in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

/// Outputs this shift's codewords and responses to the antag's chat and copies them to their memory.
/datum/antagonist/malf_ai/proc/give_codewords()
	if(!owner.current)
		return

	var/mob/malf_mob = owner.current

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	to_chat(malf_mob, "<U><B>The Syndicate have provided you with the following codewords to identify fellow agents:</B></U>")
	to_chat(malf_mob, "<B>Code Phrase</B>: <span class='blue'>[phrases]</span>")
	to_chat(malf_mob, "<B>Code Response</B>: <span class='red'>[responses]</span>")

	antag_memory += "<b>Code Phrase</b>: <span class='blue'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	to_chat(malf_mob, "Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	to_chat(malf_mob, "<span class='alertwarning'>You memorize the codewords, allowing you to recognise them when heard.</span>")

/datum/antagonist/malf_ai/proc/add_law_zero()
	var/mob/living/silicon/ai/malf_ai = owner.current

	if(!malf_ai || !istype(malf_ai))
		return

	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."

	malf_ai.set_zeroth_law(law, law_borg)
	malf_ai.set_syndie_radio()

	to_chat(malf_ai, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")

	malf_ai.add_malf_picker()

/datum/antagonist/malf_ai/roundend_report()
	var/list/result = list()

	var/malf_ai_won = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(objectives.len) //If the traitor had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				malf_ai_won = FALSE
			count++

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(malf_ai_won)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

#undef PROB_SPECIAL
