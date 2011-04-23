/obj/secure_closet/engineering_chief/New()
	..()
	sleep(2)
	new /obj/item/blueprints( src )
	new /obj/item/device/radio/headset/heads/ce( src )
	new /obj/item/clothing/under/rank/chief_engineer( src )
	new /obj/item/clothing/gloves/yellow( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/weapon/storage/toolbox/mechanical( src )
	//new /obj/item/clothing/shoes/magboots( src ) Moved to RIG suit rack --errorage
	//new /obj/item/clothing/ears/earmuffs( src ) useless --errorage
	//new /obj/item/clothing/glasses/meson( src ) Moved to his desk --errorage
	//new /obj/item/clothing/suit/fire/firefighter( src )
	new /obj/item/clothing/suit/hazardvest( src )
	new /obj/item/clothing/mask/gas( src )
	new /obj/item/clothing/head/helmet/welding( src )
	new /obj/item/clothing/head/helmet/hardhat( src )
	new /obj/item/device/multitool( src )
	new /obj/item/device/flash( src )
	return

/obj/secure_closet/engineering_electrical/New()
	..()
	sleep(2)
	new /obj/item/clothing/gloves/yellow( src )
	new /obj/item/clothing/gloves/yellow( src )
	//new /obj/item/clothing/gloves/yellow( src ) --Part of DangerCon 2011, approved by Urist_McDorf, --Errorage
	new /obj/item/weapon/storage/toolbox/electrical( src )
	new /obj/item/weapon/storage/toolbox/electrical( src )
	new /obj/item/weapon/storage/toolbox/electrical( src )
	new /obj/item/device/multitool( src )
	new /obj/item/device/multitool( src )
	new /obj/item/device/multitool( src )
	return

/obj/secure_closet/engineering_welding/New()
	..()
	sleep(2)
	new /obj/item/clothing/head/helmet/welding( src )
	new /obj/item/clothing/head/helmet/welding( src )
	new /obj/item/clothing/head/helmet/welding( src )
	new /obj/item/weapon/weldingtool/largetank( src )
	new /obj/item/weapon/weldingtool/largetank( src )
	new /obj/item/weapon/weldingtool/largetank( src )
	return

/obj/secure_closet/engineering_personal/New()
	..()
	sleep(2)
	new /obj/item/weapon/storage/toolbox/mechanical( src )
	new /obj/item/device/radio/headset/headset_eng( src )
	new /obj/item/clothing/under/rank/engineer( src )
	new /obj/item/clothing/shoes/orange( src )
	new /obj/item/clothing/suit/hazardvest( src )
	new /obj/item/clothing/mask/gas( src )
	new /obj/item/clothing/head/helmet/hardhat( src )
	//new /obj/item/clothing/ears/earmuffs( src ) useless --errorage
	new /obj/item/clothing/glasses/meson( src )
	return