// Heretic starting knowledge.

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
	spell_to_add = /datum/action/cooldown/spell/touch/mansus_grasp
	cost = 0
	route = PATH_START

/datum/heretic_knowledge/spell/basic/New()
	. = ..()
	next_knowledge = subtypesof(/datum/heretic_knowledge/limited_amount/starting)

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
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	route = PATH_START
	/// The typepath of the organ type required for our heart.
	var/required_organ_type = /obj/item/organ/internal/heart

/datum/heretic_knowledge/living_heart/on_research(mob/user)
	. = ..()

	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/where_to_put_our_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	// Our heart slot is not valid to put a heart
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			ORGAN_SLOT_LUNGS = /obj/item/organ/internal/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver,
			ORGAN_SLOT_STOMACH = /obj/item/organ/internal/stomach,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.getorganslot(backup_slot)
			// This backup slot is not a valid slot to put a heart
			if(!is_valid_heart(look_for_backup))
				continue

			// We found a replacement place to put our heart
			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			required_organ_type = backup_organs[backup_slot]
			to_chat(user, span_boldnotice("As your species does not have a heart, your Living Heart is located in your [look_for_backup.name]."))
			break

	if(where_to_put_our_heart)
		where_to_put_our_heart.AddComponent(/datum/component/living_heart)
		desc = "Grants you a Living Heart, tied to your [where_to_put_our_heart.name], \
			allowing you to track sacrifice targets. \
			Should you lose your [where_to_put_our_heart.name], you can transmute a poppy and a pool of blood \
			to awaken your replacement [where_to_put_our_heart.name] into a Living Heart. \
			If your [where_to_put_our_heart.name] is cybernetic, \
			you will additionally require a usable organic [where_to_put_our_heart.name] in the transmutation."

	else
		to_chat(user, span_boldnotice("You don't have a heart, or any chest organs for that matter. You didn't get a Living Heart because of it."))

/datum/heretic_knowledge/living_heart/on_lose(mob/user)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	if(our_living_heart)
		qdel(our_living_heart.GetComponent(/datum/component/living_heart))

// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.has_living_heart() == HERETIC_HAS_LIVING_HEART)
		return FALSE
	return TRUE

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	// Obviously you need a heart in your chest to do a ritual on your... heart
	if(!our_living_heart)
		loc.balloon_alert(user, "ritual failed, you have no [our_heretic.living_heart_organ_slot]!") // "you have no heart!"
		return FALSE
	// For sanity's sake, check if they've got a heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "ritual failed, already have a living heart!")
		return FALSE

	// By this point they are making a new heart
	// If their current heart is organic / not synthetic, we can continue the ritual as normal
	if(is_valid_heart(our_living_heart))
		return TRUE

	// If their current heart is not organic / is synthetic, they need an organic replacement
	// ...But if our organ-to-be-replaced is unremovable, we're screwed
	if(our_living_heart.organ_flags & ORGAN_UNREMOVABLE)
		loc.balloon_alert(user, "ritual failed, [our_heretic.living_heart_organ_slot] unremovable!") // "heart unremovable!"
		return FALSE

	// Otherwise, seek out a replacement in our atoms
	for(var/obj/item/organ/nearby_organ in atoms)
		if(!istype(nearby_organ, required_organ_type))
			continue
		if(!is_valid_heart(nearby_organ))
			continue

		selected_atoms += nearby_organ
		return TRUE

	loc.balloon_alert(user, "ritual failed, need a replacement [our_heretic.living_heart_organ_slot]!") // "need a replacement heart!"
	return FALSE

/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/our_new_heart = user.getorganslot(our_heretic.living_heart_organ_slot)

	// Our heart is robotic or synthetic - we need to replace it, and we fortunately should have one by here
	if(!is_valid_heart(our_new_heart))
		var/obj/item/organ/our_replacement_heart = locate(required_organ_type) in selected_atoms
		if(our_replacement_heart)
			// Throw our current heart out of our chest, violently
			user.visible_message(span_boldwarning("[user]'s [our_new_heart.name] bursts suddenly out of [user.p_their()] chest!"))
			INVOKE_ASYNC(user, /mob/proc/emote, "scream")
			user.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			// And put our organic heart in its place
			our_replacement_heart.Insert(user, TRUE, TRUE)
			our_new_heart.throw_at(get_edge_target_turf(user, pick(GLOB.alldirs)), 2, 2)
			our_new_heart = our_replacement_heart
		else
			CRASH("[type] required a replacement organic heart in on_finished_recipe, but did not find one.")

	if(!our_new_heart)
		CRASH("[type] somehow made it to on_finished_recipe without a heart. What?")

	// Snowflakey, but if the user used a heart that wasn't beating
	// they'll immediately collapse into a heart attack. Funny but not ideal.
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.set_heartattack(FALSE)

	// Don't delete our shiny new heart
	selected_atoms -= our_new_heart
	// Make it the living heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("You feel your [our_new_heart.name] begin pulse faster and faster as it awakens!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	return TRUE

/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/new_heart)
	if(!new_heart)
		return FALSE
	if(!new_heart.useable)
		return FALSE
	if(new_heart.status != ORGAN_ORGANIC)
		return FALSE
	if(new_heart.organ_flags & (ORGAN_SYNTHETIC|ORGAN_FAILING))
		return FALSE

	return TRUE

/**
 * Allows the heretic to craft a spell focus.
 * They require a focus to cast advanced spells.
 */
/datum/heretic_knowledge/amber_focus
	name = "Amber Focus"
	desc = "Allows you to transmute a sheet of glass and a pair of eyes to create an Amber Focus. \
		A focus must be worn in order to cast more advanced spells."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Not as important as making a heart or sacrificing, but important enough.
	route = PATH_START

/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Cloak of Shadow"
	desc = "Grants you the spell Cloak of Shadow. This spell will completely conceal your identity in a purple smoke \
		for three minutes, assisting you in keeping secrecy. Requires a focus to cast."
	spell_to_add = /datum/action/cooldown/spell/shadow_cloak
	cost = 0
	route = PATH_START
