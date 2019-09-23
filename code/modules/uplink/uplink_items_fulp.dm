/datum/uplink_item/role_restricted/bag_of_encounters
	name = "Bag of Encounters"
	desc = "An inconspicious bag of dice, recovered from a Space Wizard's dungeon. Each dice within will summon a challenge for the crew: 1d4 Bears, 1d6 Space Carp or 1d20 angry Bees!\
			Be sure to give the bag a shake before use, otherwise the beasts may not recognise you as Dungeon Master, especially if thrown."
	item = /obj/item/storage/pill_bottle/encounter_dice
	cost = 8
	restricted_roles = list("Curator")
	limited_stock = 1 //for testing at least


/datum/uplink_item/badass/balloon
	name = "Syndicate Balloon"
	desc = "For showing that you and two other Syndies are true genuine 100% BAD ASS SYNDIES."
	item = /obj/item/storage/box/syndieballoons
	cost = 60
	cant_discount = TRUE
	illegal_tech = FALSE
