/obj/item/clothing/gloves/color/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	greyscale_colors = "#2f2e31"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/fingerless

/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	greyscale_colors = "#2f2e31"
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = PAYCHECK_CREW * 1.5
	undyeable = TRUE
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	greyscale_colors = "#ff9300"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	greyscale_colors = "#da0000"


/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves provide protection against electric shock."
	siemens_coefficient = 0
	armor_type = /datum/armor/red_insulated
	resistance_flags = NONE

/datum/armor/red_insulated
	bio = 50

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	inhand_icon_state = "rainbow_gloves"
	greyscale_colors = null

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	greyscale_colors = "#00b7ef"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	greyscale_colors = "#cc33ff"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	greyscale_colors = "#a8e61d"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	greyscale_colors = "#999999"

// Grey gloves intended to be paired with winter coats (specifically EVA winter coats)
/obj/item/clothing/gloves/color/grey/protects_cold
	name = "\proper Endotherm gloves"
	desc = "A pair of thick grey gloves, lined to protect the wearer from freezing cold."
	w_class = WEIGHT_CLASS_NORMAL
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	resistance_flags = NONE
	clothing_flags = THICKMATERIAL

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	greyscale_colors = "#c09f72"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	greyscale_colors = "#83613d"

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	greyscale_colors = "#ffffff"
	custom_price = PAYCHECK_CREW
