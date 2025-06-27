/obj/item/bodypart/head/ghost
	icon = 'icons/mob/human/species/ghost.dmi'
	icon_static = 'icons/mob/human/species/ghost.dmi'
	icon_state = "ghost_head"
	biological_state = BIO_FLESH
	bodytype = BODYTYPE_GHOST
	limb_id = SPECIES_GHOST
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

	head_flags = HEAD_HAIR | HEAD_FACIAL_HAIR | HEAD_DEBRAIN
	teeth_count = 0

/obj/item/bodypart/chest/ghost
	icon = 'icons/mob/human/species/ghost.dmi'
	icon_static = 'icons/mob/human/species/ghost.dmi'
	icon_state = "ghost_chest"
	biological_state = BIO_FLESH
	acceptable_bodyshape = BODYTYPE_GHOST
	bodytype = BODYTYPE_GHOST
	limb_id = SPECIES_GHOST
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	wing_types = null

//slightly different sprite meant to differentiate spirit from ghost.
/obj/item/bodypart/chest/ghost/spirit
	icon_state = "spirit_chest"
	limb_id = SPECIES_SPIRIT

/obj/item/bodypart/arm/left/ghost
	icon = 'icons/mob/human/species/ghost.dmi'
	icon_static = 'icons/mob/human/species/ghost.dmi'
	icon_state = "ghost_l_arm"
	biological_state = BIO_FLESH|BIO_JOINTED
	bodytype = BODYTYPE_GHOST
	limb_id = SPECIES_GHOST
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/arm/right/ghost
	icon = 'icons/mob/human/species/ghost.dmi'
	icon_static = 'icons/mob/human/species/ghost.dmi'
	icon_state = "ghost_r_arm"
	biological_state = BIO_FLESH|BIO_JOINTED
	bodytype = BODYTYPE_GHOST
	limb_id = SPECIES_GHOST
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
