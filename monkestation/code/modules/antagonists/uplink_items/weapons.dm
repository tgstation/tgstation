/datum/uplink_item/implants/hardlight
	name = "Hardlight Spear Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will summon a spear \
			made out of hardlight that the user can use to wreak havoc."
	item = /obj/item/storage/box/syndie_kit/imp_hard_spear
	cost = 10

/datum/uplink_item/dangerous/laser_musket
	name = "Syndicate Laser Musket"
	desc = "An exprimental 'rifle' designed by Aetherofusion. This laser(probably) uses alien technology to fit 4 high energy capacitors \
			into a small rifle which can be stored safely(?) in any backpack. To charge, simply press down on the main control panel. \
			Rumors of this 'siphoning power off your lifeforce' are greatly exaggerated, and Aetherofusion assures safety for up to 2 years of use."
	item = /obj/item/gun/energy/laser/musket/syndicate
	progression_minimum = 30 MINUTES
	cost = 12
	surplus = 40
	purchasable_from = ~UPLINK_CLOWN_OPS
