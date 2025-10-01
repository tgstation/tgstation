/datum/uplink_category/ammo
	name = "Ammunition"
	weight = 7

/datum/uplink_item/ammo
	category = /datum/uplink_category/ammo
	surplus = 40

/datum/uplink_item/ammo/toydarts
	name = "Donksoft Riot Pistol Ammunition Case"
	desc = "A case containing three spare magazines for the Donksoft riot pistol, along with a box of loose riot darts."
	item = /obj/item/storage/toolbox/guncase/traitor/ammunition/donksoft
	cost = 2
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND
	purchasable_from = ~UPLINK_SERIOUS_OPS

/datum/uplink_item/ammo/pistol
	name = "9mm Magazine Case"
	desc = "A case containing three additional 8-round 9mm magazines, compatible with the Makarov pistol, as well as \
		a box of loose 9mm ammunition."
	item = /obj/item/storage/toolbox/guncase/traitor/ammunition
	cost = 2
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/ammo/pistolap
	name = "9mm Armour Piercing Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m9mm/ap
	cost = 2
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/ammo/pistolhp
	name = "9mm Hollow Point Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m9mm/hp
	cost = 3
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/ammo/pistolfire
	name = "9mm Incendiary Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m9mm/fire
	cost = 2
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the Syndicate revolver. \
			For when you really need a lot of things dead."
	item = /obj/item/ammo_box/speedloader/c357
	cost = 4
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY) //nukies get their own version
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND
