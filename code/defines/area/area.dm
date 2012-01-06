/area/Entered(A)

	var/sound = null
	var/musVolume = 25
	sound = 'ambigen1.ogg'


	if (ismob(A))

		if (istype(A, /mob/dead/observer)) return
		if (!A:ckey)
			return

		if(istype(A,/mob/living))
			if(!A:lastarea)
				A:lastarea = get_area(A:loc)
			//world << "Entered new area [get_area(A:loc)]"
			var/area/newarea = get_area(A:loc)
			var/area/oldarea = A:lastarea
			if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (A:m_intent == "run")) // Being ready when you change areas gives you a chance to avoid falling all together.
				thunk(A)

			A:lastarea = newarea

		//if (A:ear_deaf) return

		if (A && A:client && !A:client:ambience_playing && !A:client:no_ambi) // Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas next to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
			A:client:ambience_playing = 1
			A << sound('shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = 2)

		switch(src.name)
			if ("Chapel") sound = pick('ambicha1.ogg','ambicha2.ogg','ambicha3.ogg','ambicha4.ogg')
			if ("Morgue") sound = pick('ambimo1.ogg','ambimo2.ogg','title2.ogg')
			if ("Space") sound = pick('ambispace.ogg','title2.ogg',)
			if ("Engine Control") sound = pick('ambisin1.ogg','ambisin2.ogg','ambisin3.ogg','ambisin4.ogg')
			if ("Atmospherics") sound = pick('ambiatm1.ogg')
			if ("AI Sat Ext") sound = pick('ambiruntime.ogg','ambimalf.ogg')
			if ("AI Satellite") sound = pick('ambimalf.ogg')
			if ("AI Satellite Teleporter Room") sound = pick('ambiruntime.ogg','ambimalf.ogg')
			if ("Bar") sound = pick('null.ogg')
			if ("AI Upload Foyer") sound = pick('ambimalf.ogg', 'null.ogg')
			if ("AI Upload Chamber") sound = pick('ambimalf.ogg','null.ogg')
			if ("Mine")
				sound = pick('ambimine.ogg')
				musVolume = 25
			else
				sound = pick('ambiruntime.ogg','ambigen1.ogg','ambigen3.ogg','ambigen4.ogg','ambigen5.ogg','ambigen6.ogg','ambigen7.ogg','ambigen8.ogg','ambigen9.ogg','ambigen10.ogg','ambigen11.ogg','ambigen12.ogg','ambigen14.ogg')


		if (prob(35))
			if(A && A:client && !A:client:played)
				A << sound(sound, repeat = 0, wait = 0, volume = musVolume, channel = 1)
				A:client:played = 1
				spawn(600)
					if(A && A:client)
						A:client:played = 0


/area/proc/thunk(mob)
	if(istype(mob,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		if((istype(mob:shoes, /obj/item/clothing/shoes/magboots) && (mob:shoes.flags & NOSLIP)))
			return

	if(istype(get_turf(mob), /turf/space)) // Can't fall onto nothing.
		return

	if((istype(mob,/mob/living/carbon/human/)) && (mob:m_intent == "run")) // Only clumbsy humans can fall on their asses.
		mob:AdjustStunned(5)
		mob:AdjustWeakened(5)

	else if (istype(mob,/mob/living/carbon/human/))
		mob:AdjustStunned(2)
		mob:AdjustWeakened(2)

	mob << "Gravity!"

/area/proc/gravitychange(var/gravitystate = 0, var/area/A)

	A.has_gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/M in A)
			thunk(M)


