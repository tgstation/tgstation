/obj/item/clothing/shoes/cult
	name = "\improper Nar'Sian boots"
	desc = "A pair of boots worn by the followers of Nar'Sie."
	icon_state = "cult"
	inhand_icon_state = null
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	lace_time = 10 SECONDS

/obj/item/clothing/shoes/cult/alt
	name = "\improper Nar'Sian invoker boots"
	icon_state = "cultalt"

/obj/item/clothing/shoes/cult/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/shoes/cult/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)
