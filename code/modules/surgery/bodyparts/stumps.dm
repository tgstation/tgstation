// Invisible bodyparts that serve as placeholders for a missing limb
// Used so we can add behavior to "missing limbs" without putting it on the mob itself
/obj/item/bodypart/leg/left/stump
	name = "stump"
	limb_id = null
	plaintext_zone = "left leg stump"
	stump_typepath = null
	scarrable = FALSE
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN

/obj/item/bodypart/leg/left/stump/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PARALYSIS, STUMP_TRAIT)

/obj/item/bodypart/leg/right/stump
	name = "stump"
	limb_id = null
	plaintext_zone = "right leg stump"
	stump_typepath = null
	scarrable = FALSE
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN

/obj/item/bodypart/leg/right/stump/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PARALYSIS, STUMP_TRAIT)

/obj/item/bodypart/arm/left/stump
	name = "stump"
	limb_id = null
	plaintext_zone = "left arm stump"
	stump_typepath = null
	scarrable = FALSE
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN

/obj/item/bodypart/arm/left/stump/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PARALYSIS, STUMP_TRAIT)

/obj/item/bodypart/arm/right/stump
	name = "stump"
	limb_id = null
	plaintext_zone = "right arm stump"
	stump_typepath = null
	scarrable = FALSE
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN

/obj/item/bodypart/arm/right/stump/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PARALYSIS, STUMP_TRAIT)

/obj/item/bodypart/head/stump
	name = "stump"
	limb_id = null
	plaintext_zone = "neck stump"
	stump_typepath = null
	scarrable = FALSE
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN

	head_flags = NONE
	teeth_count = 0 // lol?

/obj/item/bodypart/head/stump/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PARALYSIS, STUMP_TRAIT)
