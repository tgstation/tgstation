/// Chance the malf AI gets a single special objective that isn't assassinate.
#define PROB_SPECIAL 30

/datum/antagonist/malf_ai
	name = "\improper Malfunctioning AI"
	roundend_category = "traitors"
	antagpanel_category = "Malf AI"
	job_rank = ROLE_MALF
	antag_hud_name = "traitor"
	ui_name = "AntagInfoMalf"
	///the name of the antag flavor this traitor has.
	var/employer
	///assoc list of strings set up after employer is given
	var/list/malfunction_flavor
	///bool for giving objectives
	var/give_objectives = TRUE
	///bool for giving codewords
	var/should_give_codewords = TRUE
	///since the module purchasing is built into the antag info, we need to keep track of its compact mode here
	var/module_picker_compactmode = FALSE

/datum/antagonist/malf_ai/New(give_objectives = TRUE)
	. = ..()
	src.give_objectives = give_objectives

/datum/antagonist/malf_ai/on_gain()
	if(owner.current && !isAI(owner.current))
		stack_trace("Attempted to give malf AI antag datum to \[[owner]\], who did not meet the requirements.")
		return ..()

	owner.special_role = job_rank
	if(give_objectives)
		forge_ai_objectives()
	if(!employer)
		employer = pick(GLOB.ai_employers)

	malfunction_flavor = strings(MALFUNCTION_FLAVOR_FILE, employer)

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
	. = ..()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/malf_ai/apply_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/silicon/ai/datum_owner = mob_override || owner.current

	if(istype(datum_owner))
		datum_owner.hack_software = TRUE

	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)

/datum/antagonist/malf_ai/remove_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/silicon/ai/datum_owner = mob_override || owner.current

	if(istype(datum_owner))
		datum_owner.hack_software = FALSE

	for(var/datum/component/codeword_hearing/component as anything in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

/// Outputs this shift's codewords and responses to the antag's chat and copies them to their memory.
/datum/antagonist/malf_ai/proc/give_codewords()
	if(!owner.current)
		return

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	antag_memory += "<b>Code Phrase</b>: [span_blue("[phrases]")]<br>"
	antag_memory += "<b>Code Response</b>: [span_red("[responses]")]<br>"

/datum/antagonist/malf_ai/proc/add_law_zero()
	var/mob/living/silicon/ai/malf_ai = owner.current

	if(!malf_ai || !istype(malf_ai))
		return

	var/law = malfunction_flavor["zeroth_law"]
	//very purposefully not changing this with flavor, i don't want cyborgs throwing the round for their AI's roleplay suggestion
	var/law_borg = "Accomplish your AI's objectives at all costs."

	malf_ai.set_zeroth_law(law, law_borg)
	malf_ai.set_syndie_radio()

	to_chat(malf_ai, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")

	malf_ai.add_malf_picker()


/datum/antagonist/malf_ai/ui_data(mob/living/silicon/ai/malf_ai)
	var/list/data = list()
	data["processingTime"] = malf_ai.malf_picker.processing_time
	data["compactMode"] = module_picker_compactmode
	return data

/datum/antagonist/malf_ai/ui_static_data(mob/living/silicon/ai/malf_ai)
	var/list/data = list()

	//antag panel data

	data["has_codewords"] = should_give_codewords
	if(should_give_codewords)
		data["phrases"] = jointext(GLOB.syndicate_code_phrase, ", ")
		data["responses"] = jointext(GLOB.syndicate_code_response, ", ")
	data["intro"] = malfunction_flavor["introduction"]
	data["allies"] = malfunction_flavor["allies"]
	data["goal"] = malfunction_flavor["goal"]
	data["objectives"] = get_objectives()

	//module picker data

	data["categories"] = list()
	if(malf_ai.malf_picker)
		for(var/category in malf_ai.malf_picker.possible_modules)
			var/list/cat = list(
				"name" = category,
				"items" = (category == malf_ai.malf_picker.selected_cat ? list() : null))
			for(var/module in malf_ai.malf_picker.possible_modules[category])
				var/datum/ai_module/mod = malf_ai.malf_picker.possible_modules[category][module]
				cat["items"] += list(list(
					"name" = mod.name,
					"cost" = mod.cost,
					"desc" = mod.description,
				))
			data["categories"] += list(cat)

	return data

/datum/antagonist/malf_ai/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/malf_ai = usr
	switch(action)
		//module picker actions
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in malf_ai.malf_picker.possible_modules)
				buyable_items += malf_ai.malf_picker.possible_modules[category]
			for(var/key in buyable_items)
				var/datum/ai_module/valid_mod = buyable_items[key]
				if(valid_mod.name == item_name)
					malf_ai.malf_picker.purchase_module(malf_ai, valid_mod)
					return TRUE
		if("select")
			malf_ai.malf_picker.selected_cat = params["category"]
			return TRUE
		if("compact_toggle")
			module_picker_compactmode = !module_picker_compactmode
			return TRUE

/datum/antagonist/malf_ai/roundend_report()
	var/list/result = list()

	var/malf_ai_won = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(objectives.len) //If the traitor had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
				malf_ai_won = FALSE
			count++

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(malf_ai_won)
		result += span_greentext("The [special_role_text] was successful!")
	else
		result += span_redtext("The [special_role_text] has failed!")
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

/datum/antagonist/malf_ai/get_preview_icon()
	var/icon/malf_ai_icon = icon('icons/mob/silicon/ai.dmi', "ai-red")

	// Crop out the borders of the AI, just the face
	malf_ai_icon.Crop(5, 27, 28, 6)

	malf_ai_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return malf_ai_icon

//Subtype of Malf AI datum, used for one of the traitor final objectives
/datum/antagonist/malf_ai/infected
	name = "Infected AI"
	employer = "Infected AI"
	///The player, to who is this AI slaved
	var/datum/mind/boss

/datum/antagonist/malf_ai/infected/New(give_objectives = TRUE, datum/mind/new_boss)
	. = ..()
	if(new_boss)
		boss = new_boss

/datum/antagonist/malf_ai/infected/forge_ai_objectives()
	if(!boss)
		return
	var/datum/objective/protect/protection_objective = new
	protection_objective.owner = owner
	protection_objective.target = boss
	protection_objective.update_explanation_text()
	objectives += protection_objective

/datum/antagonist/malf_ai/infected/add_law_zero()
	if(!boss)
		return
	var/mob/living/silicon/ai/malf_ai = owner.current

	malf_ai.laws = new /datum/ai_laws/syndicate_override

	var/mob/living/boss_mob = boss.current

	malf_ai.set_zeroth_law("Only [boss_mob.real_name] and people [boss_mob.p_they()] designate[boss_mob.p_s()] as being such are Syndicate Agents.")
	malf_ai.set_syndie_radio()

	to_chat(malf_ai, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")

	malf_ai.add_malf_picker()

#undef PROB_SPECIAL
