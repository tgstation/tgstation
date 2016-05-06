/obj/structure/bed/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/on = 1
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1.0
	var/datum/effect/effect/system/spark_spread/spark_system

/obj/structure/bed/chair/e_chair/New()
	..()
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)
	spark_system = new
	spark_system.set_up(12, 0, src)
	spark_system.attach(src)

/obj/structure/bed/chair/e_chair/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/structure/bed/chair/e_chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		var/obj/structure/bed/chair/C = new /obj/structure/bed/chair(loc)
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		C.dir = dir
		part.forceMove(loc)
		part.master = null
		part = null
		qdel(src)

/obj/structure/bed/chair/e_chair/verb/toggle()
	set name = "Toggle Electric Chair"
	set category = "Object"
	set src in oview(1)

	if(on)
		on = 0
		icon_state = "echair0"
	else
		on = 1
		icon_state = "echair1"
	to_chat(usr, "<span class='notice'>You switch [on ? "on" : "off"] [src].</span>")
	return

/obj/structure/bed/chair/e_chair/rotate()
	..()
	overlays.len = 0
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)	//there's probably a better way of handling this, but eh. -Pete
	return

/obj/structure/bed/chair/e_chair/proc/shock()
	if(!on)
		return
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	if(locked_atoms.len)
		A.use_power(EQUIP, 5000)
		var/light = A.power_light
		A.updateicon()

		flick("echair1", src)

		var/mob/living/M = locked_atoms[1]
		M.Stun(60)
		M.Jitter(60)
		visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='danger'>You hear a deep sharp shock!</span>")
		for(var/i=1;i<=5;i++)
			if(M && M.locked_to == src)
				M.burn_skin(34)
				to_chat(M, "<span class='danger'>You feel a deep shock course through your body!</span>")
			spark_system.start()
			sleep(10)

		A.power_light = light
		A.updateicon()
	else
		spark_system.start() //just something to let them know it works
	return
