#define OPS_SUBCATEGORY_RIFLE "Assault Rifles"
#define OPS_SUBCATEGORY_RIFLE_AMMO "Specialty Assault Rifle Ammo"

#define OPS_SUBCATEGORY_SMG "Submachine Guns"
#define OPS_SUBCATEGORY_SMG_AMMO "Speciality Submachine Gun Ammo"

#define OPS_SUBCATEGORY_SHOTGUN "Shotguns"
#define OPS_SUBCATEGORY_SHOTGUN_AMMO "Speciality Shotgun Ammo"

#define OPS_SUBCATEGORY_SNIPER "Grenade Launchers"
#define OPS_SUBCATEGORY_SNIPER_AMMO "Speciality Grenade Launcher Ammo"

/datum/armament_entry/assault_operatives/primary
	category = "Long Arms"
	category_item_limit = 6
	mags_to_spawn = 3
	cost = 10

/datum/armament_entry/assault_operatives/primary/rifle
	subcategory = OPS_SUBCATEGORY_RIFLE

/datum/armament_entry/assault_operatives/primary/rifle/assault_ops_rifle
	item_type = /obj/item/gun/ballistic/automatic/sol_rifle/evil

/datum/armament_entry/assault_operatives/primary/rifle_ammo
	subcategory = OPS_SUBCATEGORY_RIFLE_AMMO
	max_purchase = 10
	cost = 1

/datum/armament_entry/assault_operatives/primary/rifle_ammo/standard
	item_type = /obj/item/ammo_box/magazine/c40sol_rifle/starts_empty
	cost = 0

/datum/armament_entry/assault_operatives/primary/rifle_ammo/drum
	item_type = /obj/item/ammo_box/magazine/c40sol_rifle/drum/starts_empty
	cost = 0

/datum/armament_entry/assault_operatives/primary/rifle_ammo/c40sol
	item_type = /obj/item/ammo_box/c40sol

/datum/armament_entry/assault_operatives/primary/rifle_ammo/c40sol_disabler
	item_type = /obj/item/ammo_box/c40sol/fragmentation

/datum/armament_entry/assault_operatives/primary/rifle_ammo/c40sol_pierce
	item_type = /obj/item/ammo_box/c40sol/pierce

/datum/armament_entry/assault_operatives/primary/rifle_ammo/c40sol_incendiary
	item_type = /obj/item/ammo_box/c40sol/incendiary


/datum/armament_entry/assault_operatives/primary/submachinegun
	subcategory = OPS_SUBCATEGORY_SMG

/datum/armament_entry/assault_operatives/primary/submachinegun/assault_ops_smg
	item_type = /obj/item/gun/ballistic/automatic/sol_smg/evil

/datum/armament_entry/assault_operatives/primary/submachinegun_ammo
	subcategory = OPS_SUBCATEGORY_SMG_AMMO
	max_purchase = 10
	cost = 1

/datum/armament_entry/assault_operatives/primary/submachinegun_ammo/standard
	item_type = /obj/item/ammo_box/magazine/c35sol_pistol/starts_empty
	cost = 0

/datum/armament_entry/assault_operatives/primary/submachinegun_ammo/extended
	item_type = /obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty
	cost = 0

/datum/armament_entry/assault_operatives/primary/submachinegun_ammo/c35sol
	item_type = /obj/item/ammo_box/c35sol

/datum/armament_entry/assault_operatives/primary/submachinegun_ammo/c35sol_disabler
	item_type = /obj/item/ammo_box/c35sol/incapacitator

/datum/armament_entry/assault_operatives/primary/submachinegun_ammo/c35sol_pierce
	item_type = /obj/item/ammo_box/c35sol/ripper

/datum/armament_entry/assault_operatives/primary/shotgun
	subcategory = OPS_SUBCATEGORY_SHOTGUN

/datum/armament_entry/assault_operatives/primary/shotgun/assault_ops_shotgun
	item_type = /obj/item/gun/ballistic/shotgun/riot/sol/evil

/datum/armament_entry/assault_operatives/primary/shotgun_ammo
	subcategory = OPS_SUBCATEGORY_SHOTGUN_AMMO
	max_purchase = 10
	cost = 1

/datum/armament_entry/assault_operatives/primary/shotgun_ammo/rubber
	item_type = /obj/item/ammo_box/advanced/s12gauge/rubber

/datum/armament_entry/assault_operatives/primary/shotgun_ammo/flechette
	item_type = /obj/item/ammo_box/advanced/s12gauge/flechette

/datum/armament_entry/assault_operatives/primary/shotgun_ammo/hollowpoint
	item_type = /obj/item/ammo_box/advanced/s12gauge/hp

/datum/armament_entry/assault_operatives/primary/shotgun_ammo/beehive
	item_type = /obj/item/ammo_box/advanced/s12gauge/beehive

/datum/armament_entry/assault_operatives/primary/shotgun_ammo/incendiary
	item_type = /obj/item/ammo_box/advanced/s12gauge/incendiary

/datum/armament_entry/assault_operatives/primary/sniper
	subcategory = OPS_SUBCATEGORY_SNIPER

/datum/armament_entry/assault_operatives/primary/sniper/assault_ops_gl
	item_type = /obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil

/datum/armament_entry/assault_operatives/primary/sniper_ammo
	subcategory = OPS_SUBCATEGORY_SNIPER_AMMO
	max_purchase = 10
	cost = 1

/datum/armament_entry/assault_operatives/primary/sniper_ammo/standard
	item_type = /obj/item/ammo_box/magazine/c980_grenade/starts_empty
	cost = 0

/datum/armament_entry/assault_operatives/primary/sniper_ammo/drum
	item_type = /obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	cost = 0

/datum/armament_entry/assault_operatives/primary/sniper_ammo/practice
	item_type = /obj/item/ammo_box/c980grenade

/datum/armament_entry/assault_operatives/primary/sniper_ammo/smoke
	item_type = /obj/item/ammo_box/c980grenade/smoke

/datum/armament_entry/assault_operatives/primary/sniper_ammo/shrapnel
	item_type = /obj/item/ammo_box/c980grenade/shrapnel

/datum/armament_entry/assault_operatives/primary/sniper_ammo/phosphor
	item_type = /obj/item/ammo_box/c980grenade/shrapnel/phosphor

/datum/armament_entry/assault_operatives/primary/sniper_ammo/riot
	item_type = /obj/item/ammo_box/c980grenade/riot

#undef OPS_SUBCATEGORY_RIFLE
#undef OPS_SUBCATEGORY_RIFLE_AMMO

#undef OPS_SUBCATEGORY_SMG
#undef OPS_SUBCATEGORY_SMG_AMMO

#undef OPS_SUBCATEGORY_SHOTGUN
#undef OPS_SUBCATEGORY_SHOTGUN_AMMO

#undef OPS_SUBCATEGORY_SNIPER
#undef OPS_SUBCATEGORY_SNIPER_AMMO
