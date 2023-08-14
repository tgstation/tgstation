/obj/item/bodypart/head/teshvali
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_TESHVALI
	is_dimorphic = FALSE
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_TESHVALI

/obj/item/bodypart/head/teshvali/Initialize(mapload)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	return ..()

/obj/item/bodypart/chest/teshvali
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_TESHVALI
	is_dimorphic = TRUE
	acceptable_bodytype = BODYTYPE_TESHVALI
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_TESHVALI

/obj/item/bodypart/chest/teshvali/Initialize(mapload)
	worn_belt_offset = new(
		attached_part = src,
		feature_key = OFFSET_BELT,
		offset_x = list("east" = -1, "west" = 1),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	worn_suit_offset = new(
		attached_part = src,
		feature_key = OFFSET_SUIT,
		//offset_x = list("east" = -1, "west" = 1),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	worn_uniform_offset = new(
		attached_part = src,
		feature_key = OFFSET_UNIFORM,
		//offset_x = list("east" = -1, "west" = 1),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	worn_back_offset = new(
		attached_part = src,
		feature_key = OFFSET_BACK,
		offset_x = list("east" = 2, "west" = -2),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	return ..()

/obj/item/bodypart/arm/left/teshvali
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_TESHVALI
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_TESHVALI

/obj/item/bodypart/arm/left/teshvali/Initialize(mapload)
	held_hand_offset =  new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("east" = -2, "west" = -1, "north" = -1),
		offset_y = list("north" = -4, "south" = -5, "east" = -2, "west" = -4),
	)
	return ..()

/obj/item/bodypart/arm/right/teshvali
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_TESHVALI
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_TESHVALI

/obj/item/bodypart/arm/right/teshvali/Initialize(mapload)
	held_hand_offset =  new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("west" = 2, "east" = 1, "north" = 1),
		offset_y = list("north" = -4, "south" = -5, "east" = -4, "west" = -2),
	)
	return ..()

/obj/item/bodypart/leg/left/teshvali
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_TESHVALI
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_TESHVALI

/obj/item/bodypart/leg/right/teshvali
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_TESHVALI
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_TESHVALI
