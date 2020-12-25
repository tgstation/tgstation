/obj/item/clothing/gloves/baby
	name = "baby gloves"
	desc = "Dawww, aren't these the cutest? Intended for ages 0-4, prevents accidental self-harm to the user."
	icon_state = "babygloves"
	inhand_icon_state = "babygloves"
	transfer_prints = FALSE
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	custom_price = PAYCHECK_ASSISTANT * 0.5
	undyeable = TRUE
	species_exception = list(/datum/species/golem) // now you too can be a golem baby
