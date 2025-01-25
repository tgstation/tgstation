/obj/item/bodypart/head/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'
//	eyes_icon = 'modular_doppler/modular_species/species_types/anthromorph/icons/eyes.dmi' to be restored when blinking for 2px eyes is implemented
	limb_id = SPECIES_ANTHROMORPH
	is_dimorphic = FALSE

/obj/item/bodypart/chest/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'
	limb_id = SPECIES_ANTHROMORPH

/obj/item/bodypart/arm/left/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'
	limb_id = SPECIES_ANTHROMORPH

/obj/item/bodypart/arm/right/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'
	limb_id = SPECIES_ANTHROMORPH

/obj/item/bodypart/leg/left/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'
	limb_id = SPECIES_ANTHROMORPH

/obj/item/bodypart/leg/left/digitigrade/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'

/obj/item/bodypart/leg/left/digitigrade/anthromorph/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_ANTHROMORPH

/obj/item/bodypart/leg/right/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'
	limb_id = SPECIES_ANTHROMORPH

/obj/item/bodypart/leg/right/digitigrade/anthromorph
	icon_greyscale = 'modular_doppler/modular_species/species_types/anthromorph/icons/bodyparts.dmi'

/obj/item/bodypart/leg/right/digitigrade/anthromorph/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_ANTHROMORPH
