
/////////////////////////////////////////////
//////// Attach a trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/datum/effect_system/trail_follow
	var/turf/oldposition
	var/processing = TRUE
	var/on = TRUE

/datum/effect_system/trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect_system/trail_follow/Destroy()
	oldposition = null
	return ..()

/datum/effect_system/trail_follow/proc/stop()
	processing = FALSE
	on = FALSE
	oldposition = null

/datum/effect_system/trail_follow/steam
	effect_type = /obj/effect/particle_effect/steam

/datum/effect_system/trail_follow/steam/proc/Iter_Number()

/datum/effect_system/trail_follow/steam/start()
	if(!on)
		on = TRUE
		processing = TRUE
		if(!oldposition)
			oldposition = get_turf(holder)
	if(processing)
		processing = FALSE
		if(number < 3)
			var/obj/effect/particle_effect/steam/I = new /obj/effect/particle_effect/steam(oldposition)
			number++
			I.setDir(holder.dir)
			oldposition = get_turf(holder)
			spawn(10)
				qdel(I)
				number--
		spawn(2)
			if(on)
				processing = TRUE
				start()

/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = TRUE

/obj/effect/particle_effect/ion_trails/flight
	icon_state = "ion_trails_flight"

/datum/effect_system/trail_follow/ion
	effect_type = /obj/effect/particle_effect/ion_trails
	var/fadetype = "ion_fade"
	var/fade = TRUE
	var/nograv_required = TRUE

/datum/effect_system/trail_follow/ion/proc/Restart_Processing()
	if(on)
		processing = TRUE
		start()

/datum/effect_system/trail_follow/ion/start() //Whoever is responsible for this abomination of code should become an hero
	if(!on)
		on = TRUE
		processing = TRUE
		if(!oldposition)
			oldposition = get_turf(holder)
	if(processing)
		processing = FALSE
		var/turf/T = get_turf(holder)
		if(T != oldposition)
			if(!T.has_gravity() || !nograv_required)
				var/obj/effect/particle_effect/ion_trails/I = new effect_type(oldposition)
				set_dir(I)
				if(fade)
					flick(fadetype, I)
					I.icon_state = ""
				QDEL_IN(I, 20)
			oldposition = T
		addtimer(CALLBACK(src, .proc/Restart_Processing), 2)

/datum/effect_system/trail_follow/ion/proc/set_dir(obj/effect/particle_effect/ion_trails/I)
	I.setDir(holder.dir)

/datum/effect_system/trail_follow/ion/flight
	effect_type = /obj/effect/particle_effect/ion_trails/flight
	fadetype = "ion_fade_flight"
	nograv_required = FALSE

/datum/effect_system/trail_follow/ion/flight/set_dir(obj/effect/particle_effect/ion_trails/I)
	if(istype(holder, /obj/item/device/flightpack))
		var/obj/item/device/flightpack/F = holder
		I.setDir(F.suit.user.dir)


//Reagent-based explosion effect

/datum/effect_system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = FALSE			// does explosion creates flash effect?
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
	if (amount < 1)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		for(var/mob/living/L in viewers(1, location))
			if(prob(50 * amount))
				to_chat(L, "<span class='danger'>The explosion knocks you down.</span>")
				L.Knockdown(rand(20,100))
		return
	else
		dyn_explosion(location, amount, flashing_factor)

/datum/effect_system/trail_follow/ion/space_trail
	var/turf/oldloc // secondary ion trail loc
	var/turf/currloc

/datum/effect_system/trail_follow/ion/space_trail/Destroy()
	oldloc = null
	currloc = null
	return ..()

/datum/effect_system/trail_follow/ion/space_trail/proc/Do_Spesstrail()
	var/turf/T = get_turf(holder)
	if(currloc != T)
		switch(holder.dir)
			if(NORTH)
				oldposition = T
				oldposition = get_step(oldposition, SOUTH)
				oldloc = get_step(oldposition,EAST)
			if(SOUTH) // More difficult, offset to the north!
				oldposition = get_step(holder,NORTH)
				oldposition = get_step(oldposition,NORTH)
				oldloc = get_step(oldposition,EAST)
			if(EAST) // Just one to the north should suffice
				oldposition = T
				oldposition = get_step(oldposition, WEST)
				oldloc = get_step(oldposition,NORTH)
			if(WEST) // One to the east and north from there
				oldposition = get_step(holder,EAST)
				oldposition = get_step(oldposition,EAST)
				oldloc = get_step(oldposition,NORTH)
		if(istype(T, /turf/open/space))
			var/obj/effect/particle_effect/ion_trails/I = new /obj/effect/particle_effect/ion_trails(oldposition)
			var/obj/effect/particle_effect/ion_trails/II = new /obj/effect/particle_effect/ion_trails(oldloc)
			I.dir = holder.dir
			II.dir = holder.dir
			flick("ion_fade", I)
			flick("ion_fade", II)
			I.icon_state = ""
			II.icon_state = ""
			QDEL_IN(I, 20)
			QDEL_IN(II, 20)
	addtimer(CALLBACK(src, .proc/Restart_Processing), 2)
	currloc = T



/datum/effect_system/trail_follow/ion/space_trail/start()
	if(!on)
		on = FALSE
		processing = TRUE
	if(processing)
		processing = FALSE
		INVOKE_ASYNC(src, .proc/Do_Spesstrail)