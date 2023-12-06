//Shielded Armour

/obj/item/clothing/suit/space/hardsuit/shielded/wizard
	name = "battlemage armour"
	desc = "Not all wizards are afraid of getting up close and personal."
	icon_state = "battlemage"
	inhand_icon_state = "battlemage"
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	armor_type = /datum/armor/hardsuit
	slowdown = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/shielded/wizard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded, max_charges = 15, recharge_start_delay = 0 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-red")

/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	name = "battlemage helmet"
	desc = "A suitably impressive helmet."
	icon_state = "battlemage"
	inhand_icon_state = "battlemage"
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hardsuit
	actions_types = null //No inbuilt light
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/hardsuit
	melee = 30
	bullet = 20
	laser = 20
	energy = 30
	bomb = 20
	bio = 20
	fire = 100
	acid = 100

/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard/attack_self(mob/user)
	return
