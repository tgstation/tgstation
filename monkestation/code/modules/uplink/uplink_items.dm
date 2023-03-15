/datum/uplink_item/role_restricted/boom_boots
	name = "Boom Boots"
	desc = "The pinnacle of clown footwear technology.  Fit for only the loudest and proudest! \
			Fully functional hydraulic clown shoes with anti-slip technology.  Anyone who tries \
			to remove these from your person will be in for an explosive surprise, to boot. "
	item = /obj/item/clothing/shoes/magboots/boomboots
	cost = 20
	restricted_roles = list("Clown")

/datum/uplink_item/role_restricted/psycho_scroll
	name = "The Rants of the Debtor"
	desc = "This roll of toilet paper has writings on it that will allow you to master the art of the Psychotic Brawl, but beware the cost to your own sanity."
	item = /obj/item/book/granter/martial/psychotic_brawl
	cost = 8
	restricted_roles = list("Debtor")
	surplus = 0

/datum/uplink_item/role_restricted/arcane_beacon
	name = "Beacon of Magical Items"
	desc = "This beacon allows you to choose a rare magitech item that will make your performance truly unforgettable."
	item = /obj/item/choice_beacon/magic
	cost = 5
	restricted_roles = list("Stage Magician")
	surplus = 0

/datum/uplink_item/implants/hardlight
	name = "Hardlight Spear Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will summon a spear \
			made out of hardlight that the user can use to wreak havoc."
	item = /obj/item/storage/box/syndie_kit/imp_hard_spear
	cost = 10

/datum/uplink_item/device_tools/bearserum
	name = "Werebear Serum"
	desc = "This serum made by BEAR Co (A group of very wealthy bears) will give other species the chance to be bear."
	item = /obj/item/bearserum
	cost = 12

//Species Specific Items

/datum/uplink_item/race_restricted/monkey_barrel
	name = "Angry Monkey Barrel"
	desc = "Expert Syndicate Scientists put pissed a couple monkeys off and put them in a barrel. It isn't that complicated, but it's very effective"
	cost = 7
	item = /obj/item/grenade/monkey_barrel
	restricted_species = list("simian")

/datum/uplink_item/race_restricted/monkey_ball
	name = "Monkey Ball"
	desc = "Stolen experimental MonkeTech designed to bring a monkey's speed to dangerous levels."
	cost = 12
	item = /obj/vehicle/ridden/monkey_ball
	restricted_species = list("simian")
