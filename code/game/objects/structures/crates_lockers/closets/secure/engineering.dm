/obj/structure/closet/secure_closet/engineering_chief
	name = "\proper chief engineer's locker"
	req_access = list(access_ce)
	icon_state = "ce"

/obj/structure/closet/secure_closet/engineering_chief/New()
	..()
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/under/rank/chief_engineer(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/tank/jetpack/suit(src)
	new /obj/item/weapon/cartridge/ce(src)
	new /obj/item/device/radio/headset/heads/ce(src)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/device/megaphone/command(src)
	new /obj/item/areaeditor/blueprints(src)
	new /obj/item/weapon/airlock_painter(src)
	new /obj/item/weapon/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/weapon/door_remote/chief_engineer(src)
	new /obj/item/weapon/pipe_dispenser(src)

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(access_engine_equip)
	icon_state = "eng"
	icon_door = "eng_elec"

/obj/structure/closet/secure_closet/engineering_electrical/New()
	..()
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/storage/toolbox/electrical(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/electronics/apc(src)
	for(var/i in 1 to 3)
		new /obj/item/device/multitool(src)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(access_engine_equip)
	icon_state = "eng"
	icon_door = "eng_weld"

/obj/structure/closet/secure_closet/engineering_welding/New()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/welding(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/weldingtool/largetank(src)

/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(access_engine_equip)
	icon_state = "eng_secure"

/obj/structure/closet/secure_closet/engineering_personal/New()
	..()
	new /obj/item/device/radio/headset/headset_eng(src)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/weapon/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/weapon/storage/box/emptysandbags(src)


/obj/structure/closet/secure_closet/atmospherics
	name = "\proper atmospheric technician's locker"
	req_access = list(access_atmospherics)
	icon_state = "atmos"

/obj/structure/closet/secure_closet/atmospherics/New()
	..()
	new /obj/item/device/radio/headset/headset_eng(src)
	new /obj/item/weapon/pipe_dispenser(src)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/weapon/holosign_creator/engineering(src)
	new /obj/item/weapon/watertank/atmos(src)
	new /obj/item/clothing/suit/fire/atmos(src)
	new /obj/item/clothing/head/hardhat/atmos(src)
	new /obj/item/clothing/glasses/meson/engine/tray(src)
