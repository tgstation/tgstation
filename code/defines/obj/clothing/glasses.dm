// GLASSES

/obj/item/clothing/glasses
	name = "glasses"
	icon = 'glasses.dmi'
	w_class = 2.0
	flags = GLASSESCOVERSEYES

/obj/item/clothing/glasses/blindfold
	name = "blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"

/obj/item/clothing/glasses/meson
	name = "Optical Meson Scanner"
	icon_state = "meson"
	item_state = "glasses"
	origin_tech = "magnets=2"

/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "magnets=2"

/obj/item/clothing/glasses/material
	name = "Optical Material Scanner"
	icon_state = "blindfold"
	item_state = "blindfold"
	origin_tech = "magnets=2"

/obj/item/clothing/glasses/regular
	name = "Prescription Glasses"
	icon_state = "glasses"
	item_state = "glasses"

/obj/item/clothing/glasses/gglasses
	name = "Green Glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "Sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	protective_temperature = 1300
	var/already_worn = 0

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	icon_state = "thermal"
	item_state = "glasses"
	origin_tech = "magnets=3"

/obj/item/clothing/glasses/thermal/monocle
	name = "Thermoncle"
	icon_state = "thermoncle"