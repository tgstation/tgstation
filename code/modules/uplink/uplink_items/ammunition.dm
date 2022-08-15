// File ordered by progression

/datum/uplink_category/ammo
	name = "Ammunition"
	weight = 7

/datum/uplink_item/ammo
	category = /datum/uplink_category/ammo
	surplus = 40

// No progression cost

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft riot darts, for reloading any compatible foam dart magazine. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	surplus = 0
	illegal_tech = FALSE

// Low progression cost

/datum/uplink_item/ammo/pistol
	name = "9mm Handgun Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol."
	progression_minimum = 10 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

// Medium progression cost

/datum/uplink_item/ammo/pistolap
	name = "9mm Armour Piercing Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/ap
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistolhp
	name = "9mm Hollow Point Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are more damaging but ineffective against armour."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/hp
	cost = 3
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistolfire
	name = "9mm Incendiary Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/fire
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the Syndicate revolver. \
			For when you really need a lot of things dead."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/a357
	cost = 4
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
