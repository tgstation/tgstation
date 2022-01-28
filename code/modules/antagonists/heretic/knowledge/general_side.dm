// Some general sidepath options.

/datum/heretic_knowledge/reroll_targets
	name = "The Relentless Heartbeat"
	desc = "Allows you to reroll your sacrifice targets by standing on a transmutation rune \
		and invoking it with a harebell, a book, and a jumpsuit."
	gain_text = "The heart is the principle that continues and preserves."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
	)
	cost = 1

/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || !HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!LAZYLEN(heretic_datum.sac_targets))
		return FALSE

	atoms += user
	return (user in range(1, loc))

/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	LAZYCLEARLIST(heretic_datum.sac_targets)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user))
		return FALSE

	return TRUE
