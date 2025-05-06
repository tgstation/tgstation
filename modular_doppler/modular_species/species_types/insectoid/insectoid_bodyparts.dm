/obj/item/bodypart/head/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'
	eyes_icon = 'modular_doppler/modular_species/species_types/insectoid/icons/eyes.dmi'
	limb_id = SPECIES_INSECTOID
	damage_overlay_color = COLOR_DARK_MODERATE_LIME_GREEN
	is_dimorphic = FALSE

/obj/item/bodypart/chest/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'
	limb_id = SPECIES_INSECTOID
	damage_overlay_color = COLOR_DARK_MODERATE_LIME_GREEN

/obj/item/bodypart/arm/left/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'
	limb_id = SPECIES_INSECTOID
	damage_overlay_color = COLOR_DARK_MODERATE_LIME_GREEN

/obj/item/bodypart/arm/right/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'
	limb_id = SPECIES_INSECTOID


/obj/item/bodypart/leg/left/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'
	limb_id = SPECIES_INSECTOID

/obj/item/bodypart/leg/left/digitigrade/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'

/obj/item/bodypart/leg/left/digitigrade/insectoid/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_INSECTOID

/obj/item/bodypart/leg/right/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'
	limb_id = SPECIES_INSECTOID

/obj/item/bodypart/leg/right/digitigrade/insectoid
	icon_greyscale = 'modular_doppler/modular_species/species_types/insectoid/icons/bodyparts.dmi'

/obj/item/bodypart/leg/right/digitigrade/insectoid/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = SPECIES_INSECTOID
