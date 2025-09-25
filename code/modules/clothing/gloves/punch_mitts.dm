/obj/item/clothing/gloves/gauntlets/punch_mitts
	name = "punching mitts"
	desc = "Fingerless gloves with nasty spikes attached. Allows the wearer to utilize the ill-reputed fighting technique known as Hunter Boxing. The style \
		allows the user to rapidly punch wildlife and rock into smithereens. Great workout. Extremely ill-advised for ensuring your own personal survival."
	icon_state = "punch_mitts"
	toolspeed = 1
	siemens_coefficient = 1
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)
	armor_type = /datum/armor/gloves_mitts

/obj/item/clothing/gloves/gauntlets/punch_mitts/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -6)

/datum/armor/gloves_mitts
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 100
	fire = 100
	acid = 30
