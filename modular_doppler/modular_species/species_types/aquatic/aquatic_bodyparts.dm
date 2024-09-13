/obj/item/bodypart/head/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'
	eyes_icon = 'modular_doppler/modular_species/species_types/aquatic/icons/eyes.dmi'
	limb_id = SPECIES_AQUATIC
	is_dimorphic = FALSE

/obj/item/bodypart/chest/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'
	limb_id = SPECIES_AQUATIC

/obj/item/bodypart/arm/left/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'
	limb_id = SPECIES_AQUATIC

/obj/item/bodypart/arm/right/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'
	limb_id = SPECIES_AQUATIC

/obj/item/bodypart/leg/left/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'
	limb_id = SPECIES_AQUATIC

/obj/item/bodypart/leg/left/digitigrade/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'

/obj/item/bodypart/leg/left/digitigrade/aquatic/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_AQUATIC

/obj/item/bodypart/leg/right/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'
	limb_id = SPECIES_AQUATIC

/obj/item/bodypart/leg/right/digitigrade/aquatic
	icon_greyscale = 'modular_doppler/modular_species/species_types/aquatic/icons/bodyparts.dmi'

/obj/item/bodypart/leg/right/digitigrade/aquatic/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_AQUATIC
