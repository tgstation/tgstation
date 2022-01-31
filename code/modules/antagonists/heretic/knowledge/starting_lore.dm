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
