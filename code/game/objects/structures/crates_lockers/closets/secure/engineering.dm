/obj/structure/closet/secure_closet/engineering_chief
	name = "Chief Engineer's Locker"
	req_access = list(access_ce)
	icon_state = "securece1"
	icon_closed = "securece"
	icon_locked = "securece1"
	icon_opened = "secureceopen"
	icon_broken = "securecebroken"
	icon_off = "secureceoff"


	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/industrial(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_eng(src)
		new /obj/item/blueprints(src)
		new /obj/item/clothing/under/rank/chief_engineer(src)
		new /obj/item/clothing/head/hardhat/white(src)
		new /obj/item/clothing/head/welding(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/weapon/cartridge/ce(src)
		new /obj/item/device/radio/headset/heads/ce(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/device/t_scanner/advanced(src)
		new /obj/item/device/device_analyser/advanced(src)
		new /obj/item/clothing/suit/storage/hazardvest(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/gps/engineering(src)
		new /obj/item/weapon/storage/belt/utility/chief(src)
		new /obj/item/clothing/glasses/scanner/material(src)
		return



/obj/structure/closet/secure_closet/engineering_electrical
	name = "Electrical Supplies"
	req_access = list(access_engine_equip)
	icon_state = "secureengelec1"
	icon_closed = "secureengelec"
	icon_locked = "secureengelec1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengelecbroken"
	icon_off = "secureengelecoff"


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/rcl(src)
		new /obj/item/weapon/circuitboard/power_control(src)
		new /obj/item/weapon/circuitboard/power_control(src)
		new /obj/item/weapon/circuitboard/power_control(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/multitool(src)
		return



/obj/structure/closet/secure_closet/engineering_welding
	name = "Welding Supplies"
	req_access = list(access_engine_equip)
	icon_state = "secureengweld1"
	icon_closed = "secureengweld"
	icon_locked = "secureengweld1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengweldbroken"
	icon_off = "secureengweldoff"


	New()
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
	name = "Engineer's Locker"
	req_access = list(access_engine_equip)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"


	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/industrial(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_eng(src)
		new /obj/item/clothing/under/rank/engineer(src)
		new /obj/item/clothing/shoes/orange(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
//		new /obj/item/weapon/cartridge/engineering(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/clothing/suit/storage/hazardvest(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/glasses/scanner/meson(src)
		new /obj/item/taperoll/engineering(src)
		new /obj/item/taperoll/engineering(src)
		new /obj/item/device/gps/engineering(src)
		new /obj/item/clothing/glasses/scanner/material(src)
		return

/obj/structure/closet/secure_closet/engineering_atmos
	name = "Atmospheric Technician's Locker"
	req_access = list(access_atmospherics)
	icon_state = "secureatmos1"
	icon_closed = "secureatmos"
	icon_locked = "secureatmos1"
	icon_opened = "secureatmosopen"
	icon_broken = "secureatmosbroken"
	icon_off = "secureatmosoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_norm(src)
		new /obj/item/clothing/under/rank/atmospheric_technician(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/weapon/extinguisher/foam(src)
		// new /obj/item/weapon/cartridge/engineering(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/clothing/suit/storage/hazardvest(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/taperoll/atmos(src)
		new /obj/item/pipe_planner(src)
		new /obj/item/weapon/wrench/socket(src)
		new /obj/item/weapon/gun/projectile/flare(src) //yay for emergency lighting
		new /obj/item/ammo_storage/box/flare(src)
		new /obj/item/device/rcd/rpd(src)
		new /obj/item/device/analyzer(src)
		new /obj/item/clothing/glasses/scanner/material(src)
		return

/obj/structure/closet/secure_closet/engineering_mechanic
	name = "Mechanic's Locker"
	req_access = list(access_mechanic)
	icon_state = "securemechni1"
	icon_closed = "securemechni"
	icon_locked = "securemechni1"
	icon_opened = "securemechniopen"
	icon_broken = "securemechnibroken"
	icon_off = "securemechnioff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/industrial(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_eng(src)
		new /obj/item/clothing/under/rank/mechanic(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		//new /obj/item/device/component_exchanger(src)
		new /obj/item/device/radio/headset/headset_engsci(src)
		new /obj/item/clothing/suit/storage/hazardvest(src)
		new /obj/item/device/device_analyser(src)
		new /obj/item/weapon/soap/nanotrasen(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/device/assembly_frame(src)
		new /obj/item/device/assembly_frame(src)

		if(prob(50))
			new /obj/item/clothing/head/welding(src)
		else
			new /obj/item/clothing/glasses/welding(src)
		return

/obj/structure/closet/secure_closet/engineering_general
	name = "Engineering Locker"
	req_access = list(access_engine_equip)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"


/obj/structure/closet/crate/secure/large/reinforced/shard
	name = "Supermatter Shard Crate"
	New()
		..()
		sleep(2)
		new /obj/machinery/power/supermatter/shard(src)

/obj/structure/closet/crate/secure/large/reinforced/shard/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/machinery/power/supermatter))
		return 1
	. = ..()

/obj/structure/closet/crate/secure/large/reinforced/shard/can_close()
	for(var/obj/machinery/power/supermatter/S in loc)
		if(S.damage) //This is what I like to call predicting the metagame
			return 0
	return ..()
