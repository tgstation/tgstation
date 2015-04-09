/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/pin_testing
	name = "test-range firing pin"
	desc = "This safety firing pin allows firearms to be operated within proximity to a firing range."
	id = "pin_testing"
	req_tech = list("combat" = 1, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 500, "$glass" = 300)
	build_path = /obj/item/device/firing_pin/test_range
	category = list("Firing Pins")

/datum/design/pin_loyalty
	name = "loyalty firing pin"
	desc = "This is a security firing pin which only authorizes users who are loyalty-implanted."
	id = "pin_loyalty"
	req_tech = list("combat" = 6, "materials" = 6, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$silver" = 600, "$diamond" = 600, "$uranium" = 200)
	build_path = /obj/item/device/firing_pin/implant/loyalty
	category = list("Firing Pins")

/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "A high-tech revolver that fires internal, reusable taser cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 4000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	category = list("Weapons")

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 4, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$uranium" = 2000)
	reliability = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	category = list("Weapons")

/datum/design/tele_shield
	name = "Telescopic Riot Shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	id = "tele_shield"
	req_tech = list("combat" = 4, "materials" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 4000, "$glass" = 5000, "$silver" = 300)
	build_path = /obj/item/weapon/shield/riot/tele
	category = list("Weapons")

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 2000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 8, "materials" = 7, "biotech" = 5, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 10000, "mutagen" = 40)
	build_path = /obj/item/weapon/gun/energy/decloner
	category = list("Weapons")

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe
	category = list("Weapons")

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A reverse-engineered energy crossbow favored by syndicate infiltration teams and carp hunters."
	id = "largecrossbow"
	req_tech = list("combat" = 5, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1500, "$uranium" = 1500, "$silver" = 1500)
	build_path = /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large
	category = list("Weapons")
	reliability = 76

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energythings to change temperature."//Change it if you want
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 500, "$silver" = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature
	category = list("Weapons")

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 500, "radium" = 20)
	build_path = /obj/item/weapon/gun/energy/floragun
	category = list("Weapons")

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000)
	reliability = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large
	category = list("Weapons")

/datum/design/smg
	name = "Prototype Submachine Gun"
	desc = "A prototype weapon made using lightweight materials on a traditional frame, designed to fire standard 9mm rounds."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 8000, "$silver" = 2000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic/proto
	category = list("Weapons")

/datum/design/xray
	name = "Xray Laser Gun"
	desc = "Not quite as menacing as it sounds"
	id = "xray"
	req_tech = list("combat" = 6, "materials" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 10000, "$metal" = 4000)
	build_path = /obj/item/weapon/gun/energy/xray
	category = list("Weapons")

/datum/design/ioncarbine
	name = "Ion Carbine"
	desc = "How to dismantle a cyborg : The gun."
	id = "ioncarbine"
	req_tech = list("combat" = 5, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$silver" = 4000, "$metal" = 6000, "$uranium" = 1000)
	build_path = /obj/item/weapon/gun/energy/ionrifle/carbine
	category = list("Weapons")

/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	id = "wormholeprojector"
	req_tech = list("combat" = 6, "materials" = 6, "bluespace" = 4)
	build_type = PROTOLATHE
	materials = list("$silver" = 1000, "$metal" = 5000, "$diamond" = 3000)
	build_path = /obj/item/weapon/gun/energy/wormhole_projector
	category = list("Weapons")

/datum/design/reciever
	name = "Modular Receiver"
	desc = "A prototype modular receiver and trigger assembly for a variety of firearms."
	id = "reciever"
	req_tech = list("combat" = 5, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 6500, "$silver" = 500)
	build_path = /obj/item/weaponcrafting/reciever
	category = list("Weapons")

/datum/design/mag_smg
	name = "Submachine Gun Magazine (9mm)"
	desc = "A 20-round magazine for the prototype submachine gun."
	id = "mag_smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000)
	build_path = /obj/item/ammo_box/magazine/smgm9mm
	category = list("Ammo")

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Ammo")

/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1000, "$glass" = 200, "$silver" = 300)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Ammo")

/datum/design/suppressor
	name = "Universal Suppressor"
	desc = "A reverse-engineered universal suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	req_tech = list("combat" = 6, "engineering" = 5, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$silver" = 500)
	build_path = /obj/item/weapon/suppressor
	category = list("Weapons")
