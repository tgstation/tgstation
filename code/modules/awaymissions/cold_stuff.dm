/// stuff left over from the snowdin gateway that was too much of a pain to remove from the places where they are used.
/obj/structure/barricade/wooden/snowed
	name = "crude plank barricade"
	desc = "This space is blocked off by a wooden barricade. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade_snow"
	max_integrity = 125

/obj/item/clothing/under/syndicate/coldres
	name = "insulated tactical turtleneck"
	desc = "A nondescript and slightly suspicious-looking turtleneck with digital camouflage cargo pants. The interior has been padded with special insulation for both warmth and protection."
	armor_type = /datum/armor/clothing_under/syndicate/coldres
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/datum/armor/clothing_under/syndicate/coldres
	melee = 20
	bullet = 10
	energy = 5
	fire = 25
	acid = 25

/obj/item/clothing/shoes/combat/coldres
	name = "insulated combat boots"
	desc = "High speed, low drag combat boots, now with an added layer of insulation."
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/gun/magic/wand/fireball/inert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 4

/obj/item/gun/magic/wand/resurrection/inert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 5

/mob/living/basic/pet/penguin/emperor/snowdin
	minimum_survivable_temperature = ICEBOX_MIN_TEMPERATURE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/penguin/baby/permanent/snowdin
	minimum_survivable_temperature = ICEBOX_MIN_TEMPERATURE
	gold_core_spawnable = NO_SPAWN

/turf/open/floor/iron/dark/snowdin
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = TRUE
	temperature = ICEBOX_MIN_TEMPERATURE
