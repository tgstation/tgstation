

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_heretic_text(length = 25)
	if(!isnum(length)) // stupid thing so we can use this directly in replacetext
		length = 25
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
	pref_flag = ROLE_HERETIC
	antag_hud_name = "heretic"
	hijack_speed = 0.5
	suicide_cry = "THE MANSUS SMILES UPON ME!!"
	preview_outfit = /datum/outfit/heretic
	can_assign_self_objectives = TRUE
	default_custom_objective = "Turn a department into a testament for your dark knowledge."
	hardcore_random_bonus = TRUE
	stinger_sound = 'sound/music/antag/heretic/heretic_gain.ogg'
	antag_flags = parent_type::antag_flags | ANTAG_OBSERVER_VISIBLE_PANEL

	/// Whether we give this antagonist objectives on gain.
	var/give_objectives = TRUE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// The path our heretic has chosen. Mostly used for flavor.
	var/heretic_path = PATH_START
	/// A sum of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// The organ slot we place our Living Heart in.
	var/living_heart_organ_slot = ORGAN_SLOT_HEART
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed. (Heads of staff)
	var/high_value_sacrifices = 0
	/// Lazy assoc list of [refs to humans] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/mob/living/carbon/human/sac_targets
	/// List of all sacrifice target's names, used for end of round report
	var/list/all_sac_targets = list()
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// A static typecache of all tools we can scribe with.
	var/static/list/scribing_tools = typecacheof(list(/obj/item/pen, /obj/item/toy/crayon))
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))
	/// Controls what types of turf we can spread rust to, increases as we unlock more powerful rust abilites
	var/rust_strength = 0
	/// Wether we are allowed to ascend
	var/feast_of_owls = FALSE

	/// List that keeps track of which items have been gifted to the heretic after a cultist was sacrificed. Used to alter drop chances to reduce dupes.
	var/list/unlocked_heretic_items = list(
		/obj/item/melee/sickly_blade/cursed = 0,
		/obj/item/clothing/neck/heretic_focus/crimson_medallion = 0,
		/mob/living/basic/construct/harvester/heretic = 0,
	)
	/// Simpler version of above used to limit amount of loot that can be hoarded
	var/rewards_given = 0

/datum/antagonist/heretic/Destroy()
	LAZYNULL(sac_targets)
	return ..()

/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	//basic icon parameters
	var/icon_path = 'icons/mob/actions/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = knowledge.research_tree_icon_frame
	var/icon_dir = knowledge.research_tree_icon_dir
	//can't imagine why you would want this one, so it can't be overridden by the knowledge
	var/icon_moving = 0

	//item transmutation knowledge does not generate its own icon due to implementation difficulties, the icons have to be specified in the override vars

	//if the knowledge has a special icon, use that
	if(!isnull(knowledge.research_tree_icon_path))
		icon_path = knowledge.research_tree_icon_path
		icon_state = knowledge.research_tree_icon_state

	//if the knowledge is a spell, use the spell's button
	else if(ispath(knowledge,/datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/result_action = spell_knowledge.action_to_add
		icon_path = result_action.button_icon
		icon_state = result_action.button_icon_state

	//if the knowledge is a summon, use the mob sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/summon))
		var/datum/heretic_knowledge/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = summon_knowledge.mob_to_summon
		icon_path = result_mob.icon
		icon_state = result_mob.icon_state

	//if the knowledge is an eldritch mark, use the mark sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/mark))
		var/datum/heretic_knowledge/mark/mark_knowledge = knowledge
		var/datum/status_effect/eldritch/mark_effect = mark_knowledge.mark_type
		icon_path = mark_effect.effect_icon
		icon_state = mark_effect.effect_icon_state

	//if the knowledge is an ascension, use the achievement sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/ultimate))
		var/datum/heretic_knowledge/ultimate/ascension_knowledge = knowledge
		var/datum/award/achievement/misc/achievement = ascension_knowledge.ascension_achievement
		if(!isnull(achievement))
			icon_path = achievement.icon
			icon_state = achievement.icon_state

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, done)

	var/list/knowledge_data = list()

	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = initial(knowledge.cost)
	knowledge_data["disabled"] = (!done) && (initial(knowledge.cost) > knowledge_points)
	knowledge_data["bgr"] = GLOB.heretic_research_tree[knowledge][HKT_UI_BGR]
	knowledge_data["finished"] = done
	knowledge_data["ascension"] = ispath(knowledge,/datum/heretic_knowledge/ultimate)

	//description of a knowledge might change, make sure we are not shown the initial() value in that case
	if(done)
		var/datum/heretic_knowledge/knowledge_instance = researched_knowledge[knowledge]
		knowledge_data["desc"] = knowledge_instance.desc
	else
		knowledge_data["desc"] = initial(knowledge.desc)

	return knowledge_data

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	data["charges"] = knowledge_points
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended

	var/list/tiers = list()

	// This should be cached in some way, but the fact that final knowledge
	// has to update its disabled state based on whether all objectives are complete,
	// makes this very difficult. I'll figure it out one day maybe
	for(var/datum/heretic_knowledge/knowledge as anything in researched_knowledge)
		var/list/knowledge_data = get_knowledge_data(knowledge,TRUE)

		while(GLOB.heretic_research_tree[knowledge][HKT_DEPTH] > tiers.len)
			tiers += list(list("nodes"=list()))

		tiers[GLOB.heretic_research_tree[knowledge][HKT_DEPTH]]["nodes"] += list(knowledge_data)

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		var/list/knowledge_data = get_knowledge_data(knowledge,FALSE)

		// Final knowledge can't be learned until all objectives are complete.
		if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
			knowledge_data["disabled"] ||= !can_ascend()

		while(GLOB.heretic_research_tree[knowledge][HKT_DEPTH] > tiers.len)
			tiers += list(list("nodes"=list()))

		tiers[GLOB.heretic_research_tree[knowledge][HKT_DEPTH]]["nodes"] += list(knowledge_data)

	data["knowledge_tiers"] = tiers

	return data

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()

	data["objectives"] = get_objectives()
	data["can_change_objective"] = can_assign_self_objectives

	return data

/datum/antagonist/heretic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path, /datum/heretic_knowledge))
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path || "invalid path"])")
			if(!(researched_path in get_researchable_knowledge()))
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn knowledge they can't learn!")
				CRASH("Heretic attempted to learn knowledge they can't learn! (Got: [researched_path])")
			if(ispath(researched_path, /datum/heretic_knowledge/ultimate) && !can_ascend())
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn ascension knowledge without completing objectives!")
				CRASH("Heretic attempted to learn a final knowledge despite not being able to ascend!")
			if(initial(researched_path.cost) > knowledge_points)
				return TRUE
			if(!gain_knowledge(researched_path))
				return TRUE

			log_heretic_knowledge("[key_name(owner)] gained knowledge: [initial(researched_path.name)]")
			knowledge_points -= initial(researched_path.cost)
			return TRUE

/datum/antagonist/heretic/submit_player_objective(retain_existing = FALSE, retain_escape = TRUE, force = FALSE)
	if (isnull(owner) || isnull(owner.current))
		return
	var/confirmed = tgui_alert(
		owner.current,
		message = "Are you sure? You will no longer be able to Ascend.",
		title = "Reject the call?",
		buttons = list("Yes", "No"),
	) == "Yes"
	if (!confirmed)
		return
	return ..()

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(isnull(owner.current) || owner.current.stat == DEAD) // If the owner is dead, we can't show the UI.
		return UI_UPDATE
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

/datum/antagonist/heretic/farewell()
	if(!silent && owner.current)
		to_chat(owner.current, span_userdanger("Your mind begins to flare as the otherwordly knowledge escapes your grasp!"))
	return ..()

/datum/antagonist/heretic/on_gain()
	if(!GLOB.heretic_research_tree)
		GLOB.heretic_research_tree = generate_heretic_research_tree()

	if(give_objectives)
		forge_primary_objectives()

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge)


	ADD_TRAIT(owner, TRAIT_SEE_BLESSED_TILES, REF(src))
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer) // Gain +1 knowledge every 20 minutes.
	return ..()

/datum/antagonist/heretic/on_removal()
	if(owner.current)
		for(var/knowledge_index in researched_knowledge)
			var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
			knowledge.on_lose(owner.current, src)

	REMOVE_TRAIT(owner, TRAIT_SEE_BLESSED_TILES, REF(src))
	QDEL_LIST_ASSOC_VAL(researched_knowledge)
	return ..()

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Ancient knowledge described to you has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	our_mob.faction |= FACTION_HERETIC

	if (!issilicon(our_mob))
		GLOB.reality_smash_track.add_tracked_mind(owner)

	ADD_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, REF(src))
	RegisterSignal(our_mob, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))
	RegisterSignals(our_mob, list(COMSIG_MOB_BEFORE_SPELL_CAST, COMSIG_MOB_SPELL_ACTIVATED), PROC_REF(on_spell_cast))
	RegisterSignal(our_mob, COMSIG_USER_ITEM_INTERACTION, PROC_REF(on_item_use))
	RegisterSignal(our_mob, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(after_fully_healed))

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.faction -= FACTION_HERETIC

	if (owner in GLOB.reality_smash_track.tracked_heretics)
		GLOB.reality_smash_track.remove_tracked_mind(owner)

	REMOVE_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, REF(src))
	UnregisterSignal(our_mob, list(
		COMSIG_MOB_BEFORE_SPELL_CAST,
		COMSIG_MOB_SPELL_ACTIVATED,
		COMSIG_USER_ITEM_INTERACTION,
		COMSIG_LIVING_POST_FULLY_HEAL,
		COMSIG_LIVING_CULT_SACRIFICED,
	))

/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body == new_body) // if they were using a temporary body
		return

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(old_body, src)
		knowledge.on_gain(new_body, src)

/*
 * Signal proc for [COMSIG_MOB_BEFORE_SPELL_CAST] and [COMSIG_MOB_SPELL_ACTIVATED].
 *
 * Checks if our heretic has [TRAIT_ALLOW_HERETIC_CASTING] or is ascended.
 * If so, allow them to cast like normal.
 * If not, cancel the cast, and returns [SPELL_CANCEL_CAST].
 */
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, datum/action/cooldown/spell/spell)
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
	return SPELL_CANCEL_CAST

/*
 * Signal proc for [COMSIG_USER_ITEM_INTERACTION].
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_use(mob/living/source, atom/target, obj/item/weapon, list/modifiers)
	SIGNAL_HANDLER
	if(!is_type_in_typecache(weapon, scribing_tools))
		return NONE
	if(!isturf(target) || !isliving(source))
		return NONE

	var/obj/item/offhand = source.get_inactive_held_item()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return NONE

	try_draw_rune(source, target, additional_checks = CALLBACK(src, PROC_REF(check_mansus_grasp_offhand), source))
	return ITEM_INTERACT_SUCCESS

/**
 * Attempt to draw a rune on [target_turf].
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			target_turf.balloon_alert(user, "invalid placement for rune!")
			return

	if(locate(/obj/effect/heretic_rune) in range(3, target_turf))
		target_turf.balloon_alert(user, "too close to another rune!")
		return

	if(drawing_rune)
		target_turf.balloon_alert(user, "already drawing a rune!")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	drawing_rune = TRUE

	var/rune_colour = GLOB.heretic_path_to_color[heretic_path]
	target_turf.balloon_alert(user, "drawing rune...")
	var/obj/effect/temp_visual/drawing_heretic_rune/drawing_effect
	if (drawing_time < (10 SECONDS))
		drawing_effect = new /obj/effect/temp_visual/drawing_heretic_rune/fast(target_turf, rune_colour)
	else
		drawing_effect = new(target_turf, rune_colour)

	if(!do_after(user, drawing_time, target_turf, extra_checks = additional_checks, hidden = TRUE))
		target_turf.balloon_alert(user, "interrupted!")
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target_turf, rune_colour)
		qdel(drawing_effect)
		drawing_rune = FALSE
		return

	qdel(drawing_effect)
	target_turf.balloon_alert(user, "rune created")
	new /obj/effect/heretic_rune/big(target_turf, rune_colour)
	drawing_rune = FALSE

/**
 * Callback to check that the user's still got their Mansus Grasp out when drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 */
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_held_item()
	return !QDELETED(offhand) && istype(offhand, /obj/item/melee/touch_attack/mansus_fist)

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL],
/// Gives the heretic aliving heart on aheal or organ refresh
/datum/antagonist/heretic/proc/after_fully_healed(mob/living/source, heal_flags)
	SIGNAL_HANDLER

	if(heal_flags & (HEAL_REFRESH_ORGANS|HEAL_ADMIN))
		var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
		heart_knowledge.on_research(source, src)

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to reward cultists for sacrificing a heretic
/datum/antagonist/heretic/proc/on_cult_sacrificed(mob/living/source, list/invokers)
	SIGNAL_HANDLER

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) // uhh let's find the guy to shove him back in
		if((ghost.mind?.current == source) && ghost.client) // is it the same guy and do they have the same client
			ghost.reenter_corpse() // shove them in! it doesnt do it automatically

	// Drop all items and splatter them around messily.
	var/list/dustee_items = source.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(source), 2, 4, pick(invokers), TRUE)

	// Create the blade, give it the heretic and a randomly-chosen master for the soul sword component
	var/obj/item/melee/cultblade/haunted/haunted_blade = new(get_turf(source), source, pick(invokers))

	// Cool effect for the rune as well as the item
	var/obj/effect/rune/convert/conversion_rune = locate() in get_turf(source)
	if(conversion_rune)
		conversion_rune.gender_reveal(
			outline_color = COLOR_HERETIC_GREEN,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	haunted_blade.gender_reveal(outline_color = null, ray_color = COLOR_HERETIC_GREEN)

	for(var/mob/living/culto as anything in invokers)
		to_chat(culto, span_cult_large("\"A follower of the forgotten gods! You must be rewarded for such a valuable sacrifice.\""))

	// Locate a cultist team (Is there a better way??)
	var/mob/living/random_cultist = pick(invokers)
	var/datum/antagonist/cult/antag = random_cultist.mind.has_antag_datum(/datum/antagonist/cult)
	ASSERT(antag)
	var/datum/team/cult/cult_team = antag.get_team()

	// Unlock one of 3 special items!
	var/list/possible_unlocks
	for(var/i in cult_team.unlocked_heretic_items)
		if(cult_team.unlocked_heretic_items[i])
			continue
		LAZYADD(possible_unlocks, i)
	if(length(possible_unlocks))
		var/result = pick(possible_unlocks)
		cult_team.unlocked_heretic_items[result] = TRUE

		for(var/datum/mind/mind as anything in cult_team.members)
			if(mind.current)
				SEND_SOUND(mind.current, 'sound/effects/magic/clockwork/narsie_attack.ogg')
				to_chat(mind.current, span_cult_large(span_warning("Arcane and forbidden knowledge floods your forges and archives. The cult has learned how to create the ")) + span_cult_large(span_hypnophrase("[result]!")))

	return SILENCE_SACRIFICE_MESSAGE|DUST_SACRIFICE

/**
 * Creates an animation of the item slowly lifting up from the floor with a colored outline, then slowly drifting back down.
 * Arguments:
 * * outline_color: Default is between pink and light blue, is the color of the outline filter.
 * * ray_color: Null by default. If not set, just copies outline. Used for the ray filter.
 * * anim_time: Total time of the animation. Split into two different calls.
 * * do_float: Lets you disable the sprite floating up and down.
 * * do_layer: Lets you disable the layering increase.
 */
/obj/proc/gender_reveal(
	outline_color = null,
	ray_color = null,
	anim_time = 10 SECONDS,
	do_float = TRUE,
	do_layer = TRUE,
)

	var/og_layer
	if(do_layer)
		// Layering above to stand out!
		og_layer = layer
		layer = ABOVE_MOB_LAYER

	// Slowly floats up, then slowly goes down.
	if(do_float)
		animate(src, pixel_y = 12, time = anim_time * 0.5, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_y = 0, time = anim_time * 0.5, easing = QUAD_EASING | EASE_IN)

	// Adding a cool outline effect
	if(outline_color)
		add_filter("gender_reveal_outline", 3, list("type" = "outline", "color" = outline_color, "size" = 0.5))
		// Animating it!
		var/gay_filter = get_filter("gender_reveal_outline")
		animate(gay_filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
		animate(alpha = 40, time = 2.5 SECONDS)

	// Adding a cool ray effect
	if(ray_color)
		add_filter(name = "gender_reveal_ray", priority = 1, params = list(
				type = "rays",
				size = 45,
				color = ray_color,
				density = 6
			))
		// Animating it!
		var/ray_filter = get_filter("gender_reveal_ray")
		// I understand nothing but copypaste saves lives
		animate(ray_filter, offset = 100, time = 30 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(remove_gender_reveal_fx), og_layer), anim_time)

/**
 * Removes the non-animate effects from above proc
 */
/obj/proc/remove_gender_reveal_fx(og_layer)
	remove_filter(list("gender_reveal_outline", "gender_reveal_ray"))
	layer = og_layer

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/datum/objective/heretic_research/research_objective = new()
	research_objective.owner = owner
	objectives += research_objective

	var/num_heads = 0
	for(var/mob/player in GLOB.alive_player_list)
		if(player.mind.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
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
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, target, target_image)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))
	all_sac_targets += target.real_name

/**
 * Removes [target] from the heretic's sacrifice list.
 * Returns FALSE if no one was removed, TRUE otherwise
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(mob/living/carbon/human/target)
	if(!(target in sac_targets))
		return FALSE

	LAZYREMOVE(sac_targets, target)
	UnregisterSignal(target, COMSIG_QDELETING)
	return TRUE

/**
 * Signal proc for [COMSIG_QDELETING] registered on sac targets
 * if sacrifice targets are deleted (gibbed, dusted, whatever), free their slot and reference
 */
/datum/antagonist/heretic/proc/on_target_deleted(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	remove_sacrifice_target(source)

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	knowledge_points++
	if(owner.current.stat <= SOFT_CRIT)
		to_chat(owner.current, "[span_hear("You hear a whisper...")] [span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]")
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"
	parts += "The heretic's sacrifice targets were: [english_list(all_sac_targets, nothing_text = "No one")]."
	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(!objective.check_completion())
				succeeded = FALSE
			parts += "<b>Objective #[count]</b>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
			count++
	if(feast_of_owls)
		parts += span_greentext("Ascension Forsaken")
	if(ascended)
		parts += span_greentext(span_big("THE HERETIC ASCENDED!"))

	else
		if(succeeded)
			parts += span_greentext("The heretic was successful, but did not ascend!")
		else
			parts += span_redtext("The heretic has failed.")

	parts += "<b>Knowledge Researched:</b> "

	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		string_of_knowledge += knowledge.name

	parts += english_list(string_of_knowledge)

	return parts.Join("<br>")

/datum/antagonist/heretic/get_admin_commands()
	. = ..()

	switch(has_living_heart())
		if(HERETIC_NO_LIVING_HEART)
			.["Give Living Heart"] = CALLBACK(src, PROC_REF(give_living_heart))
		if(HERETIC_HAS_LIVING_HEART)
			.["Add Heart Target (Marked Mob)"] = CALLBACK(src, PROC_REF(add_marked_as_target))
			.["Remove Heart Target"] = CALLBACK(src, PROC_REF(remove_target))

	.["Adjust Knowledge Points"] = CALLBACK(src, PROC_REF(admin_change_points))
	.["Give Focus"] = CALLBACK(src, PROC_REF(admin_give_focus))

/**
 * Admin proc for giving a heretic a Living Heart easily.
 */
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, span_warning("The heretic doesn't have a living heart knowledge for some reason. What?"))
		return

	heart_knowledge.on_research(owner.current, src)

/**
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
		to_chat(owner.current, span_danger("[new_target.real_name], the [new_target.mind?.assigned_role?.title || "human"]."))

	add_sacrifice_target(new_target)

/**
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/list/removable = list()
	for(var/mob/living/carbon/human/old_target as anything in sac_targets)
		removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Choose a human to remove", "Who to Spare", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return
	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return

	if(!remove_sacrifice_target(chosen_target))
		to_chat(admin, span_warning("Failed to remove [name_of_removed] from [owner]'s sacrifice list. Perhaps they're no longer in the list anyways."))
		return

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, span_danger("The Mansus has modified your targets."))

/**
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

/**
 * Admin proc for giving a heretic a focus.
 */
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/neck/heretic_focus(get_turf(pawn)), ITEM_SLOT_NECK, TRUE, TRUE)
	to_chat(pawn, span_hypnophrase("The Mansus has manifested you a focus."))

/datum/antagonist/heretic/antag_panel_data()
	var/list/string_of_knowledge = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(istype(knowledge, /datum/heretic_knowledge/ultimate))
			string_of_knowledge += span_bold(knowledge.name)
		else
			string_of_knowledge += knowledge.name

	return "<br><b>Research Done:</b><br>[english_list(string_of_knowledge, and_text = ", and ")]<br>"

/datum/antagonist/heretic/antag_panel_objectives()
	. = ..()

	. += "<br>"
	. += "<i><b>Current Targets:</b></i><br>"
	if(LAZYLEN(sac_targets))
		for(var/mob/living/carbon/human/target as anything in sac_targets)
			. += " - <b>[target.real_name]</b>, the [target.mind?.assigned_role?.title || "human"].<br>"

	else
		. += "<i>None!</i><br>"
	. += "<br>"

/**
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
	initialized_knowledge.on_research(owner.current, src)
	update_static_data(owner.current)
	return TRUE

/**
 * Get a list of all knowledge TYPEPATHS that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		researchable_knowledge |= GLOB.heretic_research_tree[knowledge_index][HKT_NEXT]
		banned_knowledge |= GLOB.heretic_research_tree[knowledge_index][HKT_BAN]
		banned_knowledge |= knowledge.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/**
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/// Makes our heretic more able to rust things.
/// if side_path_only is set to TRUE, this function does nothing for rust heretics.
/datum/antagonist/heretic/proc/increase_rust_strength(side_path_only=FALSE)
	if(side_path_only && get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_rust))
		return

	rust_strength++

/**
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals[knowledge.name] = knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge), associative = TRUE)

/**
 * Checks to see if our heretic can ccurrently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend()
	if(!can_assign_self_objectives)
		return FALSE // We spurned the offer of the Mansus :(
	if(feast_of_owls)
		return FALSE // We sold our ambition for immediate power :/
	for(var/datum/objective/must_be_done as anything in objectives)
		if(!must_be_done.check_completion())
			return FALSE
	return TRUE

/**
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.get_organ_slot(living_heart_organ_slot)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/minor_sacrifice
	name = "minor sacrifice"

/datum/objective/minor_sacrifice/New(text)
	. = ..()
	target_amount = rand(3, 4)
	update_explanation_text()

/datum/objective/minor_sacrifice/update_explanation_text()
	. = ..()
	explanation_text = "Sacrifice at least [target_amount] crewmembers."

/datum/objective/minor_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.total_sacrifices >= target_amount)

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Sacrifice 1 head of staff."

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.high_value_sacrifices >= target_amount)

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
			if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] == PATH_RUST)
				rust_paths_found++

		main_path_length = rust_paths_found

	// Factor in the length of the main path first.
	target_amount = main_path_length
	// Add in the base research we spawn with, otherwise it'd be too easy.
	target_amount += length(GLOB.heretic_start_knowledge)
	// And add in some buffer, to require some sidepathing, especially since heretics get some free side paths.
	target_amount += rand(2, 4)
	update_explanation_text()

/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus. You start with [length(GLOB.heretic_start_knowledge)] researched."

/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (length(heretic_datum.researched_knowledge) >= target_amount)

/datum/objective/heretic_summon
	name = "summon monsters"
	target_amount = 2
	explanation_text = "Summon 2 monsters from the Mansus into this realm."
	/// The total number of summons the objective owner has done
	var/num_summoned = 0

/datum/objective/heretic_summon/check_completion()
	return completed || (num_summoned >= target_amount)

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	head = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	r_hand = /obj/item/melee/touch_attack/mansus_fist
