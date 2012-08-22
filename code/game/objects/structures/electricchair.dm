/obj/structure/stool/bed/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/on = 0
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1.0

/obj/structure/stool/bed/chair/e_chair/New()
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)
	return

/obj/structure/stool/bed/chair/e_chair/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/wrench))
		var/obj/structure/stool/bed/chair/C = new /obj/structure/stool/bed/chair(src.loc)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		C.dir = src.dir
		src.part.loc = src.loc
		src.part.master = null
		src.part = null
		del(src)
		return
	return

/obj/structure/stool/bed/chair/e_chair/verb/toggle()
	set name = "Toggle Electric Chair"
	set category = "Object"
	set src in oview(1)

	if(on)
		on = 0
		icon_state = "echair0"
	else
		on = 1
		icon_state = "echair1"
	return

/obj/structure/stool/bed/chair/e_chair/rotate()
	..()
	overlays = null
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)	//there's probably a better way of handling this, but eh. -Pete
	return

/obj/structure/stool/bed/chair/e_chair/proc/shock()
	if(!(src.on))
		return
	if((src.last_time + 50) > world.time)
		return
	src.last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	A.use_power(EQUIP, 5000)
	var/light = A.power_light
	A.updateicon()

	flick("echair1", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(12, 1, src)
	s.start()
	if(buckled_mob)
		buckled_mob.burn_skin(85)
		buckled_mob << "\red <B>You feel a deep shock course through your body!</B>"
		sleep(1)
		buckled_mob.burn_skin(85)
		buckled_mob.Stun(600)
	for(var/mob/M in hearers(src, null))
		M.show_message("\red The electric chair went off!.", 3, "\red You hear a deep sharp shock.", 2)

	A.power_light = light
	A.updateicon()
	return