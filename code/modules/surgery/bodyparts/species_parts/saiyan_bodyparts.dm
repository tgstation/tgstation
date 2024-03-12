/obj/item/bodypart/head/saiyan
	unarmed_damage_low = 5
	unarmed_damage_high = 7
	unarmed_effectiveness = 15

/obj/item/bodypart/head/saiyan/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SAIYAN_STRENGTH, INNATE_TRAIT)

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
