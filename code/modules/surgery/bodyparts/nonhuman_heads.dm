/obj/item/bodypart/head/bee
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_BEE
	bodyshape = BODYSHAPE_HUMANOID
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/bodypart/head/bear
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_BEAR
	bodyshape = BODYSHAPE_HUMANOID
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/organ/snout/bear
	name = "bear snout"
	desc = "Whoever's missing this is finding it unbearable!"
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_state = "bear_snout"
	preference = null
	external_bodyshapes = BODYSHAPE_SNOUTED
	bodypart_overlay = /datum/bodypart_overlay/simple/snout_bear

/datum/bodypart_overlay/simple/snout_bear
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_state = "bear_snout"
	layers = EXTERNAL_ADJACENT

/datum/bodypart_overlay/simple/snout_bear/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDESNOUT) || (human.wear_mask?.flags_inv & HIDESNOUT))
		return FALSE
	return TRUE

/obj/item/bodypart/head/cow
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_COW
	bodyshape = BODYSHAPE_SNOUTED
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/organ/snout/cow
	name = "cow snout"
	desc = "Are you not amoosed?"
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_state = "cow_snout"
	preference = null
	external_bodyshapes = BODYSHAPE_SNOUTED
	bodypart_overlay = /datum/bodypart_overlay/simple/snout_cow

/datum/bodypart_overlay/simple/snout_cow
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_state = "cow_snout"
	layers = EXTERNAL_ADJACENT

/datum/bodypart_overlay/simple/snout_cow/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDESNOUT) || (human.wear_mask?.flags_inv & HIDESNOUT))
		return FALSE
	return TRUE

/obj/item/bodypart/head/frog
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_FROG
	bodyshape = BODYSHAPE_HUMANOID
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN|HEAD_HAIR

/obj/item/bodypart/head/horse
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_HORSE
	bodyshape = BODYSHAPE_SNOUTED
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/organ/snout/horse
	name = "horse snout"
	desc = "Quit horsing around and stick it back on!"
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_state = "horse_snout"
	preference = null
	external_bodyshapes = BODYSHAPE_SNOUTED
	bodypart_overlay = /datum/bodypart_overlay/simple/snout_horse

/datum/bodypart_overlay/simple/snout_horse
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_state = "horse_snout"
	layers = EXTERNAL_ADJACENT

/datum/bodypart_overlay/simple/snout_horse/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDESNOUT) || (human.wear_mask?.flags_inv & HIDESNOUT))
		return FALSE
	return TRUE

/obj/item/bodypart/head/pig
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_PIG
	bodyshape = BODYSHAPE_HUMANOID
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN|HEAD_HAIR

