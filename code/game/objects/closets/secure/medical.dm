/obj/structure/closet/secure_closet/medical1
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/syringes(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		return



/obj/structure/closet/secure_closet/medical2
	name = "Anesthetic"
	desc = "Used to knock people out, either by sleeping gas or brute force."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/clothing/mask/medical(src)
		new /obj/item/clothing/mask/medical(src)
		new /obj/item/clothing/mask/medical(src)
		return



/obj/structure/closet/secure_closet/medical3
	name = "Chemist's Locker"
	req_access = list(access_chemistry)


	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chemist(src)
		new /obj/item/wardrobe/chemist(src)
		new /obj/item/wardrobe/chemist(src)
		new /obj/item/wardrobe/chemist(src)
		return

/obj/structure/closet/secure_closet/CMO
	name = "Chief Medical Officer"
	req_access = list(access_cmo)


	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/cmo(src)
		new /obj/item/wardrobe/cmo(src)
		new /obj/item/wardrobe/cmo(src)
		return



/obj/structure/closet/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/device/assembly/signaler(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		return



/obj/structure/closet/secure_closet/chemical
	name = "Chemical Closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/pillbottlebox(src)
		new /obj/item/weapon/storage/pillbottlebox(src)
		return