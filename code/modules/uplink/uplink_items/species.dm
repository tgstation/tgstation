/datum/uplink_category/species
	name = "Species Restricted"
	weight = 1

/datum/uplink_item/species_restricted
	category = /datum/uplink_category/species
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/species_restricted/moth_lantern
	name = "Extra-Bright Lantern"
	desc = "We heard that moths such as yourself really like lamps, so we decided to grant you early access to a prototype \
	Syndicate brand \"Extra-Bright Lantern™\". Enjoy."
	cost = 2
	item = /obj/item/flashlight/lantern/syndicate
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/race_restricted/tribal_claw
	name = "Old Tribal Scroll"
	desc = "We found this scroll in a abandoned lizard settlement of the Knoises clan. \
			It teaches you how to use your claws and tail to gain an advantage in combat, \
			don't buy this unless you are a lizard or plan to give it to one as only they can understand the ancient draconic words."
	item = /obj/item/book/granter/martial/tribal_claw
	cost = 13
	surplus = 0
	restricted_species = list(SPECIES_LIZARD)
