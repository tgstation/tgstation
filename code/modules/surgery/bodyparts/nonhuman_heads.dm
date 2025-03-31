GLOBAL_LIST_INIT(nonhuman_heads_to_organs, list(
	/obj/item/bodypart/head/bee = list(/obj/item/organ/tongue/bee),
	/obj/item/bodypart/head/bear = list(/obj/item/organ/snout/bear, /obj/item/organ/tongue/bear),
	/obj/item/bodypart/head/cow = list(/obj/item/organ/snout/cow, /obj/item/organ/tongue/beef),
	/obj/item/bodypart/head/fly = list(/obj/item/organ/tongue/fly, /obj/item/organ/fly),
	/obj/item/bodypart/head/frog = list(/obj/item/organ/tongue/frog),
	/obj/item/bodypart/head/horse = list(/obj/item/organ/snout/horse, /obj/item/organ/tongue/horse),
	/obj/item/bodypart/head/lizard = list(/obj/item/organ/horns, /obj/item/organ/frills, /obj/item/organ/snout, /obj/item/organ/tongue/lizard, /obj/item/organ/eyes/lizard),
	/obj/item/bodypart/head/monkey = list(/obj/item/organ/tongue/monkey),
	/obj/item/bodypart/head/moth = list(/obj/item/organ/antennae, /obj/item/organ/tongue/moth, /obj/item/organ/eyes/moth),
	/obj/item/bodypart/head/pig = list(/obj/item/organ/tongue/pig),
	/obj/item/bodypart/head/snail = list(/obj/item/organ/eyes/snail, /obj/item/organ/tongue/snail),
))

/obj/item/bodypart/head/bee
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_BEE
	bodyshape = BODYSHAPE_HUMANOID
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/organ/tongue/bee
	name = "bee tongue"
	desc = "The perfect length for getting right into a flower."
	say_mod = "buzzes"
	liked_foodtypes = VEGETABLES | FRUIT | GRAIN | BUGS | MEAT | ALCOHOL
	disliked_foodtypes = GROSS | SEAFOOD | FRIED

/obj/item/bodypart/head/bear
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_BEAR
	bodyshape = BODYSHAPE_HUMANOID
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/organ/tongue/bear
	name = "bear tongue"
	desc = "Bears are renowned for eating just about anything."
	say_mod = "roars"
	liked_foodtypes = ALL
	disliked_foodtypes = NONE

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
	layers = EXTERNAL_FRONT

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

/obj/item/organ/tongue/beef
	name = "beef tongue"
	desc = "Beef tongue is found in many national cuisines, and is used for taco fillings in Mexico and for open-faced sandwiches in the United Kingdom."
	say_mod = "moos"
	liked_foodtypes = VEGETABLES | GRAIN | DAIRY
	disliked_foodtypes = MEAT | BUGS | SEAFOOD | GORE

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
	layers = EXTERNAL_FRONT

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
	head_flags = HEAD_DEBRAIN

/obj/item/organ/tongue/frog
	name = "frog tongue"
	desc = "People often mistake the capabilities of a frog's muscular tongue with those of a chameleon. Due to its ability to be launched at great distances, this one might actually be a chameleon tongue though."
	say_mod = "croaks"
	liked_foodtypes = BUGS | SEAFOOD
	disliked_foodtypes = GRAIN | VEGETABLES | DAIRY
	/// Thing we give people
	var/datum/action/cooldown/spell/tongue_spike/ability

/obj/item/organ/tongue/frog/Initialize(mapload)
	. = ..()
	ability = new(src)

/obj/item/organ/tongue/frog/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	ability.Grant(receiver)

/obj/item/organ/tongue/frog/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	ability.Remove(organ_owner)

/obj/item/bodypart/head/horse
	icon = 'icons/mob/human/nonhuman_heads.dmi'
	icon_static = 'icons/mob/human/nonhuman_heads.dmi'
	dmg_overlay_type = null
	limb_id = SPECIES_HORSE
	bodyshape = BODYSHAPE_SNOUTED
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	head_flags = HEAD_DEBRAIN

/obj/item/organ/tongue/horse
	name = "horse tongue"
	desc = "The perfect shape for taking sugar cubes from the hands of young children."
	say_mod = "neighs"
	liked_foodtypes = FRUIT | GRAIN | VEGETABLES | ALCOHOL | SUGAR
	disliked_foodtypes = FRIED | SEAFOOD

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
	layers = EXTERNAL_FRONT

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

/obj/item/organ/tongue/pig
	name = "pig tongue"
	desc = "The powerful motive organ of nature's trash disposal."
	say_mod = "snorts"
	liked_foodtypes = ALL
	disliked_foodtypes = NONE

/obj/item/organ/tongue/pig/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	var/obj/item/organ/liver = receiver.get_organ_slot(ORGAN_SLOT_LIVER)
	if (liver)
		ADD_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM, REF(src))

/obj/item/organ/tongue/pig/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	var/obj/item/organ/liver = organ_owner.get_organ_slot(ORGAN_SLOT_LIVER)
	if (liver)
		ADD_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM, REF(src))
