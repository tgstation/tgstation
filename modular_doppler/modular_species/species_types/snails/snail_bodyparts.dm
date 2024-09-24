// MODULAR SNAIL OVERRIDES

/obj/item/bodypart/head/snail
	icon_greyscale = BODYPART_ICON_SNAIL
	bodyshape = BODYSHAPE_HUMANOID
	head_flags = HEAD_HAIR|HEAD_FACIAL_HAIR|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_DEBRAIN
	eyes_icon = 'modular_doppler/modular_species/species_types/snails/icons/organs/snail_eyes.dmi'

/obj/item/bodypart/chest/snail
	icon_greyscale = BODYPART_ICON_SNAIL
	bodyshape = BODYSHAPE_HUMANOID

/obj/item/bodypart/arm/left/snail
	icon_greyscale = BODYPART_ICON_SNAIL
	bodyshape = BODYSHAPE_HUMANOID
	unarmed_damage_low = 1 // Roundstart Snails - Lowest possible punch damage. if this is set to 0, punches will always miss.
	unarmed_damage_high = 5 // Roundstart Snails - A Bit More damage.

/obj/item/bodypart/arm/right/snail
	icon_greyscale = BODYPART_ICON_SNAIL
	bodyshape = BODYSHAPE_HUMANOID
	unarmed_damage_low = 1
	unarmed_damage_high = 5

/obj/item/bodypart/leg/left/snail
	icon_greyscale = BODYPART_ICON_SNAIL
	bodyshape = BODYSHAPE_HUMANOID
	unarmed_damage_low = 1
	unarmed_damage_high = 5

/obj/item/bodypart/leg/right/snail
	icon_greyscale = BODYPART_ICON_SNAIL
	bodyshape = BODYSHAPE_HUMANOID
	unarmed_damage_low = 1
	unarmed_damage_high = 5
