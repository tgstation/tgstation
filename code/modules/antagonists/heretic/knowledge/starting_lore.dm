/// Global list of all heretic knowledge that have route = PATH_START. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.route) == PATH_START)
			. += knowledge

/*
 * The base heretic knowledge. Grants the Mansus Grasp spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey into the Mansus. \
		Grants you the Mansus Grasp, a powerful and upgradable \
		disabling spell that can be cast regardless of having a focus."
	next_knowledge = list(
		/datum/heretic_knowledge/limited_amount/base_rust,
		/datum/heretic_knowledge/limited_amount/base_ash,
		/datum/heretic_knowledge/limited_amount/base_flesh,
		/datum/heretic_knowledge/limited_amount/base_void,
		)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	cost = 0
	route = PATH_START

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Grants you a Living Heart, allowing you to track sacrifice targets. \
		Should you lose your heart, you can transmute a poppy and a pool of blood \
		to awaken your heart into a Living Heart. If your heart is cybernetic, \
		you will additionally require a usable organic heart in the transmutation."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/food/grown/poppy = 1,
	)
	cost = 0
	route = PATH_START

/datum/heretic_knowledge/living_heart/on_research(mob/user)
	. = ..()

	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(our_heart)
		our_heart.AddComponent(/datum/component/living_heart)

/datum/heretic_knowledge/living_heart/on_lose(mob/user)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(our_heart)
		qdel(our_heart.GetComponent(/datum/component/living_heart))

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	if(our_heart.status == ORGAN_ORGANIC)
		return TRUE

	else
		for(var/obj/item/organ/heart/nearby_heart in atoms)
			if(nearby_heart.status == ORGAN_ORGANIC && nearby_heart.useable)
				selected_atoms += nearby_heart
				return TRUE

		return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)

	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)

	if(our_heart.status != ORGAN_ORGANIC)
		var/obj/item/organ/heart/our_replacement_heart = locate() in selected_atoms
		if(our_replacement_heart)
			user.visible_message("[user]'s [our_replacement_heart.name] bursts suddenly out of [user.p_their()] chest!")
			INVOKE_ASYNC(user, /mob/proc/emote, "scream")
			user.apply_damage(20, BRUTE, BODY_ZONE_CHEST)

			our_replacement_heart.Insert(user, special = TRUE, drop_if_replaced = TRUE)
			our_heart.throw_at(get_edge_target_turf(user, pick(GLOB.alldirs)), 2, 2)
			our_heart = our_replacement_heart

	if(!our_heart)
		CRASH("[type] somehow made it to on_finished_recipe without a heart. What?")

	if(our_heart in selected_atoms)
		selected_atoms -= our_heart
	our_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("You feel your [our_heart.name] begin pulse faster and faster as it awakens!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)

/**
 * Allows the heretic to sacrifice living heart targets.
 */
/datum/heretic_knowledge/hunt_and_sacrifice
	name = "Heartbeat of the Mansus"
	desc = "Allows you to sacrifice targets to the Mansus by bringing them to a rune in critical (or worse) condition. \
		If you have no targets, stand on a transmutation rune and invoke it to aquire some."
	required_atoms = list(/mob/living/carbon/human = 1)
	cost = 0
	route = PATH_START
	/// If TRUE, we skip the ritual. Done when no targets can be found, to avoid locking up the heretic.
	var/skip_this_ritual = FALSE
	/// Lazylist of weakrefs to minds that we won't pick as targets.
	var/list/datum/weakref/target_blacklist

/datum/heretic_knowledge/hunt_and_sacrifice/on_research(mob/user, regained = FALSE)
	. = ..()
	obtain_targets(user)

/datum/heretic_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || !HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	// We've got no targets set, let's try to set some. Adds the user to the list of atoms,
	// then returns TRUE if skip_this_ritual is FALSE and the user's on top of the rune.
	// If skip_this_ritual is TRUE, returns FALSE to fail the check and move onto the next ritual.
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!LAZYLEN(heretic_datum.sac_targets))
		if(skip_this_ritual)
			return FALSE

		atoms += user
		return (user in range(1, loc))

	// Determine if livings in our atoms are valid
	for(var/mob/living/carbon/human/sacrifice in atoms)
		// If the mob's not in soft crit or worse, or isn't one of the sacrifices, remove it from the list
		if(sacrifice.stat < SOFT_CRIT || !(WEAKREF(sacrifice) in heretic_datum.sac_targets))
			atoms -= sacrifice

	// Finally, return TRUE if we have a mob remaining in our list
	// Otherwise, return FALSE and stop the ritual
	return !!(locate(/mob/living/carbon/human) in atoms)

/datum/heretic_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(LAZYLEN(heretic_datum.sac_targets))
		sacrifice_process(user, selected_atoms, loc)
	else
		obtain_targets(user)

	return TRUE

/datum/heretic_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/user, list/selected_atoms, loc)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(WEAKREF(sacrifice) in heretic_datum.sac_targets))
		CRASH("[type] sacrifice_process managed to get a non-target human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, WEAKREF(sacrifice.mind))
	LAZYREMOVE(heretic_datum.sac_targets, WEAKREF(sacrifice))

	to_chat(user, span_danger("Your patrons accepts your offer."))
	sacrifice.spill_organs()
	sacrifice.adjustBruteLoss(250)
	new /obj/effect/gibspawner/generic(get_turf(sacrifice))

	var/datum/job/their_job = sacrifice.mind?.assigned_role
	if(their_job?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		heretic_datum.high_value_sacrifices++

	heretic_datum.total_sacrifices++
	heretic_datum.knowledge_points += 2

/datum/heretic_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user)

	// First construct a list of minds that are valid objective targets.
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(possible_target == user.mind)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue
		if(istype(get_area(possible_target), /area/shuttle/arrival))
			continue
		if(WEAKREF(possible_target) in target_blacklist)
			continue

		valid_targets += possible_target

	if(!valid_targets.len)
		to_chat(user, span_danger("No sacrifice targets could be found! Attempt the ritual later."))
		skip_this_ritual = TRUE
		addtimer(VARSET_CALLBACK(src, skip_this_ritual, FALSE), 5 MINUTES)
		return FALSE

	// Now, let's try to get four targets.
	// - One completely random
	// - One from your department
	// - One from security
	// - One from heads of staff ("high value")

	// First target (and list definition), random
	var/list/datum/mind/final_targets = list(pick_n_take(valid_targets))

	// Second target, department
	for(var/datum/mind/department_mind as anything in shuffle_inplace(valid_targets))
		if(department_mind.assigned_role?.departments_bitflags & user.mind.assigned_role?.departments_bitflags)
			final_targets += department_mind
			break

	// Third target, security
	for(var/datum/mind/sec_mind as anything in shuffle_inplace(valid_targets))
		if(sec_mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			final_targets += sec_mind
			break

	// Fourth target, command
	for(var/datum/mind/head_mind as anything in shuffle_inplace(valid_targets))
		if(head_mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			final_targets += head_mind
			break

	// If any of our targets failed to aquire,
	// Let's run a loop until we get four total,
	// grabbing random targets.
	var/target_sanity = 0
	while(final_targets.len < 4 && valid_targets.len > 4 && target_sanity < 25)
		final_targets += pick_n_take(valid_targets)
		target_sanity++

	list_clear_nulls(final_targets)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)

	to_chat(user, span_danger("Your targets have been determined. Your Living Heart will allow you to track their position. Go and sacrifice them!"))
	for(var/datum/mind/chosen_mind as anything in final_targets)
		LAZYADD(heretic_datum.sac_targets, WEAKREF(chosen_mind.current))
		to_chat(user, span_danger("[chosen_mind.current.real_name], the [chosen_mind.assigned_role]."))
	return TRUE

/**
 * Allows the heretic to craft a spell focus.
 * They require a focus to cast advanced spells.
 */
/datum/heretic_knowledge/cicatrix_focus
	name = "Cicatrix Focus"
	desc = "Allows you to transmute a sheet of glass and a pair of eyes to create a Cicatrix Focus. \
		A focus must be worn in order to cast more advanced spells."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	cost = 0
	route = PATH_START
