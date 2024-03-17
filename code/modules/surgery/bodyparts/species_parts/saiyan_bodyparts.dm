/obj/item/bodypart/head/saiyan
	unarmed_damage_low = 5
	unarmed_damage_high = 7
	unarmed_effectiveness = 15
	/// All TRUE saiyans have this colour hair
	var/saiyan_hair_colour = "#292929"

/obj/item/bodypart/head/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)

/obj/item/bodypart/head/saiyan/update_hair_and_lips(dropping_limb, is_creating)
	. = ..()
	if (HAS_TRAIT(owner, TRAIT_SUPER_SAIYAN))
		return
	// Sorry, you are not legendary enough to dye your hair
	var/mob/living/carbon/human/human_head_owner = owner
	human_head_owner?.hair_color = saiyan_hair_colour
	hair_color = saiyan_hair_colour

/obj/item/bodypart/chest/saiyan
	unarmed_damage_low = 5 // Good luck actually dealing damage with your chest
	unarmed_damage_high = 7
	unarmed_effectiveness = 15

/obj/item/bodypart/chest/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)

/obj/item/bodypart/arm/left/saiyan
	unarmed_damage_low = 8
	unarmed_damage_high = 12
	unarmed_effectiveness = 15

/obj/item/bodypart/arm/left/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)

/obj/item/bodypart/arm/right/saiyan
	unarmed_damage_low = 8
	unarmed_damage_high = 12
	unarmed_effectiveness = 15

/obj/item/bodypart/arm/right/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)

/obj/item/bodypart/leg/left/saiyan
	unarmed_damage_low = 12
	unarmed_damage_high = 18
	unarmed_effectiveness = 15

/obj/item/bodypart/leg/left/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)

/obj/item/bodypart/leg/right/saiyan
	unarmed_damage_low = 12
	unarmed_damage_high = 18
	unarmed_effectiveness = 15

/obj/item/bodypart/leg/right/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)
