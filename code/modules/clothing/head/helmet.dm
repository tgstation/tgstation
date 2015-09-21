/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = FPRINT
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	body_parts_covered = HEAD | EYES | EARS
	flags_inv = HIDEEARS | HIDEEYES | HIDEHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7

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
	flags = FPRINT
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS | HIDEHEADHAIR
	siemens_coefficient = 0.7
	eyeprot = 1

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = FPRINT
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES|HIDEHEADHAIR
	cold_protection = HEAD
	species_fit = list("Vox")
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	eyeprot = 1

/obj/item/clothing/head/helmet/swat/dredd
	name = "Judge Helmet"
	desc = "Judge, Jury, and Executioner."
	icon_state = "dredd-helmet"
	item_state = "dredd-helmet"
	species_fit = list()

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = FPRINT
	flags_inv = HIDEEARS | HIDEHEADHAIR
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = FPRINT
	body_parts_covered = FULL_HEAD
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	armor = list(melee = 20, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/hopcap
	name = "Head of Personnel's Cap"
	desc = "Papers, Please"
	armor = list(melee = 25, bullet = 0, laser = 15, energy = 10, bomb = 5, bio = 0, rad = 0)
	item_state = "hopcap"
	icon_state = "hopcap"
	flags_inv = 0

/obj/item/clothing/head/helmet/aviatorhelmet
	name = "Aviator Helmet"
	desc = "Help the Bombardier!"
	armor = list(melee = 25, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	item_state = "aviator_helmet"
	icon_state = "aviator_helmet"
	flags_inv = HIDEEARS|HIDEHAIR
	species_restricted = list("exclude","Vox")

/obj/item/clothing/head/helmet/piratelord
	name = "pirate lord's helmet"
	desc = "The headwear of an all powerful and bloodthirsty pirate lord. Simply looking at it sends chills down your spine."
	armor = list(melee = 75, bullet = 75, laser = 75,energy = 75, bomb = 75, bio = 100, rad = 90)
	icon_state = "piratelord"

/obj/item/clothing/head/helmet/biker
	name = "Biker's Helmet"
	desc = "This helmet should protect you from russians and masked vigilantes."
	armor = list(melee = 25, bullet = 15, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "biker_helmet"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	body_parts_covered = FULL_HEAD

/obj/item/clothing/head/helmet/richard
	name = "Richard"
	desc = "Do you like hurting people?"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	icon_state = "richard"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	body_parts_covered = FULL_HEAD

/obj/item/clothing/head/helmet/megahelmet
	name = "DRN-001 Helmet"
	desc = "The helmet of the DRN-001 model. A simple, sturdy blue helmet."
	icon_state = "megahelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "megahelmet"
	flags_inv = HIDEEARS|HIDEHAIR
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/protohelmet
	name = "Prototype Helmet"
	desc = "Shiny red helmet with white accents and a built in shaded visor that does absolutely nothing, nothing but look rad as hell."
	icon_state = "protohelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EYES|EARS
	item_state = "protohelmet"
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/breakhelmet
	name = "Broken Helmet"
	desc = "The product of twelve years of work by an eccentric and brilliant loner. A helmet belonging to the perfect man; an unbeatable machine."
	icon_state = "breakhelmet"
	flags = FPRINT
	body_parts_covered = FULL_HEAD
	item_state = "breakhelmet"
	flags_inv = HIDEMASK|HIDEEARS|HIDEHAIR|HIDEEYES
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/megaxhelmet
	name = "Maverick Hunter Helmet"
	desc = "Heavily armored upgrade to the DRN-001 model's helmet, now comes with a pointless red crystal thing!"
	icon_state = "megaxhelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "megaxhelmet"
	flags_inv = HIDEEARS|HIDEHAIR
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/volnutthelmet
	name = "Digouter Helmet"
	desc = "A sturdy helmet, fortified to protect from falling rocks or buster shots"
	icon_state = "volnutthelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "volnutthelmet"
	armor = list(melee = 50, bullet = 40, laser = 40,energy = 40, bomb = 5, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEHAIR
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/joehelmet
	name = "Sniper Helmet"
	desc = "Helmet belonging to one of the many mass produced 'Joe' type robots."
	icon_state = "joehelmet"
	flags = FPRINT
	body_parts_covered = FULL_HEAD
	item_state = "joehelmet"
	flags_inv = HIDEMASK|HIDEEARS|HIDEHAIR|HIDEEYES
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/doomguy
	name = "Doomguy's helmet"
	desc = ""
	icon_state = "doom"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "doom"
	armor = list(melee = 50, bullet = 40, laser = 40,energy = 40, bomb = 5, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEHAIR
	siemens_coefficient = 1
