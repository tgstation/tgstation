/obj/item/assembly/shock_kit
	name = "Shock Kit"
	desc = "This appears to be made from both an Electric Pack and a Helmet."
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/device/radio/electropack/part2 = null
	var/status = 0.0
	w_class = 5.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/shock_kit/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/assembly/shock_kit/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (!src.status)
		user.show_message("\blue The shock pack is now secured!", 1)
	else
		user.show_message("\blue The shock pack is now unsecured!", 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/receive_signal()
	//*****
	//world << "Shock kit got r_signal"
	if (istype(src.loc, /obj/structure/stool/bed/chair/e_chair))
		var/obj/structure/stool/bed/chair/e_chair/C = src.loc
		//world << "Shock kit sending shock to EC"
		C.shock()
	return
