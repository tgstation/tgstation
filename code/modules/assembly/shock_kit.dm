/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/device/radio/electropack/part2 = null
	w_class = W_CLASS_HUGE
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/assembly/shock_kit/Destroy()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

/obj/item/assembly/shock_kit/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		var/turf/T = loc
		if(ismob(T))
			T = T.loc
		part1.forceMove(T)
		part2.forceMove(T)
		part1.master = null
		part2.master = null
		part1 = null
		part2 = null
		qdel(src)
		return
	add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/attack_self(mob/user as mob)
	part1.attack_self(user)
	part2.attack_self(user)
	add_fingerprint(user)
	return

//I guess at some point, this shock kit thing was meant to be an /obj/item/DEVICE/assembly/ with it's own radio_frequency datum,
//but honestly I think just using the electropack for the whole signal-receiving thing works out much better.
//This proc never ever gets called unless the electropack calls it directly, see electropack.dm
/obj/item/assembly/shock_kit/receive_signal()
	if(istype(loc, /obj/structure/bed/chair/e_chair))
		var/obj/structure/bed/chair/e_chair/C = loc
		C.shock()
	return
