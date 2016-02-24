/datum/design/nuclear_gun
	name = "Advanced Energy Gun Modkit"
	desc = "Can be used on an energy gun to grant it the ability to recharge itself over time."
	id = "nuclear_gun"
	req_tech = list("combat" = 3, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_URANIUM = 500)
	reliability_base = 76
	category = "Weapons"
	build_path = /obj/item/device/modkit/aeg_parts
	

/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/lasercannon
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/xcomplasmapistol
	name = "Plasma Pistol"
	desc = "A plasma pistol."
	id = "xcomplasmapistol"
	req_tech = list("combat" = 5, "materials" = 3, "powerstorage" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_PLASMA = 12000, MAT_URANIUM = 4000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/plasma/pistol
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/xcomplasmarifle
	name = "Plasma Cannon"
	desc = "A plasma cannon."
	id = "xcomplasmarifle"
	req_tech = list("combat" = 5, "materials" = 3, "powerstorage" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 3000, MAT_PLASMA = 28000, MAT_URANIUM = 12000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/plasma/rifle
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/xcomlightplasmarifle
	name = "Plasma Rifle"
	desc = "A plasma rifle."
	id = "xcomlightplasmarifle"
	req_tech = list("combat" = 5, "materials" = 3, "powerstorage" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_PLASMA = 20000, MAT_URANIUM = 8000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/plasma/light
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/xcomlaserrifle
	name = "Laser Rifle"
	desc = "A laser rifle."
	id = "xcomlaserrifle"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/laser/rifle
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/xcomlaserpistol
	name = "Laser Pistol"
	desc = "A laser pistol."
	id = "xcomlaserpistol"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/laser/pistol
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/xcomar
	name = "Assault Rifle"
	desc = "An Assault Rifle."
	id = "xcomar"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 10000, MAT_GLASS = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/projectile/automatic/xcom
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/ammo_12mm
	name = "Ammunition Box (12mm)"
	desc = "A box of 12mm ammunition."
	id = "ammo_12mm"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 2000, MAT_GLASS = 200)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/box/c12mm

/datum/design/magazine_12mm
	name = "Magazine (12mm)"
	desc = "A magazine that holds 12mm ammunition."
	id = "magazine_12mm"
	req_tech = list("combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 300)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/magazine/a12mm/empty

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 4, "materials" = 4, "biotech" = 5, "powerstorage" = 4, "syndicate" = 3) //More reasonable
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GOLD = 5000,MAT_URANIUM = 10000) //, "mutagen" = 40)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/decloner
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000)
	reliability_base = 100
	category = "Weapons"
	build_path = /obj/item/weapon/reagent_containers/spray/chemsprayer
	req_lock_access = list(access_medical, access_cmo)

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favoured by syndicate infiltration teams."
	id = "largecrossbow"
	req_tech = list("combat" = 4, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_URANIUM = 1000, MAT_SILVER = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that changes the body temperature of its targets."
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/energy/temperature
	locked = 1
	req_lock_access = list(access_tox, access_robotics, access_rd)

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000)
	reliability_base = 79
	category = "Weapons"
	build_path = /obj/item/weapon/grenade/chem_grenade/large

/datum/design/ex_grenade
	name = "EX Grenade"
	desc = "A large grenade that is designed to hold three containers."
	id = "ex_Grenade"
	req_tech = list("combat" = 4, "materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000)
	reliability_base = 79
	category = "Weapons"
	build_path = /obj/item/weapon/grenade/chem_grenade/exgrenade

/datum/design/smg
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 8000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	category = "Weapons"
	build_path = /obj/item/weapon/gun/projectile/automatic
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/ammo_9mm
	name = "Ammunition Box (9mm)"
	desc = "A box of prototype 9mm ammunition."
	id = "ammo_9mm"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3750, MAT_SILVER = 100)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/box/c9mm

/datum/design/magazine_9mm
	name = "Magazine (9mm SMG)"
	desc = "A SMG magazine that holds 9mm ammunition."
	id = "magazine_9mm"
	req_tech = list("combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 300)
	category = "Weapons"
	build_path = /obj/item/ammo_storage/magazine/smg9mm/empty

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4000)
	category = "Weapons"
	build_path = /obj/item/ammo_casing/shotgun/stunshell

/datum/design/pneumatic
	name = "Pneumatic Cannon"
	desc = "A launcher powered by compressed air."
	id = "pneumatic"
	req_tech = list("materials" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 12000)
	category = "Weapons"
	build_path = /obj/item/weapon/storage/pneumatic
