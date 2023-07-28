/obj/item/bodypart/head/akula
	icon_greyscale = 'modular_skyraptor/modules/species_akula/icons/bodyparts.dmi'
	limb_id = SPECIES_AKULA
	is_dimorphic = FALSE

/obj/item/bodypart/chest/akula
	icon_greyscale = 'modular_skyraptor/modules/species_akula/icons/bodyparts.dmi'
	limb_id = SPECIES_AKULA
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/akula
	icon_greyscale = 'modular_skyraptor/modules/species_akula/icons/bodyparts.dmi'
	limb_id = SPECIES_AKULA
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/akula
	icon_greyscale = 'modular_skyraptor/modules/species_akula/icons/bodyparts.dmi'
	limb_id = SPECIES_AKULA
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/digitigrade/akula
	icon_greyscale = 'modular_skyraptor/modules/species_akula/icons/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/leg/left/digitigrade/akula/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_AKULA

/obj/item/bodypart/leg/right/digitigrade/akula
	icon_greyscale = 'modular_skyraptor/modules/species_akula/icons/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/akula/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_AKULA
