/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/device/electropack/part2 = null
	w_class = WEIGHT_CLASS_HUGE
	flags = CONDUCT

/obj/item/assembly/shock_kit/Destroy()
	qdel(part1)
	qdel(part2)
	return ..()

/obj/item/assembly/shock_kit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		var/turf/T = loc
		if(ismob(T))
			T = T.loc
		part1.loc = T
		part2.loc = T
		part1.master = null
		part2.master = null
		part1 = null
		part2 = null
		qdel(src)
		return
	add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/attack_self(mob/user)
	part1.attack_self(user)
	part2.attack_self(user)
	add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/receive_signal()
	if(istype(loc, /obj/structure/chair/e_chair))
		var/obj/structure/chair/e_chair/C = loc
		C.shock()
	return
