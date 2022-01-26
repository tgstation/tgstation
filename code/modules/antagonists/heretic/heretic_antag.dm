

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 */
/proc/generate_heretic_text(length = 25)
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/// The heretic antagonist itself.
/datum/antagonist/heretic
	name = "\improper Heretic"
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
	var/high_value_sacrifices = 0
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
		knowledge_data["cost"] = found_knowledge.cost
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
	RegisterSignal(owner.current, COMSIG_LIVING_DEATH, .proc/on_death)

	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current)

	GLOB.reality_smash_track.RemoveMind(owner)
	on_death()
	UnregisterSignal(owner.current, COMSIG_LIVING_DEATH)

	return ..()

///What happens to the heretic once he dies, used to remove any custom perks
/datum/antagonist/heretic/proc/on_death()
	SIGNAL_HANDLER

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_death(owner.current)

/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/datum/objective/heretic_research/research_objective = new()
	research_objective.owner = owner
	objectives += research_objective

	var/datum/objective/minor_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	objectives += sac_objective

	var/datum/objective/major_sacrifice/other_sac_objective = new()
	other_sac_objective.owner = owner
	objectives += other_sac_objective

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Ancient knowledge described in the book allows you to overcome your clownish nature, allowing you to use complex items effectively.")
	our_mob.faction |= "heretics"
	RegisterSignal(our_mob, COMSIG_MOB_PRE_CAST_SPELL, .proc/spell_check)

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.faction -= "heretics"
	UnregisterSignal(our_mob, COMSIG_MOB_PRE_CAST_SPELL)

/*
 * Signal proc for [COMSIG_MOB_PRE_CAST_SPELL].
 *
 * Checks if our heretic has TRAIT_ALLOW_HERETIC_CASTING.
 * If so, allow them to cast like normal.
 * If not, cancel the cast.
 */
/datum/antagonist/heretic/proc/spell_check(datum/source, obj/effect/proc_holder/spell/spell)
	SIGNAL_HANDLER

	// Heretic spells are of the forbidden school, otherwise we don't care
	if(spell.school != SCHOOL_FORBIDDEN)
		return

	// If we've got the trait, we don't care
	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return

	// We shouldn't be able to cast this! Cancel it.
	return COMPONENT_CANCEL_SPELL

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				succeeded = FALSE
			count++

	if(ascended)
		parts += "<span class='greentext big'>THE HERETIC ASCENDED!</span>"

	else
		if(succeeded)
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

/*
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type)
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	researched_knowledge[knowledge_type] = initialized_knowledge
	initialized_knowledge.on_gain(owner.current)
	return TRUE

/*
 * Get a list of all knowledge TYPEPATHS that we can currently research.
 */
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

/*
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/*
 * Returns all research knowledge. Assoc list of [typepath] to [instance].
 */
/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

////////////////
// Objectives //
////////////////

/datum/objective/minor_sacrifice
	name = "minor sacrifice"

/datum/objective/minor_sacrifice/New(text)
	. = ..()
	target_amount = rand(2, 3)
	update_explanation_text()

/datum/objective/minor_sacrifice/update_explanation_text()
	. = ..()
	explanation_text = "Sacrifice at least [target_amount] crewmembers."

/datum/objective/minor_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return heretic_datum.total_sacrifices >= target_amount

/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Sacrifice a high value crewmember."

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return heretic_datum.high_value_sacrifices >= target_amount

/datum/objective/heretic_research
	name = "research"
	target_amount = 9 // 9's the length of the main paths, so basically make people take some side nodes

/datum/objective/heretic_research/New(text)
	. = ..()
	target_amount += length(GLOB.heretic_start_knowledge) + rand(3, 4)
	update_explanation_text()

/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus."

/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return length(heretic_datum.researched_knowledge) >= target_amount

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/outfit/heretic/post_equip(mob/living/carbon/human/equipper, visualsOnly)
	var/obj/item/clothing/suit/hooded/hooded = locate() in equipper
	hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
	hooded.ToggleHood()
