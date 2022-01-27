
/**
 * #Eldritch Knowledge
 *
 * Datum that makes eldritch cultist interesting.
 *
 * Eldritch knowledge aren't instantiated anywhere roundstart, and are initalized and destroyed as the round goes on.
 */
/datum/heretic_knowledge
	/// Name of the knowledge, shown to the heretic.
	var/name = "Basic knowledge"
	/// Description of the knowledge, shown to the heretic. Describes what it unlocks / does.
	var/desc = "Basic knowledge of forbidden arts."
	/// What's shown to the heretic when the knowledge is aquired
	var/gain_text
	/// Cost of knowledge in knowlege points
	var/cost = 0
	/// The knowledge this unlocks next after learning.
	var/list/next_knowledge = list()
	/// What knowledge is incompatible with this. Knowledge in this list cannot be researched with this current knowledge.
	var/list/banned_knowledge = list()
	/// Assoc list of [typepaths we need] to [amount needed].
	/// If set, this knowledge allows the heretic to do a ritual on a transmutation rune with the components set.
	var/list/required_atoms = list()
	/// Paired with above. If set, the resulting spawned atoms upon ritual completion.
	var/list/result_atoms = list()
	/// What path is this on. Sefaults to "Side".
	var/route = PATH_SIDE
	/// Whether this knowledge processes on life ticks.
	var/processes_on_life = FALSE

/**
 * What happens when this is assigned to an antag datum
 *
 * This proc is called whenever a new eldritch knowledge is added to an antag datum
 */
/datum/heretic_knowledge/proc/on_gain(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(gain_text)
		to_chat(user, span_warning("[gain_text]"))
	if(processes_on_life)
		RegisterSignal(user, COMSIG_LIVING_LIFE, .proc/on_life)

/**
 * What happens when you loose this
 *
 * This proc is called whenever antagonist looses his antag datum, put cleanup code in here
 */
/datum/heretic_knowledge/proc/on_lose(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(processes_on_life)
		UnregisterSignal(user, COMSIG_LIVING_LIFE)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Used for effects done from knowledge of every life tick.
 * Will not be called unless processes_on_life = TRUE.
 */
/datum/heretic_knowledge/proc/on_life(mob/user)
	SIGNAL_HANDLER

/**
 * Special check for recipes
 *
 * If you are adding a more complex summoning or something that requires a special check that parses through all the atoms in an area override this.
 */
/datum/heretic_knowledge/proc/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE

/**
 * A proc that handles the code when the mob dies
 *
 * This proc is primarily used to end any soundloops when the heretic dies
 */
/datum/heretic_knowledge/proc/on_death(mob/user)

/**
 * What happens once the recipe is succesfully finished
 *
 * By default this proc creates atoms from result_atoms list. Override this is you want something else to happen.
 */
/datum/heretic_knowledge/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result_atoms))
		return FALSE
	for(var/result in result_atoms)
		new result(loc)
	return TRUE

/**
 * Used atom cleanup
 *
 * Overide this proc if you dont want ALL ATOMS to be destroyed. useful in many situations.
 */
/datum/heretic_knowledge/proc/cleanup_atoms(list/selected_atoms)
	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)

/**
 * Mansus grasp act
 *
 * Gives addtional effects to mansus grasp spell
 */
/datum/heretic_knowledge/proc/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	return FALSE


/**
 * Sickly blade act
 *
 * Gives addtional effects to sickly blade weapon
 */
/datum/heretic_knowledge/proc/on_eldritch_blade(atom/target,mob/user,proximity_flag,click_parameters)
	return

/**
 * Sickly blade distant act
 *
 * Same as [/datum/heretic_knowledge/proc/on_eldritch_blade] but works on targets that are not in proximity to you.
 */
/datum/heretic_knowledge/proc/on_ranged_attack_eldritch_blade(atom/target,mob/user,click_parameters)
	return

//////////////
///Subtypes///
//////////////

/datum/heretic_knowledge/spell
	var/obj/effect/proc_holder/spell/spell_to_add

/datum/heretic_knowledge/spell/on_gain(mob/user)
	spell_to_add = new spell_to_add
	user.mind.AddSpell(spell_to_add)
	return ..()

/datum/heretic_knowledge/spell/on_lose(mob/user)
	user.mind.RemoveSpell(spell_to_add)
	return ..()

/datum/heretic_knowledge/curse
	var/timer = 5 MINUTES
	var/list/fingerprints = list()
	var/list/dna = list()

/datum/heretic_knowledge/curse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	fingerprints = list()
	for(var/atom/requirements as anything in atoms)
		fingerprints |= requirements.return_fingerprints()
	list_clear_nulls(fingerprints)
	if(!length(fingerprints))
		return FALSE
	return TRUE

/datum/heretic_knowledge/curse/on_finished_recipe(mob/living/user, list/selected_atoms,loc)

	var/list/compiled_list = list()

	for(var/mob/living/carbon/human/human_to_check as anything in GLOB.human_list)
		if(fingerprints[md5(human_to_check.dna.unique_identity)])
			compiled_list |= human_to_check.real_name
			compiled_list[human_to_check.real_name] = human_to_check

	if(!length(compiled_list))
		to_chat(user, span_warning("These items don't possess the required fingerprints or DNA."))
		return FALSE

	var/chosen_mob = tgui_input_list(user, "Select the person you wish to curse", "Eldritch Curse", sort_list(compiled_list, /proc/cmp_mob_realname_dsc))
	if(isnull(chosen_mob))
		return FALSE
	curse(compiled_list[chosen_mob])
	addtimer(CALLBACK(src, .proc/uncurse, compiled_list[chosen_mob]),timer)
	return TRUE

/datum/heretic_knowledge/curse/proc/curse(mob/living/chosen_mob)
	return

/datum/heretic_knowledge/curse/proc/uncurse(mob/living/chosen_mob)
	return

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

//Ascension knowledge
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
