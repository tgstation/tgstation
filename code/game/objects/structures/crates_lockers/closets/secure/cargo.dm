/obj/structure/closet/secure_closet/quartermaster
	name = "quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	..()
	new /obj/item/storage/lockbox/medal/cargo(src)
	new /obj/item/radio/headset/heads/qm(src)
	new /obj/item/megaphone/cargo(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/universal_scanner(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/circuitboard/machine/techfab/department/cargo(src)
	new /obj/item/storage/photo_album/qm(src)
	new /obj/item/circuitboard/machine/ore_silo(src)
	new /obj/item/storage/bag/garment/quartermaster(src)

/obj/structure/closet/secure_closet/quartermaster/populate_contents_immediate()
	. = ..()

	// Traitor steal objective
	new /obj/item/card/id/departmental_budget/car(src)
	new /obj/item/gun/ballistic/rifle/boltaction/brand_new/quartermaster(src) // MONKESTATION EDIT - The QM's 'special' head item. It spawns loaded, but you have to find more ammo if you run out and get ready to manually load rounds in!
	new /obj/item/cargo_teleporter(src) // MONKESTATION EDIT - Adds a cargo teleporter to QM locker, so they can intice others to research it
	new /obj/item/clothing/glasses/hud/gun_permit(src) //MONKESTATION EDIT - GUN CARGO
