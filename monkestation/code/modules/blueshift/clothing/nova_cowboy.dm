
/obj/item/clothing/head/cowboy/nova
	name = "SR COWBOY HAT DEBUG"
	desc = "REPORT THIS IF FOUND"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/cowboy.dmi'
	icon_state = null //Keeps this from showing up under the chameleon hat
	worn_icon_state = null //TG defaults this to "hunter" and breaks our items
	armor_type = /datum/armor/none
	resistance_flags = NONE //TG defaults cowboy hats to fireproof/acidproof

/obj/item/clothing/head/cowboy/nova/wide
	name = "wide brimmed hat"
	desc = "A wide-brimmed hat, to keep the sun out of your eyes in style."
	icon_state = "widebrim"
	greyscale_colors = "#4D4D4D#DE9754"
	greyscale_config = /datum/greyscale_config/cowboy_wide
	greyscale_config_worn = /datum/greyscale_config/cowboy_wide/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/cowboy/nova/wide/feathered
	name = "wide brimmed feathered hat"
	desc = "A wide-brimmed hat adorned with a feather, the perfect flourish to a rugged outfit."
	icon_state = "widebrim_feathered"
	greyscale_colors = "#4D4D4D#DE9754#D5D5B9"
	greyscale_config = /datum/greyscale_config/cowboy_wide_feathered
	greyscale_config_worn = /datum/greyscale_config/cowboy_wide_feathered/worn

/obj/item/clothing/head/cowboy/nova/flat
	name = "flat brimmed hat"
	desc = "A finely made hat with a short flat brim, perfect for an old fashioned shootout."
	icon_state = "flatbrim"
	greyscale_colors = "#BE925B#914C2F"
	greyscale_config = /datum/greyscale_config/cowboy_flat
	greyscale_config_worn = /datum/greyscale_config/cowboy_flat/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/cowboy/nova/flat/cowl
	name = "flat brimmed hat with cowl"
	desc = "A finely made hat with a short flat brim, paired with a snug and warm cowl. Today's a cold day to die..."
	icon_state = "flatbrim_cowl"
	greyscale_colors = "#c26934#8f89ae#774B2D"
	greyscale_config = /datum/greyscale_config/cowboy_flat_cowl
	greyscale_config_worn = /datum/greyscale_config/cowboy_flat_cowl/worn
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR

/obj/item/clothing/head/cowboy/nova/cattleman
	name = "cattleman hat"
	desc = "A hat with a creased brim and a tall crown, intended to be pushed down further on the head to stay on in harsh weather. Not as relevant in space but still comes in handy."
	icon_state = "cattleman"
	greyscale_colors = "#725443#B2977C"
	greyscale_config = /datum/greyscale_config/cowboy_cattleman
	greyscale_config_worn = /datum/greyscale_config/cowboy_cattleman/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/cowboy/nova/cattleman/wide
	name = "wide brimmed cattleman hat"
	desc = "A hat with a wide, slightly creased brim. Good for working in the sun, not so much for fitting through tight gaps."
	icon_state = "cattleman_wide"
	greyscale_colors = "#4D4D4D#5F666E"
	greyscale_config = /datum/greyscale_config/cowboy_cattleman_wide
	greyscale_config_worn = /datum/greyscale_config/cowboy_cattleman_wide/worn
	flags_1 = IS_PLAYER_COLORABLE_1

//Presets
/obj/item/clothing/head/cowboy/nova/flat/sheriff
	name = "sheriff hat"
	desc = "A dark brown hat with a smell of whiskey. There's a small set of antlers embroidered on the inside."
	greyscale_colors = "#704640#8f89ae"
	flags_1 = NONE //No recoloring presets

/obj/item/clothing/head/cowboy/nova/flat/deputy
	name = "deputy hat"
	desc = "A light brown hat with a smell of iron. There's a small set of antlers embroidered on the inside."
	greyscale_colors = "#c26934#8f89ae"
	flags_1 = NONE //No recoloring presets

/obj/item/clothing/head/cowboy/nova/flat/cowl/sheriff
	name = "winter sheriff hat"
	desc = "A dark hat with a matching dark cowl, warm yet breathable. There's a small set of antlers embroidered on the inside."
	greyscale_colors = "#3F3F3F#716349#3F3F3F"
	flags_1 = NONE //No recoloring presets

/obj/item/clothing/head/cowboy/nova/cattleman/sec
	name = "security cattleman hat"
	desc = "A security cattleman hat, perfect for any true lawman."
	greyscale_colors = "#39393F#3F6E9E"
	armor_type = /datum/armor/head_helmet
	flags_1 = NONE //No recoloring presets

/obj/item/clothing/head/cowboy/nova/cattleman/wide/sec
	name = "wide brimmed security cattleman hat"
	desc = "A bandit turned sheriff, his enforcement is brutal but effective - whether out of fear or respect is unclear, though not many bodies hang high. A peaceful land, a quiet people."
	greyscale_colors = "#39393F#3F6E9E"
	armor_type = /datum/armor/head_helmet
	flags_1 = NONE //No recoloring presets
