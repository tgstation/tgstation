/datum/uplink_category/species
	name = "Species Restricted"
	weight = 2

/datum/uplink_item/species_restricted
	category = /datum/uplink_category/species
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY)

/datum/uplink_item/species_restricted/moth_lantern
	name = "Extra-Bright Lantern"
	desc = "We heard that moths such as yourself really like lamps, so we decided to grant you early access to a prototype \
	Syndicate brand \"Extra-Bright Lantern™\". Enjoy."
	cost = 2
	item = /obj/item/flashlight/lantern/syndicate
	restricted_species = list(SPECIES_MOTH)
	surplus = 0

/datum/uplink_item/species_restricted/superhuman
	name = "Super-Human Mutator"
	desc = "This DNA mutator contains a highly experimental mutation that significantly boosts a human's physical and mental attributes to it's peak potential. \
			Superhuman's slowly regenerate health, have greater stamina, have greater maximum health, slightly resist damage, are immune to stuns, have near-immunity to slips, easily ignore pain, and cannot be dismembered. \
			Mutadone CANNOT cure this mutation, but this mutation causes great genetic instability. Proceed with extreme caution. Incompatible with hulk mutations."
	cost = 20
	surplus = 0
	item = /obj/item/dnainjector/superhuman
	restricted_species = list(SPECIES_HUMAN)
