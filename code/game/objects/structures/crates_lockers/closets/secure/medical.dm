<<<<<<< HEAD
/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled to the brim with medical junk."
	icon_state = "med"
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical1/New()
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
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/medical2/New()
	..()
	for(var/i in 1 to 3)
		new /obj/item/weapon/tank/internals/anesthetic(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(access_surgery)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medical3/New()
	..()
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/weapon/defibrillator/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/weapon/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	return

/obj/structure/closet/secure_closet/CMO
	name = "\proper chief medical officer's locker"
	req_access = list(access_cmo)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/CMO/New()
	..()
	new /obj/item/clothing/suit/cloak/cmo(src)
	new /obj/item/weapon/storage/backpack/dufflebag/med(src)
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
	new /obj/item/device/autoimplanter/cmo(src)
	new /obj/item/weapon/door_remote/chief_medical_officer(src)

/obj/structure/closet/secure_closet/animal
	name = "animal control"
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/animal/New()
	..()
	new /obj/item/device/assembly/signaler(src)
	for(var/i in 1 to 3)
		new /obj/item/device/electropack(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	icon_door = "chemical"

/obj/structure/closet/secure_closet/chemical/New()
	..()
	new /obj/item/weapon/storage/box/pillbottles(src)
	new /obj/item/weapon/storage/box/pillbottles(src)
=======
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
		new /obj/item/weapon/storage/box/syringes(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
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
	req_access = list(access_surgery)


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
	req_access = list(access_surgery)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/monkeyclothes/doctor (src)
		new /obj/item/clothing/monkeyclothes/doctor (src)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/clothing/under/rank/nursesuit (src)
		new /obj/item/clothing/head/nursehat (src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)
		new /obj/item/clothing/under/rank/medical(src)
		new /obj/item/clothing/under/rank/nurse(src)
		new /obj/item/clothing/under/rank/orderly(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/suit/storage/fr_jacket(src)
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
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/clothing/suit/bio_suit/cmo(src)
		new /obj/item/clothing/head/bio_hood/cmo(src)
		new /obj/item/clothing/shoes/white(src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)
		new /obj/item/clothing/under/rank/chief_medical_officer(src)
		new /obj/item/clothing/suit/storage/labcoat/cmo(src)
		new /obj/item/weapon/cartridge/cmo(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/shoes/brown	(src)
		new /obj/item/device/radio/headset/heads/cmo(src)
		new /obj/item/weapon/storage/belt/medical(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/reagent_containers/hypospray(src)
		return



/obj/structure/closet/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_surgery)


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
	req_access = list(access_chemistry)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/box/pillbottles(src)
		new /obj/item/weapon/storage/box/pillbottles(src)
		return

/obj/structure/closet/secure_closet/medical_wall
	name = "First Aid Closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	anchored = 1
	density = 0
	wall_mounted = 1
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical_wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/paramedic
	name = "Paramedic EVA gear"
	desc = "A locker with a Paramedic EVA suit."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_paramedic)


	New()
		..()
		sleep(2)
		new /obj/item/clothing/suit/space/paramedic(src)
		new /obj/item/clothing/head/helmet/space/paramedic(src)
		new /obj/item/clothing/shoes/magboots(src)
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
