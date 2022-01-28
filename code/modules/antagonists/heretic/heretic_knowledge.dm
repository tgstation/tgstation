
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
	/// The knowledge this unlocks next after learning.
	var/list/next_knowledge = list()
	/// What knowledge is incompatible with this. Knowledge in this list cannot be researched with this current knowledge.
	var/list/banned_knowledge = list()
	/// Assoc list of [typepaths we need] to [amount needed].
	/// If set, this knowledge allows the heretic to do a ritual on a transmutation rune with the components set.
	var/list/required_atoms = list()
	/// Paired with above. If set, the resulting spawned atoms upon ritual completion.
	var/list/result_atoms = list()
	/// Cost of knowledge in knowlege points
	var/cost = 0
	/// What path is this on. Sefaults to "Side".
	var/route = PATH_SIDE

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
 * Overide this proc if you don't want ALL ATOMS to be destroyed.
 *
 * Arguments
 * * selected_atoms - a list of all atoms we intend on destroying.
 */
/datum/heretic_knowledge/proc/cleanup_atoms(list/selected_atoms)
	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)

/*
 * A knowledge subtype that grants the heretic a certain spell.
 */
/datum/heretic_knowledge/spell
	/// The proc holder spell we add to the heretic. Type-path, becomes an instance via on_gain().
	var/obj/effect/proc_holder/spell/spell_to_add

/datum/heretic_knowledge/spell/on_gain(mob/user)
	spell_to_add = new spell_to_add()
	user.mind.AddSpell(spell_to_add)

/datum/heretic_knowledge/spell/on_lose(mob/user)
	user.mind.RemoveSpell(spell_to_add)

/*
 * A knowledge subtype lets the heretic curse someone with a ritual.
 */
/datum/heretic_knowledge/curse
	/// The duration of the curse
	var/duration = 5 MINUTES
	/// Cache list of fingerprints (actual fingerprint strings) we have from our current ritual
	var/list/fingerprints

/datum/heretic_knowledge/curse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	fingerprints = list()
	for(var/atom/requirements as anything in atoms)
		fingerprints[requirements.return_fingerprints()] = 1
	list_clear_nulls(fingerprints)

	return length(fingerprints) // No fingerprints? No ritual

/datum/heretic_knowledge/curse/on_finished_recipe(mob/living/user, list/selected_atoms,  turf/loc)

	var/list/compiled_list = list()

	for(var/mob/living/carbon/human/human_to_check as anything in GLOB.human_list)
		if(fingerprints[md5(human_to_check.dna.unique_identity)])
			compiled_list |= human_to_check.real_name
			compiled_list[human_to_check.real_name] = human_to_check

	if(!length(compiled_list))
		loc.balloon_alert(user, "no fingerprints!")
		return FALSE

	var/chosen_mob = tgui_input_list(user, "Select the person you wish to curse", "Eldritch Curse", sort_list(compiled_list, /proc/cmp_mob_realname_dsc))
	if(isnull(chosen_mob))
		return FALSE

	var/mob/living/carbon/human/to_curse = compiled_list[chosen_mob]
	if(QDELETED(to_curse))
		loc.balloon_alert(user, "invalid choice!")
		return FALSE

	curse(to_curse)
	addtimer(CALLBACK(src, .proc/uncurse, to_curse), duration)
	return TRUE

/**
 * Calls a curse onto [chosen_mob].
 */
/datum/heretic_knowledge/curse/proc/curse(mob/living/chosen_mob)
	return

/**
 * Removes a curse from [chosen_mob]. Used in timers / callbacks.
 */
/datum/heretic_knowledge/curse/proc/uncurse(mob/living/chosen_mob)
	return

/*
 * A knowledge subtype lets the heretic summon a monster with the ritual.
 */
/datum/heretic_knowledge/summon
	/// Typepath of a mob to summon when we finish the recipe.
	var/mob/living/mob_to_summon

/datum/heretic_knowledge/summon/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/summoned = new mob_to_summon(loc)
	// Fade in the summon while the ghost poll is ongoing.
	summoned.alpha = 0
	animate(summoned, 10 SECONDS, alpha = 155)

	message_admins("A [summoned.name] is being summoned by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(summoned)].")
	var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a [summoned.real_name]?", ROLE_HERETIC, FALSE, 10 SECONDS, summoned)
	if(!LAZYLEN(candidates))
		to_chat(user, span_warning("Your ritual failed! The spirits lie dormant, and the summon falls apart. Perhaps try later?"))
		qdel(summoned)
		return FALSE

	var/mob/dead/observer/picked_candidate = pick(candidates)
	summoned.alpha = 255
	summoned.ghostize(FALSE)
	summoned.key = picked_candidate.key

	log_game("[key_name(user)] created a [summoned.name], controlled by [key_name(picked_candidate)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a [summoned.name], [ADMIN_LOOKUPFLW(picked_candidate)].")

	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(user.mind)

	return TRUE

/*
 * The special final tier of knowledges that unlocks ASCENSION.
 */
/datum/heretic_knowledge/final
	cost = 3
	required_atoms = list(/mob/living/carbon/human = 3)

/datum/heretic_knowledge/final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(heretic_datum.ascended)
		return FALSE

	// Remove all non-dead humans from the atoms list.
	// (We only want to sacrifice dead folk.)
	for(var/mob/living/carbon/human/sacrifice in atoms)
		if(sacrifice.stat != DEAD)
			atoms -= sacrifice

	// All the non-dead humans are removed in this proc.
	// We handle checking if we have enough humans in the ritual itself.
	return TRUE

/datum/heretic_knowledge/final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_datum.ascended = TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.physiology.brute_mod *= 0.5
		human_user.physiology.burn_mod *= 0.5

	return TRUE

/datum/heretic_knowledge/final/cleanup_atoms(list/selected_atoms)
	for(var/mob/living/carbon/human/sacrifice in selected_atoms)
		selected_atoms -= sacrifice
		sacrifice.gib()

	return ..()
