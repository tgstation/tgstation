/obj/structure/closet/secure_closet/engineering_chief
	name = "\proper chief engineer's locker"
	req_access = list(access_ce)
	icon_state = "securece1"
	icon_closed = "securece"
	icon_locked = "securece1"
	icon_opened = "secureceopen"
	icon_broken = "securecebroken"
	icon_off = "secureceoff"


/obj/structure/closet/secure_closet/engineering_chief/New()
	..()
	sleep(2)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/areaeditor/blueprints(src)
	new /obj/item/weapon/storage/box/permits(src)
	new /obj/item/clothing/under/rank/chief_engineer(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/cartridge/ce(src)
	new /obj/item/device/radio/headset/heads/ce(src)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/weapon/airlock_painter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/flash/handheld(src)
	return

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(access_engine_equip)
	icon_state = "secureengelec1"
	icon_closed = "secureengelec"
	icon_locked = "secureengelec1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengelecbroken"
	icon_off = "secureengelecoff"


/obj/structure/closet/secure_closet/engineering_electrical/New()
	..()
	sleep(2)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/weapon/storage/toolbox/electrical(src)
	new /obj/item/weapon/storage/toolbox/electrical(src)
	new /obj/item/weapon/storage/toolbox/electrical(src)
	new /obj/item/weapon/module/power_control(src)
	new /obj/item/weapon/module/power_control(src)
	new /obj/item/weapon/module/power_control(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/multitool(src)
	return



/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(access_engine_equip)
	icon_state = "secureengweld1"
	icon_closed = "secureengweld"
	icon_locked = "secureengweld1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengweldbroken"
	icon_off = "secureengweldoff"


/obj/structure/closet/secure_closet/engineering_welding/New()
	..()
	sleep(2)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/weapon/weldingtool/largetank(src)
	new /obj/item/weapon/weldingtool/largetank(src)
	new /obj/item/weapon/weldingtool/largetank(src)
	return



/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(access_engine_equip)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"


/obj/structure/closet/secure_closet/engineering_personal/New()
	..()
	sleep(2)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/shoes/sneakers/orange(src)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
//	new /obj/item/weapon/cartridge/engineering(src)
	new /obj/item/device/radio/headset/headset_eng(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	return

/obj/structure/closet/secure_closet/atmospherics
	name = "\proper atmospheric technician's locker"
	req_access = list(access_atmospherics)
	icon_state = "secureatmos"
	icon_closed = "secureatmos"
	icon_locked = "secureatmos1"
	icon_opened = "secureatmosopen"
	icon_broken = "secureatmosbroken"
	icon_off = "secureatmosoff"


/obj/structure/closet/secure_closet/atmospherics/New()
	..()
	sleep(2)
	new /obj/item/device/radio/headset/headset_eng(src)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
	new /obj/item/weapon/storage/backpack/satchel_norm(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	new /obj/item/weapon/watertank/atmos(src)
	new /obj/item/clothing/suit/fire/atmos(src)
	new /obj/item/clothing/head/hardhat/atmos(src)
	return