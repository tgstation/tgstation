/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 3, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$uranium" = 2000)
	reliability = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	locked = 1

datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 4000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = 1

datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 2000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	locked = 1

datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 8, "materials" = 7, "biotech" = 5, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 10000, "mutagen" = 40)
	build_path = /obj/item/weapon/gun/energy/decloner
	locked = 1
/*
datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000)
	reliability = 100
	build_path = /obj/item/weapon/chemsprayer"
*/
datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe
/*
datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favoured by syndicate infiltration teams."
	id = "largecrossbow"
	req_tech = list("combat" = 4, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$uranium" = 1000, "$silver" = 1000)
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow"
*/
datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energythings to change temperature."//Change it if you want
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 500, "$silver" = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature
	locked = 1

datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 500, "radium" = 20)
	build_path = /obj/item/weapon/gun/energy/floragun

datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000)
	reliability = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large

datum/design/smg
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 8000, "$silver" = 2000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic
	locked = 1

datum/design/xray
	name = "Xray Laser Gun"
	desc = "Not quite as menacing as it sounds"
	id = "xray"
	req_tech = list("combat" = 6, "materials" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 10000, "$metal" = 4000)
	build_path = /obj/item/weapon/gun/energy/xray
	locked = 1

datum/design/ionrifle
	name = "Ion Rifle"
	desc = "How to dismantle a cyborg : The gun."
	id = "ionrifle"
	req_tech = list("combat" = 5, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$silver" = 4000, "$metal" = 6000, "$uranium" = 1000)
	build_path = /obj/item/weapon/gun/energy/ionrifle
	locked = 1

datum/design/ammo_9mm
	name = "Ammunition Box (9mm)"
	desc = "A box of prototype 9mm ammunition."
	id = "ammo_9mm"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000)
	build_path = /obj/item/ammo_box/c9mm

datum/design/mag_smg
	name = "Submachine Gun Magazine (9mm)"
	desc = "A prototype magazine for the submachine gun."
	id = "mag_smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000)
	build_path = /obj/item/ammo_box/magazine/msmg9mm

datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug

datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1000, "$glass" = 200, "$silver" = 300)
	build_path = /obj/item/ammo_casing/shotgun/techshell