// Some general sidepath options.

/datum/heretic_knowledge/reroll_targets
	name = "The Relentless Heartbeat"
	desc = "Allows you transmute a harebell, a book, and a jumpsuit while standing over a rune \
		to reroll your sacrifice targets."
	gain_text = "The heart is the principle that continues and preserves."
	required_atoms = list(
		/obj/item/food/grown/harebell = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
		/mob/living/carbon/human = 1,
	)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || !HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!LAZYLEN(heretic_datum.sac_targets))
		return FALSE

	atoms += user
	return (user in range(1, loc))

/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	LAZYCLEARLIST(heretic_datum.sac_targets)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user))
		return FALSE

	return TRUE

/datum/heretic_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to transmute a bible, a fountain pen, and hide from an animal (or human) to create a Codex Cicatrix. \
		The Codex Cicatrix can be used when draining influences to gain additional knowledge, but comes at greater risk of being noticed. \
		It can also be used to draw and remove transmutation runes easier."
	gain_text = "The occult leaves fragments of knowledge and power anywhere and everywhere. The Codex Cicatrix is one such example. \
		Within the leather-bound faces and age old pages, a path into the Mansus is revealed."
	required_atoms = list(
		/obj/item/storage/book/bible = 1,
		/obj/item/pen/fountain = 1,
		/obj/item/stack/sheet/animalhide = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/obj/item/stack/sheet/animalhide/hide = locate() in selected_atoms
	if(hide)
		selected_atoms -= hide
		hide.use(1)
	return ..()
