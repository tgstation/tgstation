/datum/antag_faction/uzka
	name = "Uz'ka"
	description = "The term 'no honor among thieves' holds very little water with the ruthless Uz'ka, an organized crime outfit based out of a farflung ice-world in the reaches of 4CA space. Their operatives are every bit as implacable and grounded as the frigid realm that spawned their cultural practices, and they are widely known to expect the same dedication from independent contractors that they occasionally hire to pursue their interests elsewhere in the sector."
	antagonist_types = list(/datum/antagonist/traitor, /datum/antagonist/spy)
	faction_category = /datum/uplink_category/faction_special/uzka
	entry_line = span_boldnotice("The Uz'ka watch. Do not shame us. Achieve your goals and honor your word, or do not return. We gift you a choice of honored armaments: seek your uplink for more details.")

/datum/uplink_category/faction_special/uzka
	name = "Honorable Armaments"
	weight = 100

/datum/antag_faction_item/uzka
	faction = /datum/antag_faction/uzka

// items

/datum/antag_faction_item/uzka/saber
	name = "Saber"
	description = "Forged by the artisan clans of the Uz'ka, it's a medium-sized, one-handed weapon that can cut through lightly armored or unarmored foes with utter ease. A staple for every member when going through their rites."
	item = /obj/item/claymore/cutlass
	cost = 4

/datum/antag_faction_item/uzka/club
	name = "Ablative Club"
	description = "Specially forged by the highest ranking artisan clans, this bat was given to some of the Zar'Khet to act as vanguards. Used to dispel laser fire more commonly used in hostile lands it gave a sense of courage and pride to those in the ranks. "
	item = /obj/item/melee/baseball_bat/ablative
	cost = 6
