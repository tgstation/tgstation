/obj/item/device/doorCharge
	name = "airlock charge"
	desc = null //Different examine for traitors
	item_state = "electronic"
	icon_state = "doorCharge"
	w_class = WEIGHT_CLASS_SMALL
	throw_range = 4
	throw_speed = 1
	flags = NOBLUDGEON
	force = 3
	attack_verb = list("blown up", "exploded", "detonated")
	materials = list(MAT_METAL=50, MAT_GLASS=30)
	origin_tech = "syndicate=1;combat=3;engineering=3"

/obj/item/device/doorCharge/ex_act(severity, target)
	switch(severity)
		if(1)
			Detonate()
		if(2)
			if(prob(50))
				Detonate()
		if(3)
			if(prob(25))
				Detonate()

/obj/item/device/doorCharge/proc/Detonate()
	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>[src] detonates!</span>")
	explosion(T, 0, 1, 0)
	for(var/mob/living/carbon/human/H in orange(2, T))
		H.Weaken(8)
		H.apply_damage(40, BRUTE)
		H.apply_damage(30, BURN)
	qdel(src)

/obj/item/device/doorCharge/Destroy()
	if(istype(loc, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = loc
		if(A.charge == src)
			A.charge = null
	return ..()

/obj/item/device/doorCharge/examine(mob/user)
	..()
	if(user.mind in SSticker.mode.traitors) //No nuke ops because the device is excluded from nuclear
		to_chat(user, "A small explosive device that can be used to sabotage airlocks to cause an explosion upon opening. To apply, remove the airlock's maintenance panel and place it within.")
	else
		to_chat(user, "A small, suspicious object that feels lukewarm when held.")
