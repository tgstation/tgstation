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
	surplus = 0

/datum/uplink_item/species_restricted/mothletgrenade
	name = "Mothlet Grenade"
	desc = "A experimental greande comprised of a C02 canister, and dozens of tiny moths (dubbed mothlets). They are very hungery \
			and are ready to eat just about any clothing the next person they meet is wearing. We are not responsible for any gear \
			you accidently loose to these hungry little guys."
	item = /obj/item/grenade/frag/mothlet
	cost = 4
	restricted_species = list(SPECIES_MOTH)
	surplus = 0
