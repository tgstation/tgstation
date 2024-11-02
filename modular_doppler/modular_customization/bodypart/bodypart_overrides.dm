/// If you need to make edits to existing bodyparts, do so in here.
/obj/item/bodypart
	/// Override of the base bodypart datum to add a seperate list for customization markings. This is to avoid the dimorphic marking system while trying to keep the code as modular as possible using overrides.
	var/list/markings = list()

/obj/item/bodypart/head
	/// Override of the eyes icon file - used for ramatae as test dummies, followed by teshies, vox, possibly moths & insects, and more!
	var/eyes_icon

/obj/item/bodypart/head/lizard
	head_flags = HEAD_ALL_FEATURES

/obj/item/bodypart/head/moth
	head_flags = HEAD_ALL_FEATURES

/obj/item/bodypart/head/robot
	head_flags = HEAD_EYESPRITES | HEAD_FACIAL_HAIR | HEAD_HAIR | HEAD_EYECOLOR

/obj/item/bodypart/head/snail
	head_flags = HEAD_EYESPRITES | HEAD_DEBRAIN | HEAD_FACIAL_HAIR | HEAD_HAIR

/// Extending species to support alternate digilegs
/datum/species
	var/list/digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade,
	)

/datum/bodypart_overlay/simple/body_marking/lizard
	applies_to = list(
		/obj/item/bodypart/head,
		/obj/item/bodypart/chest,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right,
		)
