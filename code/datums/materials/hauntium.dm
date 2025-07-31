/datum/material/hauntium
	name = "hauntium"
	desc = "very scary!"
	color = list(460/255, 464/255, 460/255, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_color = "#FFFFFF"
	alpha = 100
	starlight_color = COLOR_ALMOST_BLACK
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/hauntium
	value_per_unit = 0.05
	beauty_modifier = 0.25
	//pretty good but only the undead can actually make use of these modifiers
	strength_modifier = 1.2
	armor_modifiers = list(MELEE = 1.1, BULLET = 1.1, LASER = 1.15, ENERGY = 1.15, BOMB = 1, BIO = 1, FIRE = 1, ACID = 0.7)
	fish_weight_modifier = 1.4
	fishing_difficulty_modifier = -25 //Only the undead and the coroner can game this.
	fishing_cast_range = 2
	fishing_experience_multiplier = 1.5
	fishing_completion_speed = 1.1
	fishing_bait_speed_mult = 0.85
	fishing_gravity_mult = 0.8

/datum/material/hauntium/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isobj(source))
		return
	var/obj/obj = source
	obj.make_haunted(INNATE_TRAIT, "#f8f8ff")
	if(isbodypart(source))
		var/obj/item/bodypart/bodypart = source
		if(!(bodypart::bodytype & BODYTYPE_GHOST))
			bodypart.bodytype |= BODYTYPE_GHOST
	if(isorgan(source))
		var/obj/item/organ/organ = source
		if(!(organ::organ_flags & ORGAN_GHOST))
			organ.organ_flags |= ORGAN_GHOST

/datum/material/hauntium/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isobj(source))
		return
	var/obj/obj = source
	obj.remove_haunted(INNATE_TRAIT)
	if(isbodypart(source))
		var/obj/item/bodypart/bodypart = source
		if(!(bodypart::bodytype & BODYTYPE_GHOST))
			bodypart.bodytype &= ~BODYTYPE_GHOST
	if(isorgan(source))
		var/obj/item/organ/organ = source
		if(!(organ::organ_flags & ORGAN_GHOST))
			organ.organ_flags &= ~ORGAN_GHOST
