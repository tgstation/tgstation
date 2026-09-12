/obj/item/bodypart/head/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_head"
	icon_static = 'icons/mob/human/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYEHOLES|HEAD_DEBRAIN //what the fuck, moths have lips?
	teeth_count = 0
	bodypart_traits = list(TRAIT_ANTENNAE)

/obj/item/bodypart/chest/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_chest_m"
	icon_static = 'icons/mob/human/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	wing_types = list(/obj/item/organ/wings/megamoth, /obj/item/organ/wings/mothra)
	bodypart_traits = list(TRAIT_TACKLING_WINGED_ATTACKER)

	var/obj/item/bodypart/arm/left/moth/inner/left_inner
	var/obj/item/bodypart/arm/right/moth/inner/right_inner

/obj/item/bodypart/chest/moth/Initialize(mapload)
	. = ..()
	left_inner = new(src)
	right_inner = new(src)
	RegisterSignal(left_inner, COMSIG_BODYPART_POST_REMOVED, PROC_REF(slurp_up_limbs))
	RegisterSignal(right_inner, COMSIG_BODYPART_POST_REMOVED, PROC_REF(slurp_up_limbs))

/obj/item/bodypart/chest/moth/Destroy()
	QDEL_NULL(left_inner)
	QDEL_NULL(right_inner)
	return ..()

/obj/item/bodypart/chest/moth/proc/slurp_up_limbs(datum/source, mob/living/carbon/owner, special, dismembered)
	SIGNAL_HANDLER

	astype(source, /obj/item/bodypart/arm)?.forceMove(src)

/obj/item/bodypart/chest/moth/try_attach_limb(mob/living/carbon/new_owner, special, lazy)
	. = ..()
	if(!.)
		return

	new_owner.change_number_of_hands(4)
	left_inner.try_attach_limb(new_owner, special = TRUE)
	right_inner.try_attach_limb(new_owner, special = TRUE)

/obj/item/bodypart/chest/moth/on_removal(mob/living/carbon/old_owner)
	left_inner.drop_limb(special = TRUE, dismembered = FALSE, move_to_floor = FALSE)
	right_inner.drop_limb(special = TRUE, dismembered = FALSE, move_to_floor = FALSE)
	old_owner.change_number_of_hands(2)
	. = ..()

/obj/item/bodypart/chest/moth/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_FUZZY)

/obj/item/bodypart/arm/left/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_l_arm"
	icon_static = 'icons/mob/human/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verbs = list("slash")
	unarmed_attack_verbs_continuous = list("slashes")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_r_arm"
	icon_static = 'icons/mob/human/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verbs = list("slash")
	unarmed_attack_verbs_continuous = list("slashes")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_l_leg"
	icon_static = 'icons/mob/human/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_r_leg"
	icon_static = 'icons/mob/human/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/moth/inner
	body_zone = null
	held_index = 3
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_ABSTRACT

/obj/item/bodypart/arm/left/moth/inner/Initialize(mapload)
	held_hand_offset =  new (
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = 2, "south" = -2, "east" = 0),
		offset_y = list("south" = -12), // shhh
	)
	return ..()

/obj/item/bodypart/arm/left/moth/inner/drop_limb(special, dismembered, move_to_floor)
	if(special)
		return ..()
	return FALSE

/obj/item/bodypart/arm/left/moth/inner/generate_icon_key()
	return list()

/obj/item/bodypart/arm/right/moth/inner
	body_zone = null
	held_index = 4
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_ABSTRACT

/obj/item/bodypart/arm/right/moth/inner/Initialize(mapload)
	held_hand_offset = new (
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = -2, "south" = 2, "east" = 0),
		offset_y = list("south" = -12),
	)
	return ..()

/obj/item/bodypart/arm/right/moth/inner/drop_limb(special, dismembered, move_to_floor)
	if(special)
		return ..()
	return FALSE

/obj/item/bodypart/arm/right/moth/inner/generate_icon_key()
	return list()
