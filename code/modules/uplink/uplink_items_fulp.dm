/datum/uplink_item/role_restricted/bag_of_encounters
	name = "Bag of Encounters"
	desc = "An inconspicious bag of dice, recovered from a Space Wizard's dungeon. Each dice within will summon a challenge for the crew: 1d4 Bears, 1d6 Space Carp or 1d20 angry Bees!\
			Be sure to give the bag a shake before use, so that the creatures will recognise you as their true dungeon master, no matter who rolls the dice."
	item = /obj/item/storage/pill_bottle/encounter_dice
	cost = 8
	restricted_roles = list("Curator")
	limited_stock = 1 //for testing at least


/datum/uplink_item/badass/balloongold
	name = "Golden Syndicate Balloons"
	desc = "For showing that you and two other Syndies are true genuine 100% BAD ASS SYNDIES."
	item = /obj/item/storage/box/syndieballoons
	cost = 60
	cant_discount = TRUE
	illegal_tech = FALSE

/datum/uplink_item/role_restricted/susp_bowler
	name = "Suspicious Bowler"
	desc = "A strange, deep black bowler with an extremely sharp, weighted brim. The material used to make the brim of the bowler allows for it to pierce armor, often embeding within the designated target."
	item = /obj/item/clothing/head/susp_bowler
	cost = 5
	cant_discount = FALSE
	illegal_tech = TRUE
	restricted_roles = list("Bartender")
