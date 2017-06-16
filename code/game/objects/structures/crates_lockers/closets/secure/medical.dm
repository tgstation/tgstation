/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled to the brim with medical junk."
	icon_state = "med"
	req_access = list(GLOB.access_medical)

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker(src)
	new /obj/item/weapon/reagent_containers/glass/beaker(src)
	new /obj/item/weapon/reagent_containers/dropper(src)
	new /obj/item/weapon/reagent_containers/dropper(src)
	new /obj/item/weapon/storage/belt/medical(src)
	new /obj/item/weapon/storage/box/syringes(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/toxin(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/morphine(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/glass/bottle/epinephrine(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/glass/bottle/charcoal(src)
	new /obj/item/weapon/storage/box/rxglasses(src)

/obj/structure/closet/secure_closet/medical2
	name = "anesthetic closet"
	desc = "Used to knock people out."
	req_access = list(GLOB.access_surgery)

/obj/structure/closet/secure_closet/medical2/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/weapon/tank/internals/anesthetic(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(GLOB.access_surgery)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	..()
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/weapon/defibrillator/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/weapon/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	return

/obj/structure/closet/secure_closet/CMO
	name = "\proper chief medical officer's locker"
	req_access = list(GLOB.access_cmo)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/weapon/storage/backpack/duffelbag/med(src)
	new /obj/item/clothing/suit/bio_suit/cmo(src)
	new /obj/item/clothing/head/bio_hood/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/under/rank/chief_medical_officer(src)
	new /obj/item/clothing/shoes/sneakers/brown	(src)
	new /obj/item/weapon/cartridge/cmo(src)
	new /obj/item/device/radio/headset/heads/cmo(src)
	new /obj/item/device/megaphone/command(src)
	new /obj/item/weapon/defibrillator/compact/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/weapon/storage/belt/medical(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/weapon/reagent_containers/hypospray/CMO(src)
	new /obj/item/device/autosurgeon/cmo(src)
	new /obj/item/weapon/door_remote/chief_medical_officer(src)

/obj/structure/closet/secure_closet/animal
	name = "animal control"
	req_access = list(GLOB.access_surgery)

/obj/structure/closet/secure_closet/animal/PopulateContents()
	..()
	new /obj/item/device/assembly/signaler(src)
	for(var/i in 1 to 3)
		new /obj/item/device/electropack(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	icon_door = "chemical"

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	..()
	new /obj/item/weapon/storage/box/pillbottles(src)
	new /obj/item/weapon/storage/box/pillbottles(src)
