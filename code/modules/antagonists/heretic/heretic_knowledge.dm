
/**
 * # Heretic Knowledge
 *
 * The datums that allow heretics to progress and learn new spells and rituals.
 *
 * Heretic Knowledge datums are not singletons - they are instantiated as they
 * are given to heretics, and deleted if the heretic antagonist is removed.
 *
 */
/datum/heretic_knowledge
	/// Name of the knowledge, shown to the heretic.
	var/name = "Basic knowledge"
	/// Description of the knowledge, shown to the heretic. Describes what it unlocks / does.
	var/desc = "Basic knowledge of forbidden arts."
	/// What's shown to the heretic when the knowledge is aquired
	var/gain_text
	/// The abstract parent type of the knowledge, used in determine mutual exclusivity in some cases
	var/datum/heretic_knowledge/abstract_parent_type = /datum/heretic_knowledge
	/// If TRUE, populates the banned_knowledge list of every other subtype of this knowledge's abstract_parent_type
	var/mutually_exclusive = FALSE
	/// The knowledge this unlocks next after learning.
	var/list/next_knowledge = list()
	/// What knowledge is incompatible with this. Knowledge in this list cannot be researched with this current knowledge.
	var/list/banned_knowledge = list()
	/// Assoc list of [typepaths we need] to [amount needed].
	/// If set, this knowledge allows the heretic to do a ritual on a transmutation rune with the components set.
	var/list/required_atoms
	/// Paired with above. If set, the resulting spawned atoms upon ritual completion.
	var/list/result_atoms = list()
	/// Cost of knowledge in knowlege points
	var/cost = 0
	/// The priority of the knowledge. Higher priority knowledge appear higher in the ritual list.
	/// Number itself is completely arbitrary. Does not need to be set for non-ritual knowledge.
	var/priority = 0
	/// What path is this on. If set to "null", assumed to be unreachable (or abstract).
	var/route

/datum/heretic_knowledge/New()
	if(!mutually_exclusive)
		return

	for(var/knowledge_type in subtypesof(abstract_parent_type))
		if(knowledge_type == type)
			continue
		banned_knowledge += knowledge_type

/**
 * Called when the knowledge is first researched.
 * This is only ever called once per heretic.
 *
 * Arguments
 * * user - the heretic who researched something
 */
/datum/heretic_knowledge/proc/on_research(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(gain_text)
		to_chat(user, span_warning("[gain_text]"))
	on_gain(user)

/**
 * Called when the knowledge is applied to a mob.
 * This can be called multiple times per heretic,
 * in the case of bodyswap shenanigans.
 *
 * Arguments
 * * user - the heretic which we're applying things to
 */
/datum/heretic_knowledge/proc/on_gain(mob/user)

/**
 * Called when the knowledge is removed from a mob,
 * either due to a heretic being de-heretic'd or bodyswap memery.
 *
 * Arguments
 * * user - the heretic which we're removing things from
 */
/datum/heretic_knowledge/proc/on_lose(mob/user)

/**
 * Determines if a heretic can actually attempt to invoke the knowledge as a ritual.
 * By default, we can only invoke knowledge with rituals associated.
 *
 * Return TRUE to have the ritual show up in the rituals list, FALSE otherwise.
 */
/datum/heretic_knowledge/proc/can_be_invoked(datum/antagonist/heretic/invoker)
	return !!LAZYLEN(required_atoms)

/**
 * Special check for rituals.
 * Called before any of the required atoms are checked.
 *
 * If you are adding a more complex summoning,
 * or something that requires a special check
 * that parses through all the atoms,
 * you should override this.
 *
 * Arguments
 * * user - the mob doing the ritual
 * * atoms - a list of all atoms being checked in the ritual.
 * * selected_atoms - an empty list(!) instance passed in by the ritual. You can add atoms to it in this proc.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual will continue, or FALSE, if the ritual is skipped / cancelled
 */
/datum/heretic_knowledge/proc/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE

/**
 * Called whenever the knowledge's associated ritual is completed successfully.
 *
 * Creates atoms from types in result_atoms.
 * Override this is you want something else to happen.
 * This CAN sleep, such as for summoning rituals which poll for ghosts.
 *
 * Arguments
 * * user - the mob who did the  ritual
 * * selected_atoms - an list of atoms chosen as a part of this ritual.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual should cleanup afterwards, or FALSE, to avoid calling cleanup after.
 */
/datum/heretic_knowledge/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result_atoms))
		return FALSE
	for(var/result in result_atoms)
		new result(loc)
	return TRUE

/**
 * Called after on_finished_recipe returns TRUE
 * and a ritual was successfully completed.
 *
 * Goes through and cleans up (deletes)
 * all atoms in the selected_atoms list.
 *
 * Remove atoms from the selected_atoms
 * (either in this proc or in on_finished_recipe)
 * to NOT have certain atoms deleted on cleanup.
 *
 * Arguments
 * * selected_atoms - a list of all atoms we intend on destroying.
 */
/datum/heretic_knowledge/proc/cleanup_atoms(list/selected_atoms)
	SHOULD_CALL_PARENT(TRUE)

	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		if(isstack(sacrificed))
			var/obj/item/stack/sac_stack = sacrificed
			var/how_much_to_use = 0
			for(var/requirement in required_atoms)
				if(istype(sacrificed, requirement))
					how_much_to_use = min(required_atoms[requirement], sac_stack.amount)
					break

			sac_stack.use(how_much_to_use)
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)

/*
 * A knowledge subtype that grants the heretic a certain spell.
 */
/datum/heretic_knowledge/spell
	abstract_parent_type = /datum/heretic_knowledge/spell
	/// The proc holder spell we add to the heretic. Type-path, becomes an instance via on_research().
	var/obj/effect/proc_holder/spell/spell_to_add

/datum/heretic_knowledge/spell/Destroy(force, ...)
	if(istype(spell_to_add))
		QDEL_NULL(spell_to_add)
	return ..()

/datum/heretic_knowledge/spell/on_research(mob/user)
	spell_to_add = new spell_to_add()
	return ..()

/datum/heretic_knowledge/spell/on_gain(mob/user)
	user.mind.AddSpell(spell_to_add)

/datum/heretic_knowledge/spell/on_lose(mob/user)
	user.mind.RemoveSpell(spell_to_add)

/*
 * A knowledge subtype for knowledge that can only
 * have a limited amount of it's resulting atoms
 * created at once.
 */
/datum/heretic_knowledge/limited_amount
	abstract_parent_type = /datum/heretic_knowledge/limited_amount
	/// The limit to how many items we can create at once.
	var/limit = 1
	/// A list of weakrefs to all items we've created.
	var/list/datum/weakref/created_items

/datum/heretic_knowledge/limited_amount/Destroy(force, ...)
	LAZYCLEARLIST(created_items)
	return ..()

/datum/heretic_knowledge/limited_amount/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/datum/weakref/ref as anything in created_items)
		var/atom/real_thing = ref.resolve()
		if(QDELETED(real_thing))
			LAZYREMOVE(created_items, ref)

	if(LAZYLEN(created_items) >= limit)
		loc.balloon_alert(user, "ritual failed, at limit!")
		return FALSE

	return TRUE

/datum/heretic_knowledge/limited_amount/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/result in result_atoms)
		var/atom/created_thing = new result(loc)
		LAZYADD(created_items, WEAKREF(created_thing))
	return TRUE

/*
 * A knowledge subtype for limited_amount knowledge
 * used for base knowledge (the ones that make blades)
 *
 * A heretic can only learn one /starting type knowledge,
 * and their ascension depends on whichever they chose.
 */
/datum/heretic_knowledge/limited_amount/starting
	abstract_parent_type = /datum/heretic_knowledge/limited_amount/starting
	mutually_exclusive = TRUE
	limit = 2
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 5

/datum/heretic_knowledge/limited_amount/starting/New()
	. = ..()
	// Starting path also determines the final knowledge we're limited too
	for(var/datum/heretic_knowledge/final_knowledge_type as anything in subtypesof(/datum/heretic_knowledge/final))
		if(initial(final_knowledge_type.route) == route)
			continue
		banned_knowledge += final_knowledge_type

/*
 * A knowledge subtype for heretic knowledge
 * that applies a mark on use.
 *
 * A heretic can only learn one /mark type knowledge.
 */
/datum/heretic_knowledge/mark
	abstract_parent_type = /datum/heretic_knowledge/mark
	mutually_exclusive = TRUE
	cost = 2
	/// The status effect typepath we apply on people on mansus grasp.
	var/datum/status_effect/eldritch/mark_type

/datum/heretic_knowledge/mark/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/mark/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/**
 * Signal proc for [COMSIG_HERETIC_MANSUS_GRASP_ATTACK].
 *
 * Whenever we cast mansus grasp on someone, apply our mark.
 */
/datum/heretic_knowledge/mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	create_mark(source, target)

/**
 * Signal proc for [COMSIG_HERETIC_BLADE_ATTACK].
 *
 * Whenever we attack someone with our blade, attempt to trigger any marks on them.
 */
/datum/heretic_knowledge/mark/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	trigger_mark(source, target)

/**
 * Creates the mark status effect on our target.
 * This proc handles the instatiate and the application of the station effect,
 * and returns the /datum/status_effect instance that was made.
 *
 * Can be overriden to set or pass in additional vars of the status effect.
 */
/datum/heretic_knowledge/mark/proc/create_mark(mob/living/source, mob/living/target)
	if(target.stat == DEAD)
		return
	return target.apply_status_effect(mark_type)

/**
 * Handles triggering the mark on the target.
 *
 * If there is no mark, returns FALSE. Returns TRUE if a mark was triggered.
 */
/datum/heretic_knowledge/mark/proc/trigger_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return FALSE

	mark.on_effect()
	return TRUE

/*
 * A knowledge subtype for heretic knowledge that
 * upgrades their sickly blade, either on melee or range.
 *
 * A heretic can only learn one /blade_upgrade type knowledge.
 */
/datum/heretic_knowledge/blade_upgrade
	abstract_parent_type = /datum/heretic_knowledge/blade_upgrade
	mutually_exclusive = TRUE
	cost = 2

/datum/heretic_knowledge/blade_upgrade/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)
	RegisterSignal(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, .proc/on_ranged_eldritch_blade)

/datum/heretic_knowledge/blade_upgrade/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_BLADE_ATTACK, COMSIG_HERETIC_RANGED_BLADE_ATTACK))


/**
 * Signal proc for [COMSIG_HERETIC_BLADE_ATTACK].
 *
 * Apply any melee effects from hitting someone with our blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	do_melee_effects(source, target, blade)

/**
 * Signal proc for [COMSIG_HERETIC_RANGED_BLADE_ATTACK].
 *
 * Apply any ranged effects from hitting someone with our blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/on_ranged_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	do_ranged_effects(source, target, blade)

/**
 * Overridable proc that invokes special effects
 * whenever the heretic attacks someone in melee with their heretic blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	return

/**
 * Overridable proc that invokes special effects
 * whenever the heretic clicks on someone at range with their heretic blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/do_ranged_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	return

/*
 * A knowledge subtype lets the heretic curse someone with a ritual.
 */
/datum/heretic_knowledge/curse
	abstract_parent_type = /datum/heretic_knowledge/curse
	/// The duration of the curse
	var/duration = 5 MINUTES
	/// Cache list of fingerprints (actual fingerprint strings) we have from our current ritual
	var/list/fingerprints

/datum/heretic_knowledge/curse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	fingerprints = list()
	for(var/atom/requirements as anything in atoms)
		fingerprints[GET_ATOM_FINGERPRINTS(requirements)] = 1
	list_clear_nulls(fingerprints)

	// No fingerprints? No ritual
	if(!length(fingerprints))
		loc.balloon_alert(user, "ritual failed, no fingerprints!")
		return FALSE

	return TRUE

/datum/heretic_knowledge/curse/on_finished_recipe(mob/living/user, list/selected_atoms,  turf/loc)

	var/list/compiled_list = list()

	for(var/mob/living/carbon/human/human_to_check as anything in GLOB.human_list)
		if(fingerprints[md5(human_to_check.dna.unique_identity)])
			compiled_list |= human_to_check.real_name
			compiled_list[human_to_check.real_name] = human_to_check

	if(!length(compiled_list))
		loc.balloon_alert(user, "ritual failed, no fingerprints!")
		return FALSE

	var/chosen_mob = tgui_input_list(user, "Select the person you wish to curse", "Eldritch Curse", sort_list(compiled_list, /proc/cmp_mob_realname_dsc))
	if(isnull(chosen_mob))
		return FALSE

	var/mob/living/carbon/human/to_curse = compiled_list[chosen_mob]
	if(QDELETED(to_curse))
		loc.balloon_alert(user, "ritual failed, invalid choice!")
		return FALSE

	log_combat(user, to_curse, "cursed via heretic ritual", addition = "([name])")
	curse(to_curse)
	addtimer(CALLBACK(src, .proc/uncurse, to_curse), duration)
	return TRUE

/**
 * Calls a curse onto [chosen_mob].
 */
/datum/heretic_knowledge/curse/proc/curse(mob/living/carbon/human/chosen_mob)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement curse()!")

/**
 * Removes a curse from [chosen_mob]. Used in timers / callbacks.
 */
/datum/heretic_knowledge/curse/proc/uncurse(mob/living/carbon/human/chosen_mob)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement uncurse()!")

/*
 * A knowledge subtype lets the heretic summon a monster with the ritual.
 */
/datum/heretic_knowledge/summon
	abstract_parent_type = /datum/heretic_knowledge/summon
	/// Typepath of a mob to summon when we finish the recipe.
	var/mob/living/mob_to_summon

/datum/heretic_knowledge/summon/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/summoned = new mob_to_summon(loc)
	// Fade in the summon while the ghost poll is ongoing.
	// Also don't let them mess with the summon while waiting
	summoned.alpha = 0
	summoned.notransform = TRUE
	summoned.move_resist = MOVE_FORCE_OVERPOWERING
	animate(summoned, 10 SECONDS, alpha = 155)

	message_admins("A [summoned.name] is being summoned by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(summoned)].")
	var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a [summoned.real_name]?", ROLE_HERETIC, FALSE, 10 SECONDS, summoned)
	if(!LAZYLEN(candidates))
		loc.balloon_alert(user, "ritual failed, no ghosts!")
		animate(summoned, 0.5 SECONDS, alpha = 0)
		QDEL_IN(summoned, 0.6 SECONDS)
		return FALSE

	var/mob/dead/observer/picked_candidate = pick(candidates)
	// Ok let's make them an interactable mob now, since we got a ghost
	summoned.alpha = 255
	summoned.notransform = FALSE
	summoned.move_resist = initial(summoned.move_resist)

	summoned.ghostize(FALSE)
	summoned.key = picked_candidate.key

	log_game("[key_name(user)] created a [summoned.name], controlled by [key_name(picked_candidate)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a [summoned.name], [ADMIN_LOOKUPFLW(summoned)].")

	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(user.mind)

	var/datum/objective/heretic_summon/summon_objective = locate() in user.mind.get_all_objectives()
	summon_objective?.num_summoned++

	return TRUE

/// The amount of knowledge points the knowledge ritual gives on success.
#define KNOWLEDGE_RITUAL_POINTS 4

/*
 * A subtype of knowledge that generates random ritual components.
 */
/datum/heretic_knowledge/knowledge_ritual
	name = "Ritual of Knowledge"
	desc = "A randomly generated transmutation ritual that rewards knowledge points and can only be completed once."
	gain_text = "Everything can be a key to unlocking the secrets behind the Gates. I must be wary and wise."
	abstract_parent_type = /datum/heretic_knowledge/knowledge_ritual
	mutually_exclusive = TRUE
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 10 // A pretty important midgame ritual.
	/// Whether we've done the ritual. Only doable once.
	var/was_completed = FALSE

/datum/heretic_knowledge/knowledge_ritual/New()
	. = ..()
	var/static/list/potential_organs = list(
		/obj/item/organ/appendix,
		/obj/item/organ/tail,
		/obj/item/organ/eyes,
		/obj/item/organ/tongue,
		/obj/item/organ/ears,
		/obj/item/organ/heart,
		/obj/item/organ/liver,
		/obj/item/organ/stomach,
		/obj/item/organ/lungs,
	)

	var/static/list/potential_easy_items = list(
		/obj/item/shard,
		/obj/item/candle,
		/obj/item/book,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/toy/crayon,
		/obj/item/flashlight,
		/obj/item/clipboard,
	)

	var/static/list/potential_uncommoner_items = list(
		/obj/item/restraints/legcuffs/beartrap,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/circular_saw,
		/obj/item/scalpel,
		/obj/item/binoculars,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/melee/baton/security,
		/obj/item/clothing/glasses/sunglasses,
	)

	required_atoms = list()
	// 2 organs. Can be the same.
	required_atoms[pick(potential_organs)] += 1
	required_atoms[pick(potential_organs)] += 1
	// 2-3 random easy items.
	required_atoms[pick(potential_easy_items)] += rand(2, 3)
	// 1 uncommon item.
	required_atoms[pick(potential_uncommoner_items)] += 1

/datum/heretic_knowledge/knowledge_ritual/on_research(mob/user)
	. = ..()

	var/list/requirements_string = list()

	to_chat(user, span_hierophant("The [name] requires the following:"))
	for(var/obj/item/path as anything in required_atoms)
		var/amount_needed = required_atoms[path]
		to_chat(user, span_hypnophrase("[amount_needed] [initial(path.name)]\s..."))
		requirements_string += "[amount_needed == 1 ? "":"[amount_needed] "][initial(path.name)]\s"

	to_chat(user, span_hierophant("Completing it will reward you [KNOWLEDGE_RITUAL_POINTS] knowledge points. You can check the knowledge in your Researched Knowledge to be reminded."))

	desc = "Allows you to transmute [english_list(requirements_string)] for [KNOWLEDGE_RITUAL_POINTS] bonus knowledge points. This can only be completed once."

/datum/heretic_knowledge/knowledge_ritual/can_be_invoked(datum/antagonist/heretic/invoker)
	return !was_completed

/datum/heretic_knowledge/knowledge_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return !was_completed

/datum/heretic_knowledge/knowledge_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	our_heretic.knowledge_points += KNOWLEDGE_RITUAL_POINTS
	was_completed = TRUE

	var/drain_message = pick(strings(HERETIC_INFLUENCE_FILE, "drain_message"))
	to_chat(user, span_boldnotice("[name] completed!"))
	to_chat(user, span_hypnophrase(span_big("[drain_message]")))
	desc += " (Completed!)"
	log_heretic_knowledge("[key_name(user)] completed a [name] at [worldtime2text()].")
	return TRUE

#undef KNOWLEDGE_RITUAL_POINTS

/*
 * The special final tier of knowledges that unlocks ASCENSION.
 */
/datum/heretic_knowledge/final
	abstract_parent_type = /datum/heretic_knowledge/final
	mutually_exclusive = TRUE // I guess, but it doesn't really matter by this point
	cost = 2
	priority = MAX_KNOWLEDGE_PRIORITY + 1 // Yes, the final ritual should be ABOVE the max priority.
	required_atoms = list(/mob/living/carbon/human = 3)

/datum/heretic_knowledge/final/on_research(mob/user)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/total_points = 0
	for(var/datum/heretic_knowledge/knowledge as anything in flatten_list(heretic_datum.researched_knowledge))
		total_points += knowledge.cost

	log_heretic_knowledge("[key_name(user)] gained knowledge of their final ritual at [worldtime2text()]. \
		They have [length(heretic_datum.researched_knowledge)] knowledge nodes researched, totalling [total_points] points \
		and have sacrificed [heretic_datum.total_sacrifices] people ([heretic_datum.high_value_sacrifices] of which were high value)")

/datum/heretic_knowledge/final/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.ascended)
		return FALSE

	if(!invoker.can_ascend())
		return FALSE

	return TRUE

/datum/heretic_knowledge/final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!can_be_invoked(heretic_datum))
		return FALSE

	// Remove all non-dead humans from the atoms list.
	// (We only want to sacrifice dead folk.)
	for(var/mob/living/carbon/human/sacrifice in atoms)
		if(!is_valid_sacrifice(sacrifice))
			atoms -= sacrifice

	// All the non-dead humans are removed in this proc.
	// We handle checking if we have enough humans in the ritual itself.
	return TRUE

/**
 * Checks if the passed human is a valid sacrifice for our ritual.
 */
/datum/heretic_knowledge/final/proc/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	return (sacrifice.stat == DEAD) && !ismonkey(sacrifice)

/datum/heretic_knowledge/final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.ascended = TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.physiology.brute_mod *= 0.5
		human_user.physiology.burn_mod *= 0.5


	log_heretic_knowledge("[key_name(user)] completed their final ritual at [worldtime2text()].")
	return TRUE

/datum/heretic_knowledge/final/cleanup_atoms(list/selected_atoms)
	for(var/mob/living/carbon/human/sacrifice in selected_atoms)
		selected_atoms -= sacrifice
		sacrifice.gib()

	return ..()
