/obj/item/bodypart/leg/left/digitigrade/genemod
	icon_greyscale = 'modular_doppler/modular_species/species_types/genemod/icons/bodyparts.dmi'

/obj/item/bodypart/leg/left/digitigrade/genemod/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_HUMAN

/obj/item/bodypart/leg/right/digitigrade/genemod
	icon_greyscale = 'modular_doppler/modular_species/species_types/genemod/icons/bodyparts.dmi'

/obj/item/bodypart/leg/right/digitigrade/genemod/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_HUMAN
