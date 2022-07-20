/* Sound Hallucinations
 *
 * Contains:
 * Fighting sounds
 * Machinery sounds
 * Special effects sounds
 */

/datum/hallucination/battle
	var/battle_type
	var/iterations_left
	var/hits = 0
	var/next_action = 0
	var/turf/source

/datum/hallucination/battle/New(mob/living/carbon/C, forced = TRUE, new_battle_type)
	..()

	source = random_far_turf()

	battle_type = new_battle_type
	if (isnull(battle_type))
		battle_type = pick("laser", "disabler", "esword", "gun", "stunprod", "harmbaton", "bomb")
	feedback_details += "Type: [battle_type]"
	var/process = TRUE

	switch(battle_type)
		if("disabler", "laser")
			iterations_left = rand(5, 10)
		if("esword")
			iterations_left = rand(4, 8)
			target.playsound_local(source, 'sound/weapons/saberon.ogg',15, 1)
		if("gun")
			iterations_left = rand(3, 6)
		if("stunprod") //Stunprod + cablecuff
			process = FALSE
			target.playsound_local(source, 'sound/weapons/egloves.ogg', 40, 1)
			target.playsound_local(source, get_sfx(SFX_BODYFALL), 25, 1)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/cablecuff.ogg', 15, 1), 20)
		if("harmbaton") //zap n slap
			iterations_left = rand(5, 12)
			target.playsound_local(source, 'sound/weapons/egloves.ogg', 40, 1)
			target.playsound_local(source, get_sfx(SFX_BODYFALL), 25, 1)
			next_action = 2 SECONDS
		if("bomb") // Tick Tock
			iterations_left = rand(3, 11)

	if (process)
		START_PROCESSING(SSfastprocess, src)
	else
		qdel(src)

/datum/hallucination/battle/process(delta_time)
	next_action -= (delta_time * 10)

	if (next_action > 0)
		return

	switch (battle_type)
		if ("disabler", "laser", "gun")
			var/fire_sound
			var/hit_person_sound
			var/hit_wall_sound
			var/number_of_hits
			var/chance_to_fall

			switch (battle_type)
				if ("disabler")
					fire_sound = 'sound/weapons/taser2.ogg'
					hit_person_sound = 'sound/weapons/tap.ogg'
					hit_wall_sound = 'sound/weapons/effects/searwall.ogg'
					number_of_hits = 3
					chance_to_fall = 70
				if ("laser")
					fire_sound = 'sound/weapons/laser.ogg'
					hit_person_sound = 'sound/weapons/sear.ogg'
					hit_wall_sound = 'sound/weapons/effects/searwall.ogg'
					number_of_hits = 4
					chance_to_fall = 70
				if ("gun")
					fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
					hit_person_sound = 'sound/weapons/pierce.ogg'
					hit_wall_sound = SFX_RICOCHET
					number_of_hits = 2
					chance_to_fall = 80

			target.playsound_local(source, fire_sound, 25, 1)

			if(prob(50))
				addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, hit_person_sound, 25, 1), rand(5,10))
				hits += 1
			else
				addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, hit_wall_sound, 25, 1), rand(5,10))

			next_action = rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6)

			if(hits >= number_of_hits && prob(chance_to_fall))
				addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, get_sfx(SFX_BODYFALL), 25, 1), next_action)
				qdel(src)
				return
		if ("esword")
			target.playsound_local(source, 'sound/weapons/blade1.ogg', 50, 1)

			if (hits == 4)
				target.playsound_local(source, get_sfx(SFX_BODYFALL), 25, 1)

			next_action = rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6)
			hits += 1

			if (iterations_left == 1)
				target.playsound_local(source, 'sound/weapons/saberoff.ogg', 15, 1)
		if ("harmbaton")
			target.playsound_local(source, SFX_SWING_HIT, 50, 1)
			next_action = rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 4)
		if ("bomb")
			target.playsound_local(source, 'sound/items/timer.ogg', 25, 0)
			next_action = 15

	iterations_left -= 1
	if (iterations_left == 0)
		qdel(src)

/datum/hallucination/battle/Destroy()
	. = ..()
	source = null
	STOP_PROCESSING(SSfastprocess, src)

/datum/hallucination/sounds

/datum/hallucination/sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("airlock")
			target.playsound_local(source,'sound/machines/airlock.ogg', 30, 1)
		if("airlock pry")
			target.playsound_local(source,'sound/machines/airlock_alien_prying.ogg', 100, 1)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/machines/airlockforced.ogg', 30, 1), 50)
		if("console")
			target.playsound_local(source,'sound/machines/terminal_prompt.ogg', 25, 1)
		if("explosion")
			if(prob(50))
				target.playsound_local(source,'sound/effects/explosion1.ogg', 50, 1)
			else
				target.playsound_local(source, 'sound/effects/explosion2.ogg', 50, 1)
		if("far explosion")
			target.playsound_local(source, 'sound/effects/explosionfar.ogg', 50, 1)
		if("glass")
			target.playsound_local(source, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 50, 1)
		if("alarm")
			target.playsound_local(source, 'sound/machines/alarm.ogg', 100, 0)
		if("beepsky")
			target.playsound_local(source, 'sound/voice/beepsky/freeze.ogg', 35, 0)
		if("mech")
			new /datum/hallucination/mech_sounds(C, forced, sound_type)
		//Deconstructing a wall
		if("wall decon")
			target.playsound_local(source, 'sound/items/welder.ogg', 50, 1)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/items/welder2.ogg', 50, 1), 105)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/items/ratchet.ogg', 50, 1), 120)
		//Hacking a door
		if("door hack")
			target.playsound_local(source, 'sound/items/screwdriver.ogg', 50, 1)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/machines/airlockforced.ogg', 30, 1), rand(40, 80))
	qdel(src)

/datum/hallucination/mech_sounds
	var/mech_dir
	var/steps_left
	var/next_action = 0
	var/turf/source

/datum/hallucination/mech_sounds/New()
	. = ..()
	mech_dir = pick(GLOB.cardinals)
	steps_left = rand(4, 9)
	source = random_far_turf()
	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/mech_sounds/process(delta_time)
	next_action -= delta_time
	if (next_action > 0)
		return

	if(prob(75))
		target.playsound_local(source, 'sound/mecha/mechstep.ogg', 40, 1)
		source = get_step(source, mech_dir)
	else
		target.playsound_local(source, 'sound/mecha/mechturn.ogg', 40, 1)
		mech_dir = pick(GLOB.cardinals)

	steps_left -= 1
	if (!steps_left)
		qdel(src)
		return
	next_action = 1

/datum/hallucination/mech_sounds/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/hallucination/weird_sounds

/datum/hallucination/weird_sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("phone")
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			for (var/next_rings in 1 to 3)
				addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/ring.ogg', 15), 25 * next_rings)
		if("hyperspace")
			target.playsound_local(null, 'sound/runtime/hyperspace/hyperspace_begin.ogg', 50)
		if("hallelujah")
			target.playsound_local(source, 'sound/effects/pray_chaplain.ogg', 50)
		if("highlander")
			target.playsound_local(null, 'sound/misc/highlander.ogg', 50)
		if("game over")
			target.playsound_local(source, 'sound/misc/compiler-failure.ogg', 50)
		if("laughter")
			if(prob(50))
				target.playsound_local(source, 'sound/voice/human/womanlaugh.ogg', 50, 1)
			else
				target.playsound_local(source, pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg'), 50, 1)
		if("creepy")
		//These sounds are (mostly) taken from Hidden: Source
			target.playsound_local(source, pick(GLOB.creepy_ambience), 50, 1)
		if("tesla") //Tesla loose!
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 35, 1)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/magic/lightningbolt.ogg', 65, 1), 30)
			addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/magic/lightningbolt.ogg', 100, 1), 60)

	qdel(src)
