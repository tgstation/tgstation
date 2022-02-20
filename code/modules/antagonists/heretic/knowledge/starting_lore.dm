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
	/// The typepath of the organ type required for our heart.
	var/required_organ_type = /obj/item/organ/heart

/datum/heretic_knowledge/living_heart/on_research(mob/user)
	. = ..()

	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/where_to_put_our_heart = user.getorganslot(our_heretic.living_heart_organ_slot)

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/liver,
			ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.getorganslot(backup_slot)
			if(look_for_backup)
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

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	if(!our_living_heart || HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return FALSE

	if(our_living_heart.status == ORGAN_ORGANIC)
		return TRUE

	else
		for(var/obj/item/organ/nearby_organ in atoms)
			if(!istype(nearby_organ, required_organ_type))
				continue

			if(nearby_organ.status == ORGAN_ORGANIC && nearby_organ.useable)
				selected_atoms += nearby_organ
				return TRUE

		return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/our_new_heart = user.getorganslot(our_heretic.living_heart_organ_slot)

	if(our_new_heart.status != ORGAN_ORGANIC)
		var/obj/item/organ/our_replacement_heart = locate(required_organ_type) in selected_atoms
		if(our_replacement_heart)
			user.visible_message("[user]'s [our_replacement_heart.name] bursts suddenly out of [user.p_their()] chest!")
			INVOKE_ASYNC(user, /mob/proc/emote, "scream")
			user.apply_damage(20, BRUTE, BODY_ZONE_CHEST)

			our_replacement_heart.Insert(user, TRUE, TRUE)
			our_new_heart.throw_at(get_edge_target_turf(user, pick(GLOB.alldirs)), 2, 2)
			our_new_heart = our_replacement_heart

	if(!our_new_heart)
		CRASH("[type] somehow made it to on_finished_recipe without a heart. What?")

	if(our_new_heart in selected_atoms)
		selected_atoms -= our_new_heart

	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("You feel your [our_new_heart.name] begin pulse faster and faster as it awakens!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
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
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	cost = 0
	route = PATH_START

/datum/heretic_knowledge/amber_focus/cleanup_atoms(list/selected_atoms)
	var/obj/item/stack/sheet/glass/sheets = locate() in selected_atoms
	if(sheets)
		selected_atoms -= sheets
		sheets.use(1)
	return ..()
