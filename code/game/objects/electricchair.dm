/obj/structure/stool/bed/chair/e_chair
	name = "electrified chair"
	desc = "Looks absolutely terrifying!"
	icon_state = "e_chair0"
	var/atom/movable/overlay/overl = null
	var/on = 0.0
	var/obj/item/assembly/shock_kit/part1 = null
	var/isshocking
	var/datum/effect/effect/system/spark_spread/spark = new /datum/effect/effect/system/spark_spread
	var/list/mob/living/affected = list()

/obj/structure/stool/bed/chair/e_chair/New()

	src.overl = new /atom/movable/overlay( src.loc )
	src.overl.icon = 'objects.dmi'
	src.overl.icon_state = "e_chairo0"
	src.overl.layer = 5
	src.overl.name = "electrified chair"
	src.overl.master = src
	spark.set_up(12, 1, src)
	return

/obj/structure/stool/bed/chair/e_chair/Del()

	//src.overl = null
	del(src.overl)
	..()
	return

/obj/structure/stool/bed/chair/e_chair/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/wrench))
		var/obj/structure/stool/bed/chair/C = new /obj/structure/stool/bed/chair( src.loc )
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		C.dir = src.dir
		src.part1.loc = src.loc
		src.part1.master = null
		src.part1 = null
		//SN src = null
		del(src)
		return
	if(istype(W, /obj/item/device/assembly/signaler))
		var/obj/item/assembly/shock_kit/kit = src.part1
		var/obj/item/device/radio/electropack/target = kit.part2
		var/obj/item/device/assembly/signaler/S = W
		target.set_frequency(S.frequency)
		target.code = S.code
		for(var/mob/M in viewers(src, null))
			M.show_message("\red [user] has set the electric chair using the [W].")
	return

/obj/structure/stool/bed/chair/e_chair/verb/toggle_power()
	set name = "Toggle Electric Chair"
	set category = "Object"
	set src in oview(1)

	if ((usr.stat || usr.restrained() || !( usr.canmove ) || usr.lying))
		return
	if(isshocking && on)
		shock()
	src.on = !( src.on )
	src.icon_state = text("e_chair[]", src.on)
	src.overl.icon_state = text("e_chairo[]", src.on)
	return

/obj/structure/stool/bed/chair/e_chair/rotate()
	..()
	overlays = null
	overlays += image('objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)	//there's probably a better way of handling this, but eh. -Pete
	return

/obj/structure/stool/bed/chair/e_chair/proc/shock()
	if (!( src.on ))
		return
	if(isshocking)
		processing_objects.Remove(src)
		src.icon_state = text("e_chair[]", src.on)
		src.overl.icon_state = text("e_chairo[]", src.on)
		for(var/mob/living/M in affected)
			M.jitteriness = 0
			M.is_jittery = 0
			M.anchored = 0
			affected.Remove(M)
		isshocking = 0
		return
	else
		src.icon_state = "e_chairs"
		src.overl.icon_state = "e_chairos"
		spark.start()
		for(var/mob/M in hearers(src, null))
			M.show_message("\red The electric chair went off!.", 3, "\red You hear a deep sharp shock.", 2)
		processing_objects.Add(src)
		isshocking = 1
		return

/obj/structure/stool/bed/chair/e_chair/process()
	// special power handling
	var/area/A = get_area(src)
	if(isarea(A) && A.powered(EQUIP))
		A.use_power(EQUIP, 5000)
	for(var/mob/living/M in src.loc)
		affected.Add(M)
		M.make_jittery(1000)
		M.anchored = 1
		M.Stun(600)
		M.burn_skin(10)
		spark.start()