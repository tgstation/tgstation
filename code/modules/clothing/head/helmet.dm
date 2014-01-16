/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/HoS
	name = "head of security hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flags_inv = 0
	flags_inv = HIDEEARS

/obj/item/clothing/head/helmet/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	item_state = "dermal"

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force. Protects the head from impacts."
	icon_state = "policehelm"
	flags_inv = 0

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES