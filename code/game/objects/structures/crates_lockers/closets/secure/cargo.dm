/obj/structure/closet/secure_closet/quartermaster
	name = "quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	..()
	new /obj/item/storage/lockbox/medal/cargo(src)
///	new /obj/item/radio/headset/heads/qm(src) // monkestation edit - QM is not a head. They do not need a command headset.
	new /obj/item/megaphone/cargo(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/universal_scanner(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/circuitboard/machine/techfab/department/cargo(src)
	new /obj/item/storage/photo_album/qm(src)
	new /obj/item/circuitboard/machine/ore_silo(src)
	new /obj/item/storage/bag/garment/quartermaster(src)
	new /obj/item/encryptionkey/headset_cargo(src) // monkestation edit - An extra encryption key for someone joining Cargyptia
	new /obj/item/cargo_teleporter(src) // monkestation edit - singular roundstart cargo teleporter

/obj/structure/closet/secure_closet/quartermaster/populate_contents_immediate()
	. = ..()

	// Traitor steal objective
	new /obj/item/card/id/departmental_budget/car(src)
