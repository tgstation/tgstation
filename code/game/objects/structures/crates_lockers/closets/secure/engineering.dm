/obj/structure/closet/secure_closet/engineering_chief
	name = "chief engineer's locker"
	req_access = list(ACCESS_CE)
	icon_state = "ce"

/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()

	new /obj/item/storage/bag/garment/engineering_chief (src)
	new /obj/item/computer_disk/command/ce(src)
	new /obj/item/radio/headset/heads/ce(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/door_remote/chief_engineer(src)
	new /obj/item/storage/lockbox/medal/engineering(src)
	new /obj/item/circuitboard/machine/techfab/department/engineering(src)
	new /obj/item/extinguisher/advanced(src)
	new /obj/item/storage/photo_album/ce(src)
	new /obj/item/storage/box/skillchips/engineering(src)
	new /obj/item/storage/box/stickers/chief_engineer(src)

/obj/structure/closet/secure_closet/engineering_chief/populate_contents_immediate()
	. = ..()

	// Traitor steal objective
	new /obj/item/blueprints(src)
	new /obj/item/pipe_dispenser(src)

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_elec"

/obj/structure/closet/secure_closet/engineering_electrical/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/inducer = 2,
		/obj/item/storage/toolbox/electrical = 3,
		/obj/item/electronics/apc = 3,
		/obj/item/multitool = 3)
	generate_items_inside(items_inside,src)

/obj/structure/closet/secure_closet/engineering_electrical/populate_contents_immediate()
	. = ..()

	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/gloves/color/yellow(src)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_weld"

/obj/structure/closet/secure_closet/engineering_welding/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/utility/welding(src)
	for(var/i in 1 to 3)
		new /obj/item/weldingtool(src)

/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng_secure"

/obj/structure/closet/secure_closet/engineering_personal/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/storage/bag/construction(src)


/obj/structure/closet/secure_closet/atmospherics
	name = "atmospheric technician's locker"
	req_access = list(ACCESS_ATMOSPHERICS)
	icon_state = "atmos"

/obj/structure/closet/secure_closet/atmospherics/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_eng(src)

	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/watertank/atmos(src)
	new /obj/item/clothing/suit/utility/fire/atmos(src)
	new /obj/item/clothing/gloves/atmos(src)
	new /obj/item/clothing/mask/gas/atmos(src)
	new /obj/item/clothing/head/utility/hardhat/welding/atmos(src)
	new /obj/item/clothing/glasses/meson/engine/tray(src)
	new /obj/item/extinguisher/advanced(src)

/obj/structure/closet/secure_closet/atmospherics/populate_contents_immediate()
	. = ..()

	new /obj/item/pipe_dispenser(src)
