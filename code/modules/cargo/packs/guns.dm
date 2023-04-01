/datum/supply_pack/guns
	group = "Guns"
	access = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/gear
	var/obj/item_path = null
	var/amt = 1
	var/noun_used = "Crate"
	var/generated = FALSE

/datum/supply_pack/guns/shipment
	amt = 10
	noun_used = "Shipment"

/datum/supply_pack/guns/generate_supply_packs()
	if(!item_path || generated)
		return null
	var/datum/supply_pack/guns/new_supply_pack = new type
	new_supply_pack.generated = TRUE
	new_supply_pack.group = group
	new_supply_pack.access = access
	new_supply_pack.crate_type = crate_type
	var/name_used = initial(item_path.name)
	new_supply_pack.name = "[name_used] [noun_used]"
	new_supply_pack.desc = "A [noun_used] of [amt] [name_used]"
	new_supply_pack.cost = (CARGO_CRATE_VALUE * 2) * amt
	new_supply_pack.contains = list(
		item_path = amt,
	)
	return list(new_supply_pack)

/datum/supply_pack/ammo
	group = "Ammunition"
	access = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/gear
	var/obj/item_path = null
	var/amt = 5
	var/generated = FALSE

/datum/supply_pack/ammo/generate_supply_packs()
	if(!item_path || generated)
		return null
	var/datum/supply_pack/ammo/new_supply_pack = new type
	new_supply_pack.generated = TRUE
	new_supply_pack.group = group
	new_supply_pack.access = access
	new_supply_pack.crate_type = crate_type
	var/name_used = initial(item_path.name)
	new_supply_pack.name = "[name_used] crate"
	new_supply_pack.desc = "A crate of [name_used] ammo."
	new_supply_pack.cost = (CARGO_CRATE_VALUE * 2) * amt
	new_supply_pack.contains = list(
		item_path = amt,
	)
	return list(new_supply_pack)

/datum/supply_pack/guns/proto
	item_path = /obj/item/gun/ballistic/automatic/proto/unrestricted

/datum/supply_pack/guns/shipment/proto
	item_path = /obj/item/gun/ballistic/automatic/proto/unrestricted

/datum/supply_pack/ammo/proto
	item_path = /obj/item/ammo_box/magazine/smgm9mm

/datum/supply_pack/guns/c20r
	item_path = /obj/item/gun/ballistic/automatic/c20r/unrestricted

/datum/supply_pack/guns/shipment/c20r
	item_path = /obj/item/gun/ballistic/automatic/c20r/unrestricted

/datum/supply_pack/ammo/c20r
	item_path = /obj/item/ammo_box/magazine/smgm45

/datum/supply_pack/guns/wt550
	item_path = /obj/item/gun/ballistic/automatic/wt550

/datum/supply_pack/guns/shipment/wt550
	item_path = /obj/item/gun/ballistic/automatic/wt550

/datum/supply_pack/ammo/wt550
	item_path = /obj/item/ammo_box/magazine/wt550m9

/datum/supply_pack/guns/plastikov
	item_path = /obj/item/gun/ballistic/automatic/plastikov

/datum/supply_pack/guns/shipment/plastikov
	item_path = /obj/item/gun/ballistic/automatic/plastikov

/datum/supply_pack/ammo/plastikov
	item_path = /obj/item/ammo_box/magazine/plastikov9mm

/datum/supply_pack/guns/mini_uzi
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi

/datum/supply_pack/guns/shipment/mini_uzi
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi

/datum/supply_pack/ammo/mini_uzi
	item_path = /obj/item/ammo_box/magazine/uzim9mm

/datum/supply_pack/guns/m90
	item_path = /obj/item/gun/ballistic/automatic/m90/unrestricted

/datum/supply_pack/guns/shipment/m90
	item_path = /obj/item/gun/ballistic/automatic/m90/unrestricted

/datum/supply_pack/ammo/m90
	item_path = /obj/item/ammo_box/magazine/m556

/datum/supply_pack/guns/tommygun
	item_path = /obj/item/gun/ballistic/automatic/tommygun

/datum/supply_pack/guns/shipment/tommygun
	item_path = /obj/item/gun/ballistic/automatic/tommygun

/datum/supply_pack/ammo/tommygun
	item_path = /obj/item/ammo_box/magazine/tommygunm45

/datum/supply_pack/guns/ar
	item_path = /obj/item/gun/ballistic/automatic/ar

/datum/supply_pack/guns/shipment/ar
	item_path = /obj/item/gun/ballistic/automatic/ar

/datum/supply_pack/guns/l6_saw
	item_path = /obj/item/gun/ballistic/automatic/l6_saw/unrestricted

/datum/supply_pack/guns/shipment/l6_saw
	item_path = /obj/item/gun/ballistic/automatic/l6_saw/unrestricted

/datum/supply_pack/ammo/l6_saw
	item_path = /obj/item/ammo_box/magazine/mm712x82

/datum/supply_pack/guns/surplus
	item_path = /obj/item/gun/ballistic/automatic/surplus

/datum/supply_pack/guns/shipment/surplus
	item_path = /obj/item/gun/ballistic/automatic/surplus

/datum/supply_pack/ammo/surplus
	item_path = /obj/item/ammo_box/magazine/m10mm/rifle

/datum/supply_pack/guns/laser
	item_path = /obj/item/gun/ballistic/automatic/laser

/datum/supply_pack/guns/shipment/laser
	item_path = /obj/item/gun/ballistic/automatic/laser

/datum/supply_pack/ammo/laser
	item_path = /obj/item/ammo_box/magazine/recharge

/datum/supply_pack/guns/gyropistol
	item_path = /obj/item/gun/ballistic/automatic/gyropistol

/datum/supply_pack/guns/shipment/gyropistol
	item_path = /obj/item/gun/ballistic/automatic/gyropistol

/datum/supply_pack/ammo/gyropistol
	item_path = /obj/item/ammo_box/magazine/m75

/datum/supply_pack/guns/rocketlauncher
	item_path = /obj/item/gun/ballistic/rocketlauncher/unrestricted

/datum/supply_pack/guns/shipment/rocketlauncher
	item_path = /obj/item/gun/ballistic/rocketlauncher/unrestricted

/datum/supply_pack/ammo/rocketlauncher
	item_path = /obj/item/ammo_casing/caseless/rocket

/datum/supply_pack/guns/pistol
	item_path = /obj/item/gun/ballistic/automatic/pistol

/datum/supply_pack/guns/shipment/pistol
	item_path = /obj/item/gun/ballistic/automatic/pistol

/datum/supply_pack/ammo/pistol
	item_path = /obj/item/ammo_box/magazine/m9mm

/datum/supply_pack/guns/pistol/clandestine
	item_path = /obj/item/gun/ballistic/automatic/pistol/clandestine

/datum/supply_pack/guns/shipment/pistol/clandestine
	item_path = /obj/item/gun/ballistic/automatic/pistol/clandestine

/datum/supply_pack/ammo/pistol/clandestine
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/supply_pack/guns/pistol/m1911
	item_path = /obj/item/gun/ballistic/automatic/pistol/m1911

/datum/supply_pack/guns/shipment/pistol/m1911
	item_path = /obj/item/gun/ballistic/automatic/pistol/m1911

/datum/supply_pack/ammo/pistol/m1911
	item_path = /obj/item/ammo_box/magazine/m45

/datum/supply_pack/guns/pistol/deagle
	item_path = /obj/item/gun/ballistic/automatic/pistol/deagle

/datum/supply_pack/guns/shipment/pistol/deagle
	item_path = /obj/item/gun/ballistic/automatic/pistol/deagle

/datum/supply_pack/ammo/pistol/deagle
	item_path = /obj/item/ammo_box/magazine/m50

/datum/supply_pack/guns/pistol/aps
	item_path = /obj/item/gun/ballistic/automatic/pistol/aps

/datum/supply_pack/guns/shipment/pistol/aps
	item_path = /obj/item/gun/ballistic/automatic/pistol/aps

/datum/supply_pack/ammo/pistol/aps
	item_path = /obj/item/ammo_box/magazine/m9mm_aps

/datum/supply_pack/guns/rifle
	item_path = /obj/item/gun/ballistic/rifle/boltaction

/datum/supply_pack/guns/shipment/rifle
	item_path = /obj/item/gun/ballistic/rifle/boltaction

/datum/supply_pack/ammo/rifle
	item_path = /obj/item/ammo_casing/a762

/datum/supply_pack/guns/bulldog
	item_path = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted

/datum/supply_pack/guns/shipment/bulldog
	item_path = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted

/datum/supply_pack/ammo/bulldog
	item_path = /obj/item/ammo_box/magazine/m12g

/datum/supply_pack/guns/shotgun
	item_path = /obj/item/gun/ballistic/shotgun

/datum/supply_pack/guns/shipment/shotgun
	item_path = /obj/item/gun/ballistic/shotgun

/datum/supply_pack/guns/shotgun/riot
	item_path = /obj/item/gun/ballistic/shotgun/riot

/datum/supply_pack/guns/shipment/shotgun/riot
	item_path = /obj/item/gun/ballistic/shotgun/riot

/datum/supply_pack/guns/shotgun/automatic_combat
	item_path = /obj/item/gun/ballistic/shotgun/automatic/combat

/datum/supply_pack/guns/shipment/shotgun/automatic_combat
	item_path = /obj/item/gun/ballistic/shotgun/automatic/combat

/datum/supply_pack/guns/shotgun/automatic_dual_tube
	item_path = /obj/item/gun/ballistic/shotgun/automatic/dual_tube

/datum/supply_pack/guns/shipment/shotgun/automatic_dual_tube
	item_path = /obj/item/gun/ballistic/shotgun/automatic/dual_tube


