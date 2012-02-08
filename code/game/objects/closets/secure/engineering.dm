/obj/structure/closet/secure_closet/engineering_chief
	name = "Chief Engineer's Locker"
	req_access = list(access_ce)


	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chief_engineer(src)
		new /obj/item/blueprints(src)
		//
		var/obj/item/weapon/storage/backpack/industrial/BPK = new /obj/item/weapon/storage/backpack/industrial(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/heads/ce(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/head/helmet/hardhat/white(src)
		new /obj/item/clothing/head/helmet/welding(src)
		new /obj/item/weapon/storage/belt/utility/full(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/suit/hazardvest(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/device/radio/headset/heads/ce(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/under/rank/chief_engineer(src)
		return



/obj/structure/closet/secure_closet/engineering_electrical
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



/obj/structure/closet/secure_closet/engineering_welding
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

/obj/structure/closet/secure_closet/engineering_personal
	name = "Engineer's Locker"
	req_access = list(access_engine)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/engineer(src)
		//
		var/obj/item/weapon/storage/backpack/industrial/BPK = new /obj/item/weapon/storage/backpack/industrial(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/engineering(src)
		new /obj/item/device/t_scanner(src)
		new /obj/item/clothing/suit/hazardvest(src)
		new /obj/item/weapon/storage/belt/utility/full(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/head/helmet/hardhat(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/clothing/shoes/orange(src)
		new /obj/item/clothing/under/rank/engineer(src)
		return

/obj/structure/closet/secure_closet/atmos_personal
	name = "Atmospheric Technician's Locker"
	req_access = list(access_atmospherics)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/atmos(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/engineering(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/device/radio/headset/headset_eng(src)

/obj/structure/closet/secure_closet/roboticist_personal
	name = "Roboticist's Locker"
	req_access = list(access_robotics)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/roboticist(src)
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/engineering(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/device/radio/headset/headset_eng(src)
