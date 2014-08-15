/obj/machinery/manufacturer/mining
	name = "Mining Fabricator"
	desc = "A manufacturing unit calibrated to produce mining related equipment."
	acceptdisk = 1

	New()
		..()
		src.available += new /datum/manufacture/pick(src)
		src.available += new /datum/manufacture/shovel(src)
		src.available += new /datum/manufacture/oresatchel(src)
		src.available += new /datum/manufacture/breathmask(src)
		src.available += new /datum/manufacture/spacesuit(src)
		src.available += new /datum/manufacture/spacehelm(src)
		src.available += new /datum/manufacture/eyes_meson(src)
		src.hidden += new /datum/manufacture/RCD(src)
		src.hidden += new /datum/manufacture/RCDammo(src)


// Mining Gear
/datum/manufacture/pick
	name = "Pickaxe"
	item = /obj/item/weapon/pickaxe
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 5
	time = 5
	create = 1

/datum/manufacture/shovel
	name = "Shovel"
	item = /obj/item/weapon/shovel
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 3
	time = 2
	create = 1

/datum/manufacture/dpick
	name = "Diamond Pickaxe"
	item = /obj/item/weapon/pickaxe/diamond
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/claretine
	cname2 = "Claretine"
	amount2 = 5
	time = 30
	create = 1

/datum/manufacture/jackhammer
	name = "Sonic Jackhammer"
	item = /obj/item/weapon/pickaxe/jackhammer
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 8
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 12
	time = 30
	create = 1

/datum/manufacture/drill
	name = "Hand Drill"
	item = /obj/item/weapon/pickaxe/drill
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 15
	time = 20
	create = 1

/datum/manufacture/diamonddrill
	name = "Diamomnd Drill"
	item = /obj/item/weapon/pickaxe/diamonddrill
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 15
	cost2 = /obj/item/weapon/ore/claretine
	cname2 = "Claretine"
	amount2 = 15
	cost3 = /obj/item/weapon/ore/pharosium
	cname3 = "Pharosium"
	amount3 = 15
	time = 40
	create = 1

/datum/manufacture/cutter
	name = "Plasma Cutter"
	item = /obj/item/weapon/pickaxe/plasmacutter
	cost1 = /obj/item/weapon/ore/mauxite
	cname1 = "Mauxite"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/bohrum
	cname2 = "Bohrum"
	amount2 = 10
	cost3 = /obj/item/weapon/ore/char
	cname3 = "Char"
	amount3 = 15
	time = 30
	create = 1

/datum/manufacture/eyes_meson
	name = "Optical Meson Scanner"
	item = /obj/item/clothing/glasses/meson
	cost1 = /obj/item/weapon/ore/molitz
	cname1 = "Molitz"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 3
	time = 10
	create = 1

/datum/manufacture/miningsuit
	name = "Mining Hardsuit"
	item = /obj/item/clothing/suit/space/rig/mining
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 30
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 30
	time = 30
	create = 1

/datum/manufacture/mininghelm
	name = "Mining Hardsuit Helmet"
	item = /obj/item/clothing/head/helmet/space/rig/mining
	cost1 = /obj/item/weapon/ore/uqill
	cname1 = "Uqill"
	amount1 = 30
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 30
	time = 20
	create = 1

/datum/manufacture/breathmask
	name = "Breath Mask"
	item = /obj/item/clothing/mask/breath
	cost1 = /obj/item/weapon/ore/cobryl
	cname1 = "Cobryl"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/spacesuit
	name = "Space Suit"
	item = /obj/item/clothing/suit/space
	cost1 = /obj/item/weapon/ore/cobryl
	cname1 = "Cobryl"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/mauxite
	cname2 = "Mauxite"
	amount2 = 5
	time = 15
	create = 1

/datum/manufacture/spacehelm
	name = "Space Helmet"
	item = /obj/item/clothing/head/helmet/space
	cost1 = /obj/item/weapon/ore/cobryl
	cname1 = "Cobryl"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/molitz
	cname2 = "Molitz"
	amount2 = 5
	time = 10
	create = 1

/datum/manufacture/oresatchel
	name = "Ore Satchel"
	item = /obj/item/weapon/storage/bag/ore
	cost1 = /obj/item/weapon/ore/cobryl
	cname1 = "Cobryl"
	amount1 = 5
	time = 5
	create = 1

/datum/manufacture/jetpack
	name = "Jetpack"
	item = /obj/item/weapon/tank/jetpack
	cost1 = /obj/item/weapon/ore/bohrum
	cname1 = "Bohrum"
	amount1 = 15
	cost2 = /obj/item/weapon/ore/pharosium
	cname2 = "Pharosium"
	amount2 = 20
	time = 30
	create = 1

//Diskettes!
/obj/item/weapon/disk/data/schematic/mining1
	name = "Mining Schematics Level 1"
	desc = "Contains the schematics for a new Pickaxe."

	New()
		..()
		src.schematics += new /datum/manufacture/dpick(src)

/obj/item/weapon/disk/data/schematic/mining2
	name = "Mining Schematics Level 2"
	desc = "Contains the schematics for a new line of drills. And a Char Cutter. Has the previous level as well."

	New()
		..()
		src.schematics += new /datum/manufacture/dpick(src)
		src.schematics += new /datum/manufacture/drill(src)
		src.schematics += new /datum/manufacture/jackhammer(src)
		src.schematics += new /datum/manufacture/diamonddrill(src)
		src.schematics += new /datum/manufacture/cutter(src)

/obj/item/weapon/disk/data/schematic/mining3
	name = "Mining Schematics Level 3"
	desc = "Contains the schematics for a new type of Spacesuit, and schematics for a Jetpack. Has the previous levels as well."

	New()
		..()
		src.schematics += new /datum/manufacture/dpick(src)
		src.schematics += new /datum/manufacture/drill(src)
		src.schematics += new /datum/manufacture/jackhammer(src)
		src.schematics += new /datum/manufacture/diamonddrill(src)
		src.schematics += new /datum/manufacture/cutter(src)
		src.schematics += new /datum/manufacture/miningsuit(src)
		src.schematics += new /datum/manufacture/mininghelm(src)
		src.schematics += new /datum/manufacture/jetpack(src)