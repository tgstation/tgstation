/obj/item/weapon/storage/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"
	item_state = "syringe_kit"

/obj/item/weapon/storage/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_freedom/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()
	..()
	return

/*/obj/item/weapon/storage/syndie_kit/imp_compress
	name = "Compressed Matter Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_compress/New()
	new /obj/item/weapon/implanter/compressed(src)
	..()
	return

/obj/item/weapon/storage/syndie_kit/imp_explosive
	name = "Explosive Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_explosive/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/explosive(O)
	O.name = "(BIO-HAZARD) BIO-detpack"
	O.update()
	..()
	return*/

/obj/item/weapon/storage/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_uplink/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update()
	..()
	return

/obj/item/weapon/storage/syndie_kit/space
	name = "Space Suit and Helmet"

/obj/item/weapon/storage/syndie_kit/space/New()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	..()
	return
