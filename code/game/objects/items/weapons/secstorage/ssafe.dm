/obj/item/weapon/secstorage/ssafe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	flags = FPRINT | TABLEPASS
	force = 8.0
	w_class = 8.0
	internalstorage = 8
	anchored = 1.0
	density = 0

/obj/item/weapon/secstorage/ssafe/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/secstorage/ssafe/HoS/New()
	..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)

/obj/item/weapon/secstorage/ssafe/attack_hand(mob/user as mob)
	return attack_self(user)