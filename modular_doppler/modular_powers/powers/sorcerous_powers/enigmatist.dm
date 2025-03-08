#define CAT_ENIGMATIST "Enigmatist"

/**
 * Root powers
 */

/datum/power/chalk

	name = "Produce Resonant Chalk"
	desc = "Allows a Sorcerous individual to prepare and use a spellbook, which can be re-skinned as a spell focus or a bag of materials. All Thaumaturge abilities require the use of a spellbook."
	cost = 5
	root_power = /datum/power/chalk
	power_type = TRAIT_PATH_SUBTYPE_ENIGMATIST

/datum/power/chalk/add(mob/living/carbon/human/target)
	target.mind.teach_crafting_recipe(/datum/crafting_recipe/resonant_chalk)

/datum/crafting_recipe/resonant_chalk
	name = "Resonant Chalk"
	result = /obj/item/toy/crayon/purple/resonant_chalk
	reqs = list(
		/obj/item/stack/sheet/mineral/plasma = 1,
		/obj/item/toy/crayon,
	)
	time = 5 SECONDS
	category = CAT_ENIGMATIST
	crafting_flags = CRAFT_MUST_BE_LEARNED

/obj/item/toy/crayon/purple/resonant_chalk
	name = "Resonant Chalk"
