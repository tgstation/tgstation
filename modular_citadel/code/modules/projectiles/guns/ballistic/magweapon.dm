///////XCOM X9 AR///////

/obj/item/gun/ballistic/automatic/x9	//will be adminspawn only so ERT or something can use them
	name = "\improper X9 Assault Rifle"
	desc = "A rather old design of a cheap, reliable assault rifle made for combat against unknown enemies. Uses 5.56mm ammo."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "x9"
	item_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m556	//Uses the m90gl's magazine, just like the NT-ARG
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 6	//in line with XCOMEU stats. This can fire 5 bursts from a full magazine.
	fire_delay = 1
	spread = 30	//should be 40 for XCOM memes, but since its adminspawn only, might as well make it useable
	recoil = 1

///toy memes///

/obj/item/ammo_box/magazine/toy/x9
	name = "foam force X9 magazine"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "toy9magazine"
	max_ammo = 30
	multiple_sprites = 2
	materials = list(MAT_METAL = 200)

/obj/item/gun/ballistic/automatic/x9/toy
	name = "\improper Foam Force X9"
	desc = "An old but reliable assault rifle made for combat against unknown enemies. Appears to be hastily converted. Ages 8 and up."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "toy9"
	can_suppress = 0
	obj_flags = 0
	mag_type = /obj/item/ammo_box/magazine/toy/x9
	casing_ejector = 0
	spread = 90		//MAXIMUM XCOM MEMES (actually that'd be 180 spread)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY

////////XCOM2 Magpistol/////////

//////projectiles//////

/obj/item/projectile/bullet/mags
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile"
	damage = 15
	armour_penetration = 10
	light_range = 2
	speed = 0.6
	range = 25
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/bullet/nlmags //non-lethal boolets
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile-nl"
	damage = 0
	knockdown = 0
	stamina = 25
	armour_penetration = -10
	light_range = 2
	speed = 0.7
	range = 25
	light_color = LIGHT_COLOR_BLUE


/////actual ammo/////

/obj/item/ammo_casing/caseless/amags
	desc = "A ferromagnetic slug intended to be launched out of a compatible weapon."
	caliber = "mags"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "mag-casing-live"
	projectile_type = /obj/item/projectile/bullet/mags

/obj/item/ammo_casing/caseless/anlmags
	desc = "A specialized ferromagnetic slug designed with a less-than-lethal payload."
	caliber = "mags"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "mag-casing-live"
	projectile_type = /obj/item/projectile/bullet/nlmags

//////magazines/////

/obj/item/ammo_box/magazine/mmag/small
	name = "magpistol magazine (non-lethal disabler)"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "nlmagmag"
	ammo_type = /obj/item/ammo_casing/caseless/anlmags
	caliber = "mags"
	max_ammo = 15
	multiple_sprites = 2

/obj/item/ammo_box/magazine/mmag/small/lethal
	name = "magpistol magazine (lethal)"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "smallmagmag"
	ammo_type = /obj/item/ammo_casing/caseless/amags

//////the gun itself//////

/obj/item/gun/ballistic/automatic/pistol/mag
	name = "magpistol"
	desc = "A handgun utilizing maglev technologies to propel a ferromagnetic slug to extreme velocities."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magpistol"
	force = 10
	fire_sound = 'sound/weapons/magpistol.ogg'
	mag_type = /obj/item/ammo_box/magazine/mmag/small
	can_suppress = 0
	casing_ejector = 0
	fire_delay = 2
	recoil = 0.2

/obj/item/gun/ballistic/automatic/pistol/mag/update_icon()
	..()
	if(magazine)
		cut_overlays()
		add_overlay("magpistol-magazine")
	else
		cut_overlays()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

///research memes///

/obj/item/gun/ballistic/automatic/pistol/mag/nopin
	pin = null
	spawnwithmagazine = FALSE

/datum/design/magpistol
	name = "Magpistol"
	desc = "A weapon which fires ferromagnetic slugs."
	id = "magpisol"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7500, MAT_GLASS = 1000, MAT_URANIUM = 1000, MAT_TITANIUM = 5000, MAT_SILVER = 2000)
	build_path = /obj/item/gun/ballistic/automatic/pistol/mag/nopin
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_magpistol
	name = "Magpistol Magazine"
	desc = "A 14 round magazine for the Magpistol."
	id = "mag_magpistol"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_SILVER = 500)
	build_path = /obj/item/ammo_box/magazine/mmag/small/lethal
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_magpistol/nl
	name = "Magpistol Magazine (Non-Lethal)"
	desc = "A 14 round non-lethal magazine for the Magpistol."
	id = "mag_magpistol_nl"
	materials = list(MAT_METAL = 3000, MAT_SILVER = 250, MAT_TITANIUM = 250)
	build_path = /obj/item/ammo_box/magazine/mmag/small
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

//////toy memes/////

/obj/item/projectile/bullet/reusable/foam_dart/mag
	name = "magfoam dart"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile-toy"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/mag
	light_range = 2
	light_color = LIGHT_COLOR_YELLOW

/obj/item/ammo_casing/caseless/foam_dart/mag
	name = "magfoam dart"
	desc = "A foam dart with fun light-up projectiles powered by magnets!"
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/mag

/obj/item/ammo_box/magazine/internal/shot/toy/mag
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/mag
	max_ammo = 14

/obj/item/gun/ballistic/shotgun/toy/mag
	name = "foam force magpistol"
	desc = "A fancy toy sold alongside light-up foam force darts. Ages 8 and up."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "toymag"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/mag
	fire_sound = 'sound/weapons/magpistol.ogg'
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/foambox/mag
	name = "ammo box (Magnetic Foam Darts)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/mag
	max_ammo = 42

//////Magrifle//////

///projectiles///

/obj/item/projectile/bullet/magrifle
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile-large"
	damage = 20
	armour_penetration = 25
	light_range = 3
	speed = 0.7
	range = 35
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/bullet/nlmagrifle //non-lethal boolets
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile-large-nl"
	damage = 0
	knockdown = 0
	stamina = 25
	armour_penetration = -10
	light_range = 3
	speed = 0.65
	range = 35
	light_color = LIGHT_COLOR_BLUE

///ammo casings///

/obj/item/ammo_casing/caseless/amagm
	desc = "A large ferromagnetic slug intended to be launched out of a compatible weapon."
	caliber = "magm"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "mag-casing-live"
	projectile_type = /obj/item/projectile/bullet/magrifle

/obj/item/ammo_casing/caseless/anlmagm
	desc = "A large, specialized ferromagnetic slug designed with a less-than-lethal payload."
	caliber = "magm"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "mag-casing-live"
	projectile_type = /obj/item/projectile/bullet/nlmagrifle

///magazines///

/obj/item/ammo_box/magazine/mmag/
	name = "magrifle magazine (non-lethal disabler)"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "mediummagmag"
	ammo_type = /obj/item/ammo_casing/caseless/anlmagm
	caliber = "magm"
	max_ammo = 24
	multiple_sprites = 2

/obj/item/ammo_box/magazine/mmag/lethal
	name = "magrifle magazine (lethal)"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "mediummagmag"
	ammo_type = /obj/item/ammo_casing/caseless/amagm
	max_ammo = 24

///the gun itself///

/obj/item/gun/ballistic/automatic/magrifle
	name = "\improper Magnetic Rifle"
	desc = "A simple upscalling of the technologies used in the magpistol, the magrifle is capable of firing slightly larger slugs in bursts. Compatible with the magpistol's slugs."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magrifle"
	item_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mmag
	fire_sound = 'sound/weapons/magrifle.ogg'
	can_suppress = 0
	burst_size = 3
	fire_delay = 2
	spread = 5
	recoil = 0.15
	casing_ejector = 0

///research///

/obj/item/gun/ballistic/automatic/magrifle/nopin
	pin = null
	spawnwithmagazine = FALSE

/datum/design/magrifle
	name = "Magrifle"
	desc = "An upscaled Magpistol in rifle form."
	id = "magrifle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_URANIUM = 2000, MAT_TITANIUM = 10000, MAT_SILVER = 4000, MAT_GOLD = 2000)
	build_path = /obj/item/gun/ballistic/automatic/magrifle/nopin
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_magrifle
	name = "Magrifle Magazine (Lethal)"
	desc = "A 24-round magazine for the Magrifle."
	id = "mag_magrifle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 1000)
	build_path = /obj/item/ammo_box/magazine/mmag/lethal
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_magrifle/nl
	name = "Magrifle Magazine (Non-Lethal)"
	desc = "A 24- round non-lethal magazine for the Magrifle."
	id = "mag_magrifle_nl"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 500, MAT_TITANIUM = 500)
	build_path = /obj/item/ammo_box/magazine/mmag
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

///foamagrifle///

/obj/item/ammo_box/magazine/toy/foamag
	name = "foam force magrifle magazine"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "foamagmag"
	max_ammo = 24
	multiple_sprites = 2
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/mag
	materials = list(MAT_METAL = 200)

/obj/item/gun/ballistic/automatic/magrifle/toy
	name = "foamag rifle"
	desc = "A foam launching magnetic rifle. Ages 8 and up."
	icon_state = "foamagrifle"
	obj_flags = 0
	mag_type = /obj/item/ammo_box/magazine/toy/foamag
	casing_ejector = FALSE
	spread = 60
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY

/*
// TECHWEBS IMPLEMENTATION
*/

/datum/techweb_node/magnetic_weapons
	id = "magnetic_weapons"
	display_name = "Magnetic Weapons"
	description = "Weapons using magnetic technology"
	prereq_ids = list("weaponry", "adv_weaponry", "emp_adv")
	design_ids = list("magrifle", "magpisol", "mag_magrifle", "mag_magrifle_nl", "mag_magpistol", "mag_magpistol_nl")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000


//////Hyper-Burst Rifle//////

///projectiles///

/obj/item/projectile/bullet/mags/hyper
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile"
	damage = 10
	armour_penetration = 10
	stamina = 10
	forcedodge = TRUE
	range = 6
	light_range = 1
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/bullet/mags/hyper/inferno
	icon_state = "magjectile-large"
	stamina = 0
	forcedodge = FALSE
	range = 25
	light_range = 4

/obj/item/projectile/bullet/mags/hyper/inferno/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 1, 2, 4, 5)
	return 1

///ammo casings///

/obj/item/ammo_casing/caseless/ahyper
	desc = "A large block of speciallized ferromagnetic material designed to be fired out of the experimental Hyper-Burst Rifle."
	caliber = "hypermag"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "hyper-casing-live"
	projectile_type = /obj/item/projectile/bullet/mags/hyper
	pellets = 12
	variance = 40

/obj/item/ammo_casing/caseless/ahyper/inferno
	projectile_type = /obj/item/projectile/bullet/mags/hyper/inferno
	pellets = 1
	variance = 0

///magazines///

/obj/item/ammo_box/magazine/mhyper
	name = "hyper-burst rifle magazine"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "hypermag-4"
	ammo_type = /obj/item/ammo_casing/caseless/ahyper
	caliber = "hypermag"
	desc = "A magazine for the Hyper-Burst Rifle. Loaded with a special slug that fragments into 12 smaller shards which can absolutely puncture anything, but has rather short effective range."
	max_ammo = 4

/obj/item/ammo_box/magazine/mhyper/update_icon()
	..()
	icon_state = "hypermag-[ammo_count() ? "4" : "0"]"

/obj/item/ammo_box/magazine/mhyper/inferno
	name = "hyper-burst rifle magazine (inferno)"
	ammo_type = /obj/item/ammo_casing/caseless/ahyper/inferno
	desc = "A magazine for the Hyper-Burst Rifle. Loaded with a special slug that violently reacts with whatever surface it strikes, generating a massive amount of heat and light."

///gun itself///

/obj/item/gun/ballistic/automatic/hyperburst
	name = "\improper Hyper-Burst Rifle"
	desc = "An extremely beefed up version of a stolen Nanotrasen weapon prototype, this 'rifle' is more like a cannon, with an extremely large bore barrel capable of generating several smaller magnetic 'barrels' to simultaneously launch multiple projectiles at once."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "hyperburst"
	item_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mhyper
	fire_sound = 'sound/weapons/magburst.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 40
	recoil = 2
	casing_ejector = 0
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/automatic/hyperburst/update_icon()
	..()
	icon_state = "hyperburst[magazine ? "-[get_ammo()]" : ""][chambered ? "" : "-e"]"

///toy memes///

/obj/item/projectile/beam/lasertag/mag		//the projectile, compatible with regular laser tag armor
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "magjectile-toy"
	name = "lasertag magbolt"
	forcedodge = TRUE		//for penetration memes
	range = 5		//so it isn't super annoying
	light_range = 2
	light_color = LIGHT_COLOR_YELLOW
	eyeblur = 0

/obj/item/ammo_casing/energy/laser/magtag
	projectile_type = /obj/item/projectile/beam/lasertag/mag
	select_name = "magtag"
	pellets = 3
	variance = 30
	e_cost = 1000
	fire_sound = 'sound/weapons/magburst.ogg'

/obj/item/gun/energy/laser/practice/hyperburst
	name = "toy hyper-burst launcher"
	desc = "A toy laser with a unique beam shaping lens that projects harmless bolts capable of going through objects. Compatible with existing laser tag systems."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/magtag)
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "toyburst"
	clumsy_check = FALSE
	obj_flags = 0
	fire_delay = 40
	weapon_weight = WEAPON_HEAVY
	selfcharge = TRUE
	charge_delay = 2
	recoil = 2
	cell_type = /obj/item/stock_parts/cell/toymagburst

/obj/item/stock_parts/cell/toymagburst
	name = "toy mag burst rifle power supply"
	maxcharge = 4000
