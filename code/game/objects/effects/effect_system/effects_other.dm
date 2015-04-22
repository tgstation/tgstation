
/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/obj/effect/effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1.0

/datum/effect/effect/system/ion_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect/effect/system/ion_trail_follow/Destroy()
	oldposition = null
	return ..()

/datum/effect/effect/system/ion_trail_follow/set_up(atom/atom)
	attach(atom)


/datum/effect/effect/system/ion_trail_follow/start() //Whoever is responsible for this abomination of code should become an hero
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		var/turf/T = get_turf(src.holder)
		if(T != src.oldposition)
			if(!has_gravity(T))
				var/obj/effect/effect/ion_trails/I = PoolOrNew(/obj/effect/effect/ion_trails, oldposition)
				I.dir = src.holder.dir
				flick("ion_fade", I)
				I.icon_state = ""
				spawn( 20 )
					qdel(I)
			src.oldposition = T
		spawn(2)
			if(src.on)
				src.processing = 1
				src.start()

/datum/effect/effect/system/ion_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0
	oldposition = null



//Reagent-based explosion effect
/datum/effect/effect/system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion
	var/explosion_message = 1				//whether we show a message to mobs.

/datum/effect/effect/system/reagents_explosion/set_up (amt, loc, flash = 0, flash_fact = 0, message = 1)
	amount = amt
	explosion_message = message
	if(istype(loc, /turf/))
		location = loc
	else
		location = get_turf(loc)

	flashing = flash
	flashing_factor = flash_fact

	return

/datum/effect/effect/system/reagents_explosion/start()
	if(explosion_message)
		location.visible_message("<span class='danger'>The solution violently explodes!</span>", \
								"You hear an explosion!")
	if (amount <= 2)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		for(var/mob/M in viewers(1, location))
			if (prob (50 * amount))
				M << "<span class='danger'>The explosion knocks you down.</span>"
				M.Weaken(rand(1,5))
		return
	else
		var/devastation = -1
		var/heavy = -1
		var/light = -1
		var/flash = -1

		// Clamp all values to MAX_EXPLOSION_RANGE
		if (round(amount/12) > 0)
			devastation = min (MAX_EX_DEVESTATION_RANGE, devastation + round(amount/12))

		if (round(amount/6) > 0)
			heavy = min (MAX_EX_HEAVY_RANGE, heavy + round(amount/6))

		if (round(amount/3) > 0)
			light = min (MAX_EX_LIGHT_RANGE, light + round(amount/3))

		if (flashing && flashing_factor)
			flash += (round(amount/4) * flashing_factor)

		explosion(location, devastation, heavy, light, flash)
