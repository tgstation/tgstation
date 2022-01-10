// File ordered by progression

/datum/uplink_category/suits
	name = "Space Suits"
	weight = 3

/datum/uplink_item/suits
	category = /datum/uplink_category/suits
	surplus = 40

/datum/uplink_item/suits/infiltrator_bundle
	name = "Infiltrator Case"
	desc = "Developed by Roseus Galactic in conjunction with the Gorlex Marauders to produce a functional suit for urban operations, \
			this suit proves to be cheaper than your standard issue hardsuit, with none of the movement restrictions of the outdated spacesuits employed by the company. \
			Comes with an armor vest, helmet, sneaksuit, sneakboots, specialized combat gloves and a high-tech balaclava. The case is also rather useful as a storage container."
	item = /obj/item/storage/toolbox/infiltrator
	cost = 6
	limited_stock = 1 //you only get one so you don't end up with too many gun cases
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "This red and black Syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Nanotrasen crew members are trained to report red space suit \
			sightings, however."
	item = /obj/item/storage/box/syndie_kit/space
	cost = 4

// Low progression cost

/datum/uplink_item/suits/modsuit
	name = "Syndicate MODsuit"
	desc = "The feared MODsuit of a Syndicate agent. Features armoring and a set of inbuilt modules."
	item = /obj/item/mod/control/pre_equipped/traitor
	cost = 8
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS) //you can't buy it in nuke, because the elite modsuit costs the same while being better
	progression_minimum = 20 MINUTES

/datum/uplink_item/suits/thermal
	name = "MODsuit Thermal Visor Module"
	desc = "A visor for a MODsuit. Lets you see living beings through walls."
	item = /obj/item/mod/module/visor/thermal
	progression_minimum = 20 MINUTES
	cost = 4

/datum/uplink_item/suits/night
	name = "MODsuit Night Visor Module"
	desc = "A visor for a MODsuit. Lets you see clearer in the dark."
	item = /obj/item/mod/module/visor/night
	progression_minimum = 20 MINUTES
	cost = 2
