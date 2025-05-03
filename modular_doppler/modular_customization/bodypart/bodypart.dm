/* Hoof
/obj/item/bodypart/leg/right/digitigrade/hoof
//	icon = ''
	limb_id = "digi_hoof"

/obj/item/bodypart/leg/right/digitigrade/hoof/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = "digi_hoof"

/obj/item/bodypart/leg/left/digitigrade/hoof
//	icon = ''
	limb_id = "digi_hoof"

/obj/item/bodypart/leg/left/digitigrade/hoof/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = "digi_hoof"

// Talon
/obj/item/bodypart/leg/right/digitigrade/talon
//	icon = ''
	limb_id = "digi_talon"

/obj/item/bodypart/leg/right/digitigrade/talon/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = "digi_talon"

/obj/item/bodypart/leg/left/digitigrade/talon
//	icon = ''
	limb_id = "digi_talon"

/obj/item/bodypart/leg/left/digitigrade/talon/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(limb_id == SPECIES_LIZARD)
		limb_id = "digi_talon" */
