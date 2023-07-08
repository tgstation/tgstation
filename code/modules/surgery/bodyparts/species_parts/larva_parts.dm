/obj/item/bodypart/head/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_head"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	bodytype = BODYTYPE_LARVA | BODYTYPE_ORGANIC
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 50

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_chest"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_LARVA | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_LARVA
	bodypart_flags = BODYPART_UNREMOVABLE
	burn_modifier = 2
	max_damage = 50
