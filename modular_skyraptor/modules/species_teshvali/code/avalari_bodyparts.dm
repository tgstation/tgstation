/obj/item/bodypart/head/avalari
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_AVALARI
	is_dimorphic = FALSE
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_AVALARI

/obj/item/bodypart/head/avalari/Initialize(mapload)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list("east" = 2, "west" = -2),
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	return ..()

/obj/item/bodypart/chest/avalari
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_AVALARI
	is_dimorphic = TRUE
	acceptable_bodytype = BODYTYPE_AVALARI
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_AVALARI

/obj/item/bodypart/chest/avalari/Initialize(mapload)
	worn_belt_offset = new(
		attached_part = src,
		feature_key = OFFSET_BELT,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_back_offset = new(
		attached_part = src,
		feature_key = OFFSET_BACK,
		offset_x = list("east" = 2, "west" = -2),
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	worn_suit_offset = new(
		attached_part = src,
		feature_key = OFFSET_SUIT,
		//offset_x = list("east" = -1, "west" = 1),
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_uniform_offset = new(
		attached_part = src,
		feature_key = OFFSET_UNIFORM,
		//offset_x = list("east" = -1, "west" = 1),
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	return ..()

/obj/item/bodypart/arm/left/avalari
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_AVALARI
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_AVALARI

/obj/item/bodypart/arm/left/avalari/Initialize(mapload)
	held_hand_offset =  new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_y = list("north" = 2, "south" = -1, "east" = -1, "west" = -4),
		offset_y = list("north" = -5, "south" = -4, "east" = -3, "west" = -3),
	)
	return ..()

/obj/item/bodypart/arm/right/avalari
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_AVALARI
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_AVALARI

/obj/item/bodypart/arm/right/avalari/Initialize(mapload)
	held_hand_offset =  new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_y = list("north" = -2, "south" = 1, "east" = 4, "west" = 1),
		offset_y = list("north" = -6, "south" = -5, "east" = -4, "west" = -4),
	)
	return ..()

/obj/item/bodypart/leg/left/avalari
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_AVALARI
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_AVALARI

/obj/item/bodypart/leg/right/avalari
	icon_greyscale = 'modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi'
	limb_id = SPECIES_AVALARI
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_AVALARI
