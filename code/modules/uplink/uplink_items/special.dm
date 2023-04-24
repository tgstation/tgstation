/datum/uplink_category/special
	name = "Special"
	weight = -3

/datum/uplink_item/special
	category = /datum/uplink_category/special
	cant_discount = TRUE
	surplus = 0
	purchasable_from = NONE

/datum/uplink_item/special/autosurgeon
	name = "Syndicate Autosurgeon"
	desc = "A multi-use autosurgeon for implanting whatever you want into yourself. Rip that station apart and make it part of you."
	item = /obj/item/autosurgeon/syndicate
	cost = 5

/datum/uplink_item/special/autosurgeon/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		purchasable_from |= UPLINK_TRAITORS
