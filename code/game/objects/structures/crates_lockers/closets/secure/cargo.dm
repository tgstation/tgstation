/obj/structure/closet/secure_closet/quartermaster
	name = "quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	..()
	new /obj/item/storage/bag/garment/quartermaster(src)
	new /obj/item/storage/lockbox/medal/cargo(src)
	new /obj/item/storage/toolbox/quartermaster(src)

/obj/structure/closet/secure_closet/quartermaster/populate_contents_immediate()
	. = ..()

	// Traitor steal objective
	new /obj/item/card/id/departmental_budget/car(src)
