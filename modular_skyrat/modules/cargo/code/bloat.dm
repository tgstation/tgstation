//These are currently code in as a complete fucking mess. Remind me to organize later. Courtesy of ZenithEevee

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Armory //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security/armory/riotshotguns
	name = "Peacekeeper Shotgun Crate"
	desc = "For when the peace needs kept, and you're all out of gum. Contains 3 Peacekeeper shotguns and some non-lethal shells."
	cost = CARGO_CRATE_VALUE * 13.25
	contains = list(/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/storage/box/beanbag,
					/obj/item/storage/box/rubbershot)
	crate_name = "peacekeeper shotgun crate"

/datum/supply_pack/security/armory/woodstock
	name = "Woodstock Originals Crate"
	desc = "For when Oldschool is Cool... Or the Bartender looses their gun. again. Contains 3 woodstock shotguns"
	cost = CARGO_CRATE_VALUE * 9.5
	contains = list(/obj/item/gun/ballistic/shotgun,
					/obj/item/gun/ballistic/shotgun,
					/obj/item/gun/ballistic/shotgun)
	crate_name = "woodstock crate"

/datum/supply_pack/security/armory/wt550ammovariety
	name = "WT-550 Auto Rifle Ammo Variety Crate"
	desc = "AI Gone rogue and blow the Security Lathe? Anti-Corporate scum steal it? Doesn't matter, we got you covered. Contains 2 of each magazine type for the WT550 Auto Rifle."
	cost = CARGO_CRATE_VALUE * 4.5
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtic,
					/obj/item/ammo_box/magazine/wt550m9/wtic)
	crate_name = "WT550 Ammo Variety Pack"

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three vests of well-rounded, decently-protective armor. Requires Security access to open."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/suit/armor/vest/alt)
	crate_name = "armor crate"
	

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Service //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic/lavalandsamples
	name = "Planetary Flora Samples"
	desc = "A box of samples taken from the surface of Lavaland. Requires Hydroponics access to open."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_HYDROPONICS
	contains = list(/obj/item/seeds/lavaland/polypore,
					/obj/item/seeds/lavaland/porcini,
					/obj/item/seeds/lavaland/inocybe,
					/obj/item/seeds/lavaland/ember,
					/obj/item/seeds/lavaland/seraka,
					/obj/item/seeds/star_cactus,
					/obj/item/seeds/star_cactus)
	crate_name = "planetary seeds crate"
	crate_type = /obj/structure/closet/crate/hydroponics

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Goodies //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

