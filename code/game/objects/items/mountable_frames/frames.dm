/obj/item/mounted/frame
	name = "mountable frame"
	desc = "Place it on a wall."
	flags = FPRINT | TABLEPASS| CONDUCT
	w_type=RECYK_METAL
	var/sheets_refunded = 2

/obj/item/mounted/frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench) && sheets_refunded)
		new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
		qdel(src)