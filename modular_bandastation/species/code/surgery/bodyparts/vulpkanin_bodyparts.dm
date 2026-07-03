/obj/item/bodypart/head/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR
	species_hair_mask = /datum/hair_mask/vulp

/obj/item/bodypart/chest/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	is_dimorphic = TRUE

/obj/item/bodypart/chest/vulpkanin/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_VULPKANIN)

/obj/item/bodypart/arm/left/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN
	unarmed_attack_verbs = list("slash")
	grappled_attack_verb = "lacerate"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN

/obj/item/bodypart/leg/right/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = SPECIES_VULPKANIN

/obj/item/bodypart/leg/left/digitigrade/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	species_id = SPECIES_VULPKANIN
	bodyshape = BODYSHAPE_HUMANOID
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/digitigrade/vulpkanin/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/digitigrade_limb, SPECIES_VULPKANIN, initial(limb_id))

/obj/item/bodypart/leg/right/digitigrade/vulpkanin
	icon_greyscale = 'icons/bandastation/mob/species/vulpkanin/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	species_id = SPECIES_VULPKANIN
	bodyshape = BODYSHAPE_HUMANOID
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/digitigrade/vulpkanin/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/digitigrade_limb, SPECIES_VULPKANIN, initial(limb_id))
