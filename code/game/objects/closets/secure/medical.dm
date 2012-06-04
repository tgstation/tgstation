/obj/structure/closet/secure_closet/medical1
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
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
	desc = "Used to knock people out."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/clothing/mask/breath/medical(src)
		new /obj/item/clothing/mask/breath/medical(src)
		new /obj/item/clothing/mask/breath/medical(src)
		return



/obj/structure/closet/secure_closet/medical3
	name = "Medical Doctor's Locker"
	req_access = list(access_medical)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/backpack/medic(src)
		new /obj/item/clothing/under/rank/nursesuit (src)
		new /obj/item/clothing/head/nursehat (src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
		new /obj/item/clothing/under/rank/medical(src)
		new /obj/item/clothing/suit/labcoat(src)
		new /obj/item/clothing/shoes/white(src)
//		new /obj/item/weapon/cartridge/medical(src)
		new /obj/item/device/radio/headset/headset_med(src)
		new /obj/item/weapon/storage/belt/medical(src)
		return



/obj/structure/closet/secure_closet/CMO
	name = "Chief Medical Officer's Locker"
	req_access = list(access_cmo)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/suit/bio_suit/cmo(src)
		new /obj/item/clothing/head/bio_hood/cmo(src)
		new /obj/item/clothing/under/rank/chief_medical_officer(src)
		new /obj/item/clothing/suit/labcoat/cmo(src)
		new /obj/item/weapon/cartridge/cmo(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/shoes/brown	(src)
		new /obj/item/device/radio/headset/heads/cmo(src)
		new /obj/item/weapon/storage/belt/medical(src)
		new /obj/item/device/flash(src)
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
	icon_off = "medicaloff"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/pillbottlebox(src)
		new /obj/item/weapon/storage/pillbottlebox(src)
		return