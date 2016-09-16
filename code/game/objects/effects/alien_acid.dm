/* Alien shit!
 * Contains:
 *		effect/acid
 */


/*
 * Acid
 */
/obj/effect/acid
	gender = PLURAL
	name = "acid"
	desc = "Burbling corrossive stuff."
	icon_state = "acid"
	density = 0
	opacity = 0
	anchored = 1
	acid_state = UNACIDABLE
	var/acid_type = "alienacid"
	var/turf/target
	var/target_strength = 60 //phil235 roughly 1 minute for alien acid on wall, if 1 process per second


/obj/effect/acid/New(loc, acid_pwr, acid_amt, acid_id)
	..(loc)

	target = get_turf(src)

	if(acid_id)
		acid_type = acid_id

	if(acid_amt)
		acid_level = min(acid_amt*acid_pwr, 12000)

	//handle APCs and newscasters and stuff nicely
	pixel_x = target.pixel_x + rand(-4,4)
	pixel_y = target.pixel_y + rand(-4,4)

	START_PROCESSING(SSobj, src)


/obj/effect/acid/Destroy()
	STOP_PROCESSING(SSobj, src)
	target = null
	return ..()

/obj/effect/acid/process()
	if(!target)
		qdel(src)

	if(acid_type == "alienacid") //only alien acid can melt turfs
		if(prob(50))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		target_strength--
		if(target_strength <= 0)
			target.visible_message("<span class='warning'>[target] collapses under its own weight into a puddle of goop and undigested debris!</span>")
			if(istype(target, /turf/closed/mineral))
				var/turf/closed/mineral/M = target
				M.ChangeTurf(M.baseturf)

			else if(istype(target, /turf/open/floor))
				var/turf/open/floor/F = target
				F.ChangeTurf(F.baseturf)

			else if(istype(target, /turf/closed/wall))
				var/turf/closed/wall/W = target
				W.dismantle_wall(1)
			qdel(src)
		else

			switch(target_strength)
				if(48)
					visible_message("<span class='warning'>[target] is holding up against the acid!</span>")
				if(32)
					visible_message("<span class='warning'>[target] is being melted by the acid!</span>")
				if(16)
					visible_message("<span class='warning'>[target] is struggling to withstand the acid!</span>")
				if(8)
					visible_message("<span class='warning'>[target] begins to crumble under the acid!</span>")
	else if(prob(5))
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	for(var/obj/O in target)
		if(prob(20) && O.acid_state != UNACIDABLE)
			if(O.acid_level < acid_level*0.3)
				var/acid_used = min(acid_level*0.05, 20)
				O.acid_act(10, acid_used)
				acid_level = max(0, acid_level - acid_used*10)

	acid_level = max(acid_level - (5 + 2*round(sqrt(acid_level))), 0)
	if(acid_level <= 0)
		STOP_PROCESSING(SSobj, src)
		qdel(src)

/obj/effect/acid/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.m_intent != "walk" && prob(40))
			var/acid_used = min(acid_level*0.05, 20)
			if(L.acid_act(10, acid_used, "feet"))
				acid_level = max(0, acid_level - acid_used*10)
				playsound(L, 'sound/weapons/sear.ogg', 50, 1)
				L << "<span class='userdanger'>[src] burns you!</span>"