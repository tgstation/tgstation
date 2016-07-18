
/////////////////////////////////////////////
//////// Attach a trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/datum/effect_system/trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect_system/trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect_system/trail_follow/Destroy()
	oldposition = null
	return ..()

/datum/effect_system/trail_follow/proc/stop()
	processing = 0
	on = 0
	oldposition = null

/datum/effect_system/trail_follow/steam
	effect_type = /obj/effect/particle_effect/steam

/datum/effect_system/trail_follow/steam/start()
	if(!on)
		on = 1
		processing = 1
		if(!oldposition)
			oldposition = get_turf(holder)
	if(processing)
		processing = 0
		if(number < 3)
			var/obj/effect/particle_effect/steam/I = PoolOrNew(/obj/effect/particle_effect/steam, oldposition)
			number++
			I.setDir(holder.dir)
			oldposition = get_turf(holder)
			spawn(10)
				qdel(I)
				number--
		spawn(2)
			if(on)
				processing = 1
				start()

/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1

/datum/effect_system/trail_follow/ion
	effect_type = /obj/effect/particle_effect/ion_trails

/datum/effect_system/trail_follow/ion/start() //Whoever is responsible for this abomination of code should become an hero
	if(!on)
		on = 1
		processing = 1
		if(!oldposition)
			oldposition = get_turf(holder)
	if(processing)
		processing = 0
		var/turf/T = get_turf(holder)
		if(T != oldposition)
			if(!has_gravity(T))
				var/obj/effect/particle_effect/ion_trails/I = PoolOrNew(effect_type, oldposition)
				I.setDir(holder.dir)
				flick("ion_fade", I)
				I.icon_state = ""
				spawn(20)
					qdel(I)
			oldposition = T
		spawn(2)
			if(on)
				processing = 1
				start()




//Reagent-based explosion effect

/datum/effect_system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion
	var/explosion_message = 1				//whether we show a message to mobs.

/datum/effect_system/reagents_explosion/set_up(amt, loca, flash = 0, flash_fact = 0, message = 1)
	amount = amt
	explosion_message = message
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	flashing = flash
	flashing_factor = flash_fact

/datum/effect_system/reagents_explosion/start()
	if(explosion_message)
		location.visible_message("<span class='danger'>The solution violently explodes!</span>", \
								"<span class='italics'>You hear an explosion!</span>")
	if (amount <= 2)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
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
