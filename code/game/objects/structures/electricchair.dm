/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "echair0"
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1
	item_chair = null

/obj/structure/chair/e_chair/New()
	..()
	add_overlay(image('icons/obj/chairs.dmi', src, "echair_over", MOB_LAYER + 1))

/obj/structure/chair/e_chair/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		var/obj/structure/chair/C = new /obj/structure/chair(loc)
		playsound(loc, W.usesound, 50, 1)
		C.setDir(dir)
		part.loc = loc
		part.master = null
		part = null
		qdel(src)

/obj/structure/chair/e_chair/proc/shock()
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	A.use_power(EQUIP, 5000)

	flick("echair_shock", src)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(12, 1, src)
	s.start()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act(85, src, 1)
			to_chat(buckled_mob, "<span class='userdanger'>You feel a deep shock course through your body!</span>")
			spawn(1)
				buckled_mob.electrocute_act(85, src, 1)
	visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='italics'>You hear a deep sharp shock!</span>")
