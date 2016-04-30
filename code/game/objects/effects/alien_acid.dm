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
	unacidable = 1
	var/atom/target
	var/ticks = 0
	var/target_strength = 0


/obj/effect/acid/New(loc, targ)
	..(loc)
	target = targ

	//handle APCs and newscasters and stuff nicely
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y

	if(isturf(target))	//Turfs take twice as long to take down.
		target_strength = 640
	else
		target_strength = 320
	tick()


/obj/effect/acid/proc/tick()
	if(!target)
		qdel(src)

	ticks++

	if(ticks >= target_strength)
		target.visible_message("<span class='warning'>[target] collapses under its own weight into a puddle of goop and undigested debris!</span>")

		if(istype(target, /obj/structure/closet))
			var/obj/structure/closet/T = target
			T.dump_contents()
			qdel(target)

		if(istype(target, /turf/closed/mineral))
			var/turf/closed/mineral/M = target
			M.ChangeTurf(M.baseturf)

		if(istype(target, /turf/open/floor))
			var/turf/open/floor/F = target
			F.ChangeTurf(F.baseturf)

		if(istype(target, /turf/closed/wall))
			var/turf/closed/wall/W = target
			W.dismantle_wall(1)

		else
			qdel(target)

		qdel(src)
		return

	x = target.x
	y = target.y
	z = target.z

	switch(target_strength - ticks)
		if(480)
			visible_message("<span class='warning'>[target] is holding up against the acid!</span>")
		if(320)
			visible_message("<span class='warning'>[target] is being melted by the acid!</span>")
		if(160)
			visible_message("<span class='warning'>[target] is struggling to withstand the acid!</span>")
		if(80)
			visible_message("<span class='warning'>[target] begins to crumble under the acid!</span>")

	spawn(1)
		if(src)
			tick()
