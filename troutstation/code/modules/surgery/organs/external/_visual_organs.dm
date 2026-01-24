/obj/item/organ/anteater_snout
	name = "anteater snout"
	desc = "Makes for an absolutely terrible trombone."
	icon = 'troutstation/icons/obj/medical/organs/organs.dmi'
	icon_state = "anteater_snout"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTEATER_SNOUT

	// external_bodyshapes = BODYSHAPE_SNOUTED

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/anteater
	dna_block = /datum/dna_block/feature/anteater_snout

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL
	organ_traits = list(TRAIT_TINY_SNOUT)

	/// Offset to apply to equipment worn on the mouth we give to the head.
	var/datum/worn_feature_offset/worn_mask_offset

/obj/item/organ/anteater_snout/on_bodypart_insert(obj/item/bodypart/head/limb)
	. = ..()
	if(isnull(limb.worn_mask_offset))
		worn_mask_offset = limb.worn_mask_offset = new(
			attached_part = limb,
			feature_key = OFFSET_FACEMASK,
			offset_x = list("east" = 3, "west" = -3),
		)

/obj/item/organ/anteater_snout/on_bodypart_remove(obj/item/bodypart/head/limb, movement_flags)
	if(worn_mask_offset)
		QDEL_NULL(worn_mask_offset)
		limb.worn_mask_offset = null
	return ..()

/datum/bodypart_overlay/mutant/snout/anteater
	feature_key = FEATURE_ANTEATER_SNOUT
