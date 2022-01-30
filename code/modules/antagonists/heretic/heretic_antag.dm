

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
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
	/// Whether we give this antagonist objectives on gain.
	var/give_objectives = TRUE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// A list of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed.
	var/high_value_sacrifices = 0
	/// Lazylist of weakrefs to humans that we have as targets.
	var/list/datum/weakref/sac_targets
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// A static typecache of all tools we can scribe with.
	var/static/list/scribing_tools = typecacheof(list(/obj/item/pen, /obj/item/toy/crayon))
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	var/static/list/path_to_color = list(
		PATH_START = "grey",
		PATH_SIDE = "green",
		PATH_RUST = "brown",
		PATH_FLESH = "red",
		PATH_ASH = "white",
		PATH_VOID = "blue",
	)

	data["charges"] = knowledge_points

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		var/list/knowledge_data = list()
		knowledge_data["path"] = knowledge
		knowledge_data["name"] = initial(knowledge.name)
		knowledge_data["desc"] = initial(knowledge.desc)
		knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
		knowledge_data["cost"] = initial(knowledge.cost)
		knowledge_data["disabled"] = (initial(knowledge.cost) > knowledge_points)

		// Final knowledge can't be learned until all objectives are complete.
		if(ispath(knowledge, /datum/heretic_knowledge/final))
			for(var/datum/objective/must_be_done as anything in objectives)
				if(!must_be_done.check_completion())
					knowledge_data["disabled"] = TRUE

		knowledge_data["hereticPath"] = initial(knowledge.route)
		knowledge_data["color"] = path_to_color?[initial(knowledge.route)] || "grey"

		data["learnableKnowledge"] += list(knowledge_data)

	for(var/path in researched_knowledge)
		var/list/knowledge_data = list()
		var/datum/heretic_knowledge/found_knowledge = researched_knowledge[path]
		knowledge_data["name"] = found_knowledge.name
		knowledge_data["desc"] = found_knowledge.desc
		knowledge_data["gainFlavor"] = found_knowledge.gain_text
		knowledge_data["cost"] = found_knowledge.cost
		knowledge_data["hereticPath"] = found_knowledge.route
		knowledge_data["color"] = path_to_color?[found_knowledge.route] || "grey"

		data["learnedKnowledge"] += list(knowledge_data)

	return data

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()

	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["objectives"] = get_objectives()

	return data

/datum/antagonist/heretic/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path))
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path])")

			if(initial(researched_path.cost) > knowledge_points)
				return
			if(!gain_knowledge(researched_path))
				return

			log_codex_ciatrix("[key_name(owner)] gained knowledge: [initial(researched_path.name)]")
			knowledge_points -= initial(researched_path.cost)
			return TRUE

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE
	return ..()

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

/datum/antagonist/heretic/greet()
	. = ..()
	var/policy = get_policy(ROLE_HERETIC)
	if(policy)
		to_chat(owner, policy)

/datum/antagonist/heretic/farewell()
	if(!silent)
		to_chat(owner.current, span_userdanger("Your mind begins to flare as the otherwordly knowledge escapes your grasp!"))
	return ..()

/datum/antagonist/heretic/on_gain()
	if(give_objectives)
		forge_primary_objectives()

	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge)

	GLOB.reality_smash_track.add_tracked_mind(owner)
	addtimer(CALLBACK(src, .proc/passive_influence_gain), passive_gain_timer) // Gain +1 knowledge every 20 minutes.
	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current)

	GLOB.reality_smash_track.remove_tracked_mind(owner)
	QDEL_LIST_ASSOC_VAL(researched_knowledge)
	return ..()

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Ancient knowledge described to you has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	our_mob.faction |= FACTION_HERETIC
	RegisterSignal(our_mob, COMSIG_MOB_PRE_CAST_SPELL, .proc/on_spell_cast)
	RegisterSignal(our_mob, COMSIG_MOB_ITEM_AFTERATTACK, .proc/on_item_afterattack)
	RegisterSignal(our_mob, COMSIG_MOB_LOGIN, .proc/fix_influence_network)

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.faction -= FACTION_HERETIC
	UnregisterSignal(our_mob, list(COMSIG_MOB_PRE_CAST_SPELL, COMSIG_MOB_ITEM_AFTERATTACK, COMSIG_MOB_LOGIN))

/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(old_body)
		knowledge.on_gain(new_body)

/*
 * Signal proc for [COMSIG_MOB_PRE_CAST_SPELL].
 *
 * Checks if our heretic has TRAIT_ALLOW_HERETIC_CASTING.
 * If so, allow them to cast like normal.
 * If not, cancel the cast.
 */
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, obj/effect/proc_holder/spell/spell)
	SIGNAL_HANDLER

	// Heretic spells are of the forbidden school, otherwise we don't care
	if(spell.school != SCHOOL_FORBIDDEN)
		return

	// If we've got the trait, we don't care
	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return
	// All powerful, don't care
	if(ascended)
		return

	// We shouldn't be able to cast this! Cancel it.
	source.balloon_alert(source, "you need a focus!")
	return COMPONENT_CANCEL_SPELL

/*
 * Signal proc for [COMSIG_MOB_ITEM_AFTERATTACK].
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_afterattack(mob/living/source, atom/target, obj/item/weapon, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(weapon, scribing_tools))
		return
	if(!isturf(target) || !isliving(source) || !proximity_flag)
		return

	var/obj/item/offhand = source.get_inactive_held_item()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target))
		if(!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			target.balloon_alert(source, "invalid placement for rune!")
			return

	if(locate(/obj/effect/heretic_rune/big) in range(3, target))
		target.balloon_alert(source, "to close to another rune!")
		return

	if(drawing_rune)
		source.balloon_alert(source, "already drawing a rune!")
		return

	INVOKE_ASYNC(src, .proc/draw_rune, source, weapon, target)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * scribing_tool - the object being used to draw the rune
 * * target_turf - the place the rune's being drawn
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, obj/item/scribing_tool, turf/target_turf)
	drawing_rune = TRUE

	target_turf.balloon_alert(user, "drawing rune...")
	if(!do_after(user, 30 SECONDS, target_turf, extra_checks = CALLBACK(src, .proc/rune_drawing_checks, user, scribing_tool)))
		target_turf.balloon_alert(user, "interrupted!")
		drawing_rune = FALSE
		return

	target_turf.balloon_alert(user, "rune created")
	new /obj/effect/heretic_rune/big(target_turf)
	drawing_rune = FALSE

/**
 * Callback for use in draw_rune to check that the user
 * doesn't drop their tool or hide their hand.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * scribing_tool - the object being used to draw the rune
 */
/datum/antagonist/heretic/proc/rune_drawing_checks(mob/living/user, obj/item/scribing_tool)

	var/obj/item/mainhand = user.get_active_held_item()
	if(QDELETED(mainhand) || mainhand != scribing_tool)
		return FALSE

	var/obj/item/offhand = user.get_inactive_held_item()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return FALSE

	return TRUE

/*
 * Signal proc for [COMSIG_MOB_LOGIN].
 *
 * Calls rework_network() on our reality smash tracker
 * whenever a login / client change happens, to ensure
 * influence client visibility is fixed.
 */
/datum/antagonist/heretic/proc/fix_influence_network(mob/source)
	SIGNAL_HANDLER

	GLOB.reality_smash_track.rework_network()

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/datum/objective/heretic_research/research_objective = new()
	research_objective.owner = owner
	objectives += research_objective

	var/num_heads = 0
	for(var/mob/player in GLOB.alive_player_list)
		if(player.mind.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			num_heads++

	var/datum/objective/minor_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount += 2
		sac_objective.update_explanation_text()
	objectives += sac_objective

	if(num_heads >= 2)
		var/datum/objective/major_sacrifice/other_sac_objective = new()
		other_sac_objective.owner = owner
		objectives += other_sac_objective

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	knowledge_points++
	to_chat(owner.current, "[span_hear("You hear a whisper...")] [span_hypnophrase(pick(strings(HERETIC_INFLUENCE_FILE, "drain_message")))]")
	addtimer(CALLBACK(src, .proc/passive_influence_gain), passive_gain_timer)

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

/datum/antagonist/heretic/get_admin_commands()
	. = ..()
	.["Add Heart Target (Marked Mob)"] = CALLBACK(src, .proc/add_marked_as_target)
	.["Remove Heart Target"] = CALLBACK(src, .proc/remove_target)
	.["Adjust Knowledge Points"] = CALLBACK(src, .proc/admin_change_points)

/*
 * Admin proc for adding a marked mob to a heretic's sac list.
 */
/datum/antagonist/heretic/proc/add_marked_as_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, span_warning("You need to mark a human to do this!"))
		return

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, span_danger("The Mansus has modified your targets. Go find them!"))
		to_chat(owner.current, span_danger("[new_target.real_name], the [new_target.mind?.assigned_role || "human"]."))

	LAZYADD(sac_targets, WEAKREF(new_target))

/*
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/list/removable = list()
	for(var/datum/weakref/ref as anything in sac_targets)
		var/mob/living/carbon/human/old_target = ref?.resolve()
		if(!QDELETED(old_target))
			removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Choose a human to remove", "Who to Spare", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return
	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return
	if(!(WEAKREF(chosen_target) in sac_targets))
		return

	LAZYREMOVE(sac_targets, WEAKREF(chosen_target))

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, span_danger("The Mansus has modified your targets."))

/*
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/change_num = tgui_input_number(admin, "Add or remove knowledge points", "Points", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	knowledge_points += change_num

/*
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type)
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	researched_knowledge[knowledge_type] = initialized_knowledge
	initialized_knowledge.on_research(owner.current)
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

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
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

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Sacrifice 1 high value crewmember."

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return heretic_datum.high_value_sacrifices >= target_amount

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	name = "research"
	/// The length of a main path. Calculated once in New().
	var/static/main_path_length = 0

/datum/objective/heretic_research/New(text)
	. = ..()

	if(!main_path_length)
		// Let's find the length of a main path. We'll use rust because it's the coolest.
		// (All the main paths are (should be) the same length, so it doesn't matter.)
		var/rust_paths_found = 0
		for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
			if(initial(knowledge.route) == PATH_RUST)
				rust_paths_found++

		main_path_length = rust_paths_found

	// Factor in the length of the main path first.
	target_amount = main_path_length
	// Add in the base research we spawn with, otherwise it'd be too easy.
	target_amount += length(GLOB.heretic_start_knowledge)
	// And add in some buffer, to require some sidepathing.
	target_amount += rand(2, 4)
	update_explanation_text()

/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus. You start with [length(GLOB.heretic_start_knowledge)] researched."

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
