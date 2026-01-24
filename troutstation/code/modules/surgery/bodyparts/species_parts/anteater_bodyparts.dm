/obj/item/bodypart/head/anteater
	icon_greyscale = 'troutstation/icons/mob/human/species/anteater/bodyparts.dmi'
	limb_id = SPECIES_ANTEATER
	is_dimorphic = FALSE
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	teeth_count = 0

/obj/item/bodypart/chest/anteater
	icon_greyscale = 'troutstation/icons/mob/human/species/anteater/bodyparts.dmi'
	limb_id = SPECIES_ANTEATER
	is_dimorphic = TRUE
	wing_types = null

/obj/item/bodypart/arm/left/anteater
	icon_greyscale = 'troutstation/icons/mob/human/species/anteater/bodyparts.dmi'
	limb_id = SPECIES_ANTEATER
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/left/anteater/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponentFrom(REF(src), /datum/component/shovel_hands)

/obj/item/bodypart/arm/left/anteater/on_removal(mob/living/carbon/old_owner)
	. = ..()
	old_owner.RemoveComponentSource(REF(src), /datum/component/shovel_hands)

/obj/item/bodypart/arm/right/anteater
	icon_greyscale = 'troutstation/icons/mob/human/species/anteater/bodyparts.dmi'
	limb_id = SPECIES_ANTEATER
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/anteater/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponentFrom(REF(src), /datum/component/shovel_hands)

/obj/item/bodypart/arm/right/anteater/on_removal(mob/living/carbon/old_owner)
	. = ..()
	old_owner.RemoveComponentSource(REF(src), /datum/component/shovel_hands)

/obj/item/bodypart/leg/left/anteater
	icon_greyscale = 'troutstation/icons/mob/human/species/anteater/bodyparts.dmi'
	limb_id = SPECIES_ANTEATER
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/anteater
	icon_greyscale = 'troutstation/icons/mob/human/species/anteater/bodyparts.dmi'
	limb_id = SPECIES_ANTEATER
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW
