/obj/structure/secure_closet/engineering_chief
	name = "Chief Engineer's Locker"
	req_access = list(access_ce)


	New()
		..()
		sleep(2)
		new /obj/item/blueprints(src)
		new /obj/item/clothing/under/rank/chief_engineer(src)
		new /obj/item/clothing/suit/hazardvest(src)
		new /obj/item/clothing/head/helmet/hardhat/white(src)
		new /obj/item/clothing/head/helmet/welding(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/device/radio/headset/heads/ce(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/flash(src)
		return



/obj/structure/secure_closet/engineering_electrical
	name = "Electrical Supplies"
	req_access = list(access_engine)


	New()
		..()
		sleep(2)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/multitool(src)
		return



/obj/structure/secure_closet/engineering_welding
	name = "Welding Supplies"
	req_access = list(access_engine)


	New()
		..()
		sleep(2)
		new /obj/item/clothing/head/helmet/welding(src)
		new /obj/item/clothing/head/helmet/welding(src)
		new /obj/item/clothing/head/helmet/welding(src)
		new /obj/item/weapon/weldingtool/largetank(src)
		new /obj/item/weapon/weldingtool/largetank(src)
		new /obj/item/weapon/weldingtool/largetank(src)
		return



/obj/structure/secure_closet/engineering_personal
	name = "Engineer's Locker"
	req_access = list(access_engine)


	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/engineer(src)
		new /obj/item/clothing/suit/hazardvest(src)
		new /obj/item/clothing/shoes/orange(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/glasses/meson(src)
		return
