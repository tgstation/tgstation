/obj/item/clothing/head/costume/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = null
	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/costume/pirate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -5)

/obj/item/clothing/head/costume/pirate/equipped(mob/user, slot)
	. = ..()
	if(!(slot_flags & slot) || isdrone(user))
		return
	user.grant_language(/datum/language/piratespeak, source = LANGUAGE_HAT)
	to_chat(user, span_boldnotice("You suddenly know how to speak like a pirate!"))

/obj/item/clothing/head/costume/pirate/dropped(mob/user)
	. = ..()
	if(QDELETED(src)) //This can be called as a part of destroy
		return
	user.remove_language(/datum/language/piratespeak, source = LANGUAGE_HAT)
	to_chat(user, span_boldnotice("You can no longer speak like a pirate."))

/obj/item/clothing/head/costume/pirate/armored
	armor_type = /datum/armor/pirate_armored
	strip_delay = 4 SECONDS
	equip_delay_other = 2 SECONDS

/datum/armor/pirate_armored
	melee = 30
	bullet = 50
	laser = 30
	energy = 40
	bomb = 30
	bio = 30
	fire = 60
	acid = 75

/obj/item/clothing/head/costume/pirate/captain
	name = "pirate captain hat"
	icon_state = "hgpiratecap"
	inhand_icon_state = null

/obj/item/clothing/head/costume/pirate/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	inhand_icon_state = null

/obj/item/clothing/head/costume/pirate/bandana/armored
	armor_type = /datum/armor/bandana_armored
	strip_delay = 4 SECONDS
	equip_delay_other = 2 SECONDS

/datum/armor/bandana_armored
	melee = 30
	bullet = 50
	laser = 30
	energy = 40
	bomb = 30
	bio = 30
	fire = 60
	acid = 75
