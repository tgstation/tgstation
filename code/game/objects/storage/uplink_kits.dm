/obj/item/weapon/storage/syndie_kit
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/syndie_kit/imp_freedom
	name = "box (FI)"

/obj/item/weapon/storage/syndie_kit/imp_freedom/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()
	..()
	return

/obj/item/weapon/storage/syndie_kit/imp_compress
	name = "box (CMI)"

/obj/item/weapon/storage/syndie_kit/imp_compress/New()
	new /obj/item/weapon/implanter/compressed(src)
	..()
	return

/obj/item/weapon/storage/syndie_kit/imp_explosive
	name = "box (EI)"

/obj/item/weapon/storage/syndie_kit/imp_explosive/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/explosive(O)
//	O.name = "(BIO-HAZARD) BIO-detpack"
	O.update()
	..()
	return

/obj/item/weapon/storage/syndie_kit/imp_uplink
	name = "box (UI)"

/obj/item/weapon/storage/syndie_kit/imp_uplink/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update()
	..()
	return

/obj/item/weapon/storage/syndie_kit/space
	name = "box (SS)"

/obj/item/weapon/storage/syndie_kit/space/New()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	..()
	return