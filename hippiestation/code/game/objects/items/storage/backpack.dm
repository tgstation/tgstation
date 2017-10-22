/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	desc = "A large duffel bag containing deadly chemicals, a chemical spray, a toxic foam grenade, a nerve gas grenade, a Donksoft assault rifle, riot grade darts, a minature syringe gun, and a box of syringes"

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle/PopulateContents()
	new /obj/item/reagent_containers/spray/chemsprayer/bioterror(src)
	new /obj/item/storage/box/syndie_kit/chemical(src)
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/gun/ballistic/automatic/c20r/toy(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/ammo_box/foambox/riot(src)
	new /obj/item/grenade/chem_grenade/bioterrorfoam(src)
	new /obj/item/grenade/chem_grenade/saringas(src)
	
/obj/item/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	new /obj/item/scalpel/syndicate(src)
	new /obj/item/hemostat/syndicate(src)
	new /obj/item/retractor/syndicate(src)
	new /obj/item/circular_saw/syndicate(src)
	new /obj/item/surgicaldrill/syndicate(src)
	new /obj/item/cautery/syndicate(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/device/mmi/syndie(src)
