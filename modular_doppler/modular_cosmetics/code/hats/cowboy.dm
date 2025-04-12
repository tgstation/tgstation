/obj/item/clothing/head/cowboy/doppler
	name = "COWBOY HAT DEBUG"
	desc = "REPORT THIS IF FOUND"
	icon = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/cowboy.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/GAGS/icons/mob/cowboy.dmi'
	icon_state = null //Keeps this from showing up under the chameleon hat
	worn_icon_state = null //TG defaults this to "hunter" and breaks our items
	armor_type = /datum/armor/cosmetic_sec //slighlty weaker than a helmet because it inherits the ability to be shot off in place of your head
	//there used to be a change to resistance flags here, it's gone now

/obj/item/clothing/head/cowboy/doppler/wide
	name = "wide brimmed hat"
	desc = "A wide-brimmed hat, to keep the sun out of your eyes in style."
	icon_state = "widebrim"
	greyscale_colors = "#4D4D4D#DE9754"
	greyscale_config = /datum/greyscale_config/cowboy_wide
	greyscale_config_worn = /datum/greyscale_config/cowboy_wide/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/cowboy/doppler/wide/feathered
	name = "wide brimmed feathered hat"
	desc = "A wide-brimmed hat adorned with a feather, the perfect flourish to a rugged outfit."
	icon_state = "widebrim_feathered"
	greyscale_colors = "#4D4D4D#DE9754#D5D5B9"
	greyscale_config = /datum/greyscale_config/cowboy_wide_feathered
	greyscale_config_worn = /datum/greyscale_config/cowboy_wide_feathered/worn

/obj/item/clothing/head/cowboy/doppler/flat
	name = "flat brimmed hat"
	desc = "A finely made hat with a short flat brim, perfect for an old fashioned shootout."
	icon_state = "flatbrim"
	greyscale_colors = "#BE925B#914C2F"
	greyscale_config = /datum/greyscale_config/cowboy_flat
	greyscale_config_worn = /datum/greyscale_config/cowboy_flat/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/cowboy/doppler/flat/cowl
	name = "flat brimmed hat with cowl"
	desc = "A finely made hat with a short flat brim, paired with a snug and warm cowl. Today's a cold day to die..."
	icon_state = "flatbrim_cowl"
	greyscale_colors = "#c26934#8f89ae#774B2D"
	greyscale_config = /datum/greyscale_config/cowboy_flat_cowl
	greyscale_config_worn = /datum/greyscale_config/cowboy_flat_cowl/worn
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR

/obj/item/clothing/head/cowboy/doppler/cattleman
	name = "cattleman hat"
	desc = "A hat with a creased brim and a tall crown, intended to be pushed down further on the head to stay on in harsh weather. Not as relevant in space but still comes in handy."
	icon_state = "cattleman"
	greyscale_colors = "#725443#B2977C"
	greyscale_config = /datum/greyscale_config/cowboy_cattleman
	greyscale_config_worn = /datum/greyscale_config/cowboy_cattleman/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/cowboy/doppler/cattleman/wide
	name = "wide brimmed cattleman hat"
	desc = "A hat with a wide, slightly creased brim. Good for working in the sun, not so much for fitting through tight gaps."
	icon_state = "cattleman_wide"
	greyscale_colors = "#4D4D4D#5F666E"
	greyscale_config = /datum/greyscale_config/cowboy_cattleman_wide
	greyscale_config_worn = /datum/greyscale_config/cowboy_cattleman_wide/worn
	flags_1 = IS_PLAYER_COLORABLE_1


