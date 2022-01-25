/datum/antagonist/heretic
	name = "Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	ui_name = "AntagInfoHeretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic"
	hijack_speed = 0.5
	suicide_cry = "THE MANSUS SMILES UPON ME!!"
	preview_outfit = /datum/outfit/heretic
	var/give_objectives = TRUE
	var/knowledge_points = 1
	var/list/researched_knowledge = list()
	var/total_sacrifices = 0
	var/ascended = FALSE

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	data["charges"] = knowledge_points

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		var/list/knowledge_data = list()
		knowledge_data["type"] = knowledge
		knowledge_data["name"] = initial(knowledge.name)
		knowledge_data["cost"] = initial(knowledge.cost)
		knowledge_data["disabled"] = initial(knowledge.cost) > knowledge_points
		knowledge_data["path"] = initial(knowledge.route)
		knowledge_data["state"] = "Research"
		knowledge_data["flavour"] = initial(knowledge.gain_text)
		knowledge_data["desc"] = initial(knowledge.desc)

		data["learnable_knowledge"] += list(knowledge_data)

	for(var/path in researched_knowledge)
		var/list/knowledge_data = list()
		var/datum/heretic_knowledge/found_knowledge = researched_knowledge[path]
		knowledge_data["name"] = found_knowledge.name
		loknowledge_datare["cost"] = found_knowledge.cost
		knowledge_data["disabled"] = TRUE
		knowledge_data["path"] = found_knowledge.route
		knowledge_data["state"] = "Researched"
		knowledge_data["flavour"] = found_knowledge.gain_text
		knowledge_data["desc"] = found_knowledge.desc

		data["learned_knowledge"] += list(knowledge_data)

	return data

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()

	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["objectives"] = get_objectives()

	return data

/datum/antagonist/heretic/greet()
	. = ..()
	to_chat(owner, span_cult("<span class='warningplain'>The book whispers softly, its forbidden knowledge walks this plane once again!</span>"))
	var/policy = get_policy(ROLE_HERETIC)
	if(policy)
		to_chat(owner, policy)

/datum/antagonist/heretic/farewell()
	to_chat(owner.current, span_userdanger("Your mind begins to flare as the otherwordly knowledge escapes your grasp!"))
	owner.announce_objectives()

/datum/antagonist/heretic/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// MOTHBLOCKS TOOD: Copied and pasted from cult, make this its own proc

	// The sickly blade is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/sickly_blade/blade = new
	icon.Blend(icon(blade.lefthand_file, blade.inhand_icon_state), ICON_OVERLAY)
	qdel(blade)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/heretic/on_gain()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge)

	if(give_objectives)
		forge_primary_objectives()

	GLOB.reality_smash_track.AddMind(owner)
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(owner.current, COMSIG_LIVING_DEATH, .proc/on_death)

	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current)

	GLOB.reality_smash_track.RemoveMind(owner)
	STOP_PROCESSING(SSprocessing, src)
	on_death()

	return ..()

/datum/antagonist/heretic/process()

	if(owner.current.stat == DEAD)
		return

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_life(owner.current)

///What happens to the heretic once he dies, used to remove any custom perks
/datum/antagonist/heretic/proc/on_death()
	SIGNAL_HANDLER

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_death(owner.current)

/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/list/assasination = list()
	var/list/protection = list()

	var/choose_list_begin = list("assassinate","protect")
	var/choose_list_end = list("assassinate","hijack","protect","glory")

	var/pck1 = pick(choose_list_begin)
	var/pck2 = pick(choose_list_end)

	forge_objective(pck1,assasination,protection)
	forge_objective(pck2,assasination,protection)

	var/datum/objective/sacrifice_ecult/sac_objective = new
	sac_objective.owner = owner
	sac_objective.update_explanation_text()
	objectives += sac_objective

/datum/antagonist/heretic/proc/forge_objective(string,assasination,protection)
	switch(string)
		if("assassinate")
			var/datum/objective/assassinate/kill = new
			kill.owner = owner
			var/list/owners = kill.get_owners()
			kill.find_target(owners,protection)
			assasination += kill.target
			objectives += kill
		if("hijack")
			var/datum/objective/hijack/hijack = new
			hijack.owner = owner
			objectives += hijack
		if("glory")
			var/datum/objective/martyr/martyrdom = new
			martyrdom.owner = owner
			objectives += martyrdom
		if("protect")
			var/datum/objective/protect/protect = new
			protect.owner = owner
			var/list/owners = protect.get_owners()
			protect.find_target(owners,assasination)
			protection += protect.target
			objectives += protect

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, mob_override ? null : "Ancient knowledge described in the book allows you to overcome your clownish nature, allowing you to use complex items effectively.")
	current.faction |= "heretics"

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= "heretics"

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/cultiewin = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(length(objectives))
		var/count = 1
		for(var/o in objectives)
			var/datum/objective/objective = o
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!</b>")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				cultiewin = FALSE
			count++
	if(ascended)
		parts += "<span class='greentext big'>THE HERETIC ASCENDED!</span>"
	else
		if(cultiewin)
			parts += span_greentext("The heretic was successful!")
		else
			parts += span_redtext("The heretic has failed.")

	parts += "<b>Knowledge Researched:</b> "

	var/list/knowledge_message = list()
	var/list/researched_knowledge = get_all_knowledge()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge_message += "[knowledge.name]"
	parts += knowledge_message.Join(", ")

	return parts.Join("<br>")

////////////////
// Knowledge //
////////////////

/datum/antagonist/heretic/proc/gain_knowledge(datum/eldritch_knowledge/knowledge)
	if(get_knowledge(knowledge))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge
	researched_knowledge[initialized_knowledge.type] = initialized_knowledge
	initialized_knowledge.on_gain(owner.current)
	return TRUE

/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		researchable_knowledge |= knowledge.next_knowledge
		banned_knowledge |= knowledge.banned_knowledge
		banned_knowledge |= knowledge.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

////////////////
// Objectives //
////////////////

/datum/objective/sacrifice_ecult
	name = "sacrifice"

/datum/objective/sacrifice_ecult/update_explanation_text()
	. = ..()
	target_amount = rand(2,6)
	explanation_text = "Sacrifice at least [target_amount] people."

/datum/objective/sacrifice_ecult/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.total_sacrifices >= target_amount

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/outfit/heretic/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/clothing/suit/hooded/hooded = locate() in H
	hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
	hooded.ToggleHood()
