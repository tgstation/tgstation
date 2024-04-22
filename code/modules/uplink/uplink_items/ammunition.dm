/datum/uplink_category/ammo
	name = "Ammunition"
	weight = 7

/datum/uplink_item/ammo
	category = /datum/uplink_category/ammo
	surplus = 40

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft riot darts, for reloading any compatible foam dart magazine. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/ammo/pistol
	name = "9mm Handgun Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol."
	item = /obj/item/ammo_box/magazine/m9mm
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistol/ap
	name = "9mm Armour Piercing Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m9mm/ap
	cost = 2

/datum/uplink_item/ammo/pistol/hp
	name = "9mm Hollow Point Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m9mm/hp
	cost = 3

/datum/uplink_item/ammo/pistol/fire
	name = "9mm Incendiary Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m9mm/fire
	cost = 2

/datum/uplink_item/ammo/pistol10mm
	name = "10mm Handgun Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistol10mm/ap
	name = "10mm Armor-Piercing Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 2

/datum/uplink_item/ammo/pistol10mm/hp
	name = "10mm Hollow-Point Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 3

/datum/uplink_item/ammo/pistol10mm/fire
	name = "10mm Incendiary Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			Loaded with incendiary rounds which inflict reduced damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 2

/datum/uplink_item/ammo/handgun45
	name = ".45mm Handgun Magazine"
	desc = "An additional 8-round .45mm magazine, compatible with the M1911 pistol."
	item = /obj/item/ammo_box/magazine/m45
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45/ap
	name = ".45mm Armor Piercing Magazine"
	desc = "A single 8-round Armor Piercing .45mm magazines, compatible with the M1911 pistol. \
			Exceptional when used against armored targets."
	item = /obj/item/ammo_box/magazine/m45/ap
	cost = 2
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45/hp
	name = ".45mm Hollow Point Magazine"
	desc = "A single 8-round Hollow Point .45mm magazines, compatible with the M1911 pistol. \
			Ineffective against armored targets, but very good again non-armored targets."
	item = /obj/item/ammo_box/magazine/m45/hp
	cost = 3
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45/inc
	name = ".45mm Incendiary Magazine"
	desc = "A single 8-round Incendiary .45mm magazines, compatible with the M1911 pistol. \
			These bullets will lit your targets ablaze, though they don't leave behind a trail of fire."
	item = /obj/item/ammo_box/magazine/m45/inc
	cost = 2
	illegal_tech = FALSE

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the Syndicate revolver. \
			For when you really need a lot of things dead."
	item = /obj/item/ammo_box/a357
	cost = 4
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY) //nukies get their own version
	illegal_tech = FALSE

/datum/uplink_item/ammo/deagle
	name = ".50 AE Handgun Magazine"
	desc = "An additional 7-round .50 AE magazine, compatible with the Desert Eagle."
	item = /obj/item/ammo_box/magazine/m50
	cost = 4
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/boltactionammo
	name = "Stripper Clips"
	desc = "Five stripper clips for those shoddy bolt action rifles we're selling you."
	item = /obj/item/storage/box/syndie_kit/stripperclips
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/tommygun
	name = "Tommy Gun Drum Magazine"
	desc = "An additional 50-round .45 caliber drum magazine, compatible with the Tommy Gun."
	item = /obj/item/ammo_box/magazine/tommygunm45
	cost = 6 // 15 + 6 for 100 rounds of .45. If you dumped out 6 .45 mags, you'd get 48 bullets.
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akm
	name = "Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akmap
	name = "Armor-Piercing Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round Armor-Piercing 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82/ap
	cost = 4
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akmhp
	name = "Hollow-Point Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round Hollow-Point 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82/hp
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akmincendiary
	name = "Incendiary Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round Incendiary 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82/incendiary
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/magspears
	name = "Harpoon Quiver"
	desc = "A quiver containing 7 harpoons for use with the Ballistic Harpoon Gun."
	item = /obj/item/storage/harpoon_quiver
	cost = 4
	surplus = 0
	illegal_tech = FALSE // Just a pouch filled with giant hunks of metal.
