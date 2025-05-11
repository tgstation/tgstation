/obj/item/organ/taur_body/serpentine
	left_leg_name = "upper serpentine body"
	right_leg_name = "lower serpentine body"

	clothing_cropping_state = NAGA_CLIPPING_MASK
	external_bodyshapes = parent_type::external_bodyshapes | BODYSHAPE_TAUR_SNAKE

	/// The constrict ability we have given our owner. Nullable, if we have no owner.
	var/datum/action/innate/constrict/constrict_ability

	/// Did our owner have their feet blocked before we ran on_mob_insert? Used for determining if we should unblock their feet slots on removal.
	var/owner_blocked_feet_before_insert

/obj/item/organ/taur_body/serpentine/synth
	organ_flags = parent_type::organ_flags | ORGAN_ROBOTIC

/obj/item/organ/taur_body/serpentine/Destroy()
	QDEL_NULL(constrict_ability) // handled in remove, but lets be safe
	return ..()

/obj/item/organ/taur_body/serpentine/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	// These args must be the same as the args used to add the basic human footstep!
	organ_owner.RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	organ_owner.AddElement(/datum/element/footstep, FOOTSTEP_MOB_SNAKE, 15, -6)

	constrict_ability = new /datum/action/innate/constrict(organ_owner)
	constrict_ability.Grant(organ_owner)

	owner_blocked_feet_before_insert = (organ_owner.dna.species.no_equip_flags & ITEM_SLOT_FEET)
	organ_owner.dna.species.no_equip_flags |= ITEM_SLOT_FEET
	organ_owner.dna.species.modsuit_slot_exceptions |= ITEM_SLOT_FEET

	var/obj/item/clothing/shoes/shoe = organ_owner.get_item_by_slot(ITEM_SLOT_FEET)
	if (shoe && !HAS_TRAIT(shoe, TRAIT_NODROP))
		shoe.forceMove(get_turf(organ_owner))

	add_hardened_soles(organ_owner)

/// Adds TRAIT_HARD_SOLES to our owner.
/obj/item/organ/taur_body/serpentine/proc/add_hardened_soles(mob/living/carbon/organ_owner = owner)
	ADD_TRAIT(organ_owner, TRAIT_HARD_SOLES, ORGAN_TRAIT)

/obj/item/organ/taur_body/serpentine/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	if (QDELETED(organ_owner)) return
	organ_owner.RemoveElement(/datum/element/footstep,  FOOTSTEP_MOB_SNAKE, 15, -6)
	organ_owner.AddElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)

	QDEL_NULL(constrict_ability)
	if (!owner_blocked_feet_before_insert)
		organ_owner.dna.species.no_equip_flags &= ~ITEM_SLOT_FEET
	owner_blocked_feet_before_insert = FALSE
	organ_owner.dna.species.modsuit_slot_exceptions &= ~ITEM_SLOT_FEET

	REMOVE_TRAIT(organ_owner, TRAIT_HARD_SOLES, ORGAN_TRAIT)
