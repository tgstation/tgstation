/datum/uplink_category/special
	name = "Special"
	weight = -3

/datum/uplink_item/special
	category = /datum/uplink_category/special
	cant_discount = TRUE
	surplus = 0
	purchasable_from = NONE


/datum/uplink_item/special/synditaser
	name = "Syndicate Taser Implant"
	desc = "An specialized syndicate arm-mounted taser, for quick subjugation of most personnel. Slowly recharges using bio-electricity."
	item = /obj/item/autosurgeon/syndicate/taser/hidden/single_use
	progression_minimum = 30 MINUTES
	cost = 15
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY)

/datum/uplink_item/special/synditaser/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		purchasable_from |= UPLINK_TRAITORS

