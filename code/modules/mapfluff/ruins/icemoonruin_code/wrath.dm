/obj/item/clothing/gloves/butchering
	name = "butchering gloves"
	desc = "These gloves were modified with some ill-fashioned yet sharp bone blades on their fingers, \
		allowing the user to rip apart bodies with precision and ease."
	icon_state = "butchering"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/butchering/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering/wearable, \
	speed = 0.5 SECONDS, \
	effectiveness = 125, \
	bonus_modifier = 0, \
	butcher_sound = null, \
	disabled = TRUE, \
	can_be_blunt = TRUE, \
	)
