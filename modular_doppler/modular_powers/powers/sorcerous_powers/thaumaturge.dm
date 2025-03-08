/**
 * Root powers
 */

/datum/power/item/spellprep

	name = "Spell Preparation"
	desc = "Allows a Sorcerous individual to prepare and use a spellbook, which can be re-skinned as a spell focus or a bag of materials. All Thaumaturge abilities require the use of a spellbook."
	cost = 5
	root_power = /datum/power/item/spellprep
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE
	gain_text = span_notice("You appear to have accidentaly picked up some random book instead of your spellbook...")

/datum/power/item/spellprep/add(mob/living/carbon/human/target)
	var/obj/item/book/random/spellbook = new(get_turf(target))
	spellbook.name = "[target.real_name]'s spellbook"
	give_item_to_holder(target, spellbook, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
