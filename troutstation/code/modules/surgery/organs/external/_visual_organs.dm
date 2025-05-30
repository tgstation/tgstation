/obj/item/organ/anteater_snout
	name = "anteater snout"
	desc = "Makes for an absolutely terrible trombone."
	icon = 'troutstation/icons/obj/medical/organs/organs.dmi'
	icon_state = "anteater_snout"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTEATER_SNOUT

	preference = "feature_anteater_snout"
	// external_bodyshapes = BODYSHAPE_SNOUTED

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/anteater

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/snout/anteater
	feature_key = "anteater_snout"

/datum/bodypart_overlay/mutant/snout/anteater/get_global_feature_list()
	return SSaccessories.anteater_snouts_list

// let's violate the whole "visual organ" thing and add some extra functionality
/obj/item/organ/anteater_snout/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	organ_owner.add_traits(list(TRAIT_TINY_SNOUT), ORGAN_TRAIT)

/obj/item/organ/anteater_snout/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	organ_owner.remove_traits(list(TRAIT_TINY_SNOUT), ORGAN_TRAIT)


