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

/datum/uplink_item/species_restricted/mothletgrenade //Monkestation addition
	name = "Mothlet Grenade"
	desc = "A experimental greande comprised of a Co2 canister, and dozens of tiny brainwashed moths (dubbed mothlets) \
			these little guys have been brainwashed and taught how to undo virtually all kinds of clothing and equipment \
			along with how to disarm people. We sadly couldn't figure out how to teach them friend from foe so just be careful \
			handling them, as they wont hesitate to pants you and the captain at the same time."
	item = /obj/item/grenade/frag/mothlet
	cost = 4
	restricted_species = list(SPECIES_MOTH)
	surplus = 0
