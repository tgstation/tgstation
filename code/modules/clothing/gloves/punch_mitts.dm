/obj/item/clothing/gloves/fingerless/punch_mitts
	name = "punching mitts"
	desc = "Fingerless gloves with nasty spikes attached. Allows the wearer to utilize the ill-reputed fighting technique known as Hunter Boxing. The style \
		allows the user to rapidly punch wildlife and rock into smithereens. Great workout. Extremely ill-advised for ensuring your own personal survival."
	icon_state = "punch_mitts"
	body_parts_covered = HANDS|ARMS
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	armor_type = /datum/armor/gloves_mitts

/obj/item/clothing/gloves/fingerless/punch_mitts/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -6)
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/boxing/hunter)

/datum/armor/gloves_mitts
	melee = 25
	bullet = 5
	laser = 5
	energy = 5
	bomb = 100
	fire = 100
	acid = 30
