/obj/item/bodypart/head/talonmoth
	icon_greyscale = 'modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi'
	limb_id = SPECIES_TALONMOTH
	is_dimorphic = FALSE

/obj/item/bodypart/chest/talonmoth
	icon_greyscale = 'modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi'
	limb_id = SPECIES_TALONMOTH
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/talonmoth
	icon_greyscale = 'modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi'
	limb_id = SPECIES_TALONMOTH
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/talonmoth
	icon_greyscale = 'modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi'
	limb_id = SPECIES_TALONMOTH
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/digitigrade/talonmoth
	icon_greyscale = 'modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/leg/left/digitigrade/talonmoth/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_TALONMOTH

/obj/item/bodypart/leg/right/digitigrade/talonmoth
	icon_greyscale = 'modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi'
	limb_id = BODYPART_ID_DIGITIGRADE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/talonmoth/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_TALONMOTH
