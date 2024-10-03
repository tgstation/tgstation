/obj/item/bodypart/head/ramatan
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	limb_id = SPECIES_RAMATAN
	is_dimorphic = FALSE
	eyes_icon = 'modular_doppler/modular_species/species_types/ramatae/icons/ramatan_eyes.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/chest/ramatan
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	limb_id = SPECIES_RAMATAN
	is_dimorphic = TRUE
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/arm/left/lizard/ramatan
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	limb_id = SPECIES_RAMATAN
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/arm/right/lizard/ramatan
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	limb_id = SPECIES_RAMATAN
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/leg/left/lizard/ramatan
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	limb_id = SPECIES_RAMATAN
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/leg/left/digitigrade/ramatan/
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/leg/left/digitigrade/ramatan/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_RAMATAN

/obj/item/bodypart/leg/right/lizard/ramatan
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'
	limb_id = SPECIES_RAMATAN
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/leg/right/digitigrade/ramatan/
	icon_greyscale = 'modular_doppler/modular_species/species_types/ramatae/icons/bodyparts.dmi'

/obj/item/bodypart/leg/right/digitigrade/ramatan/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_RAMATAN
