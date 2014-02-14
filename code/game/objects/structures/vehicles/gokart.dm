/obj/item/key/gokart
	name = "\improper Firebird key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "gokart_keys"

/obj/structure/stool/bed/chair/vehicle/gokart
	name = "\improper Go-Kart"
	desc = "Tiny car for tiny people."
	icon_state = "gokart0"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/gokart

/obj/structure/stool/bed/chair/vehicle/gokart/buckle_mob(mob/M, mob/user)
	..(M,user)
	update_icon()

/obj/structure/stool/bed/chair/vehicle/gokart/unbuckle()
	..()
	update_icon()

/obj/structure/stool/bed/chair/vehicle/gokart/update_icon()
	icon_state="gokart[!isnull(buckled_mob)]"