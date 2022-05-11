/// Hallucination that plays a fake sound somewhere nearby.
/datum/hallucination/fake_sound
	var/turf/sound_source
	var/volume = 50
	var/sound_vary = TRUE
	var/sound_type

/datum/hallucination/fake_sound/start()
	sound_source = random_far_turf()

	var/sound_to_play = islist(sound_type) ? pick(sound_type) : sound_type
	hallucinator.playsound_local(sound_source, sound_to_play, volume, sound_vary)

	qdel(src)
	return TRUE

/datum/hallucination/fake_sound/Destroy()
	sound_source = null
	return ..()

/// "Normal" fake sounds are more average / standard sounds you might hear.
/datum/hallucination/fake_sound/normal

/datum/hallucination/fake_sound/normal/random

/datum/hallucination/fake_sound/normal/random/start()
	var/picked_sound = pick(subtypesof(/datum/hallucination/fake_sound/normal) - type)

	feedback_details += "Type: [picked_sound]"
	hallucinator.cause_hallucination(picked_sound, source = "random normal sound hallucination")

	qdel(src)
	return TRUE

/datum/hallucination/fake_sound/normal/airlock
	volume = 30
	sound_type = 'sound/machines/airlock.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry
	volume = 100
	sound_type = 'sound/machines/airlock_alien_prying.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry/start()
	addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/machines/airlockforced.ogg', 30, TRUE), 5 SECONDS)
	return ..()

/datum/hallucination/fake_sound/normal/console
	volume = 25
	sound_type = 'sound/machines/terminal_prompt.ogg'

/datum/hallucination/fake_sound/normal/boom
	sound_type = list('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg')

/datum/hallucination/fake_sound/normal/distant_boom
	volume = 50
	sound_type = 'sound/effects/explosionfar.ogg'

/datum/hallucination/fake_sound/normal/glass
	sound_type = list('sound/effects/glassbr1.ogg', 'sound/effects/glassbr2.ogg', 'sound/effects/glassbr3.ogg')

/datum/hallucination/fake_sound/normal/alarm
	volume = 100
	sound_type = 'sound/machines/alarm.ogg'

/datum/hallucination/fake_sound/normal/beepsky
	volume = 35
	sound_type = 'sound/voice/beepsky/freeze.ogg'

/datum/hallucination/fake_sound/normal/mech
	var/mech_dir = NORTH
	var/steps_left = 0

/datum/hallucination/fake_sound/normal/mech/start()
	mech_dir = pick(GLOB.cardinals)
	steps_left = rand(4, 9)
	sound_source = random_far_turf()

	mech_walk()
	return TRUE

/datum/hallucination/fake_sound/normal/mech/proc/mech_walk()
	if(QDELETED(src))
		return

	if(prob(75))
		hallucinator.playsound_local(sound_source, 'sound/mecha/mechstep.ogg', 40, TRUE)
		sound_source = get_step(sound_source, mech_dir)
	else
		hallucinator.playsound_local(sound_source, 'sound/mecha/mechturn.ogg', 40, TRUE)
		mech_dir = pick(GLOB.cardinals)

	if(--steps_left <= 0)
		qdel(src)

	else
		addtimer(CALLBACK(src, .proc/mech_walk), 1 SECONDS)

/datum/hallucination/fake_sound/normal/wall_deconstruction
	sound_type = 'sound/items/welder.ogg'

/datum/hallucination/fake_sound/normal/wall_deconstruction/start()
	addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/items/welder2.ogg', volume, TRUE), 10.5 SECONDS)
	addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/items/ratchet.ogg', volume, TRUE), 12 SECONDS)
	return ..()

/datum/hallucination/fake_sound/normal/door_hacking
	sound_type = 'sound/items/screwdriver.ogg'

/datum/hallucination/fake_sound/normal/door_hacking/start()
	var/hacking_time = rand(4 SECONDS, 8 SECONDS)

	// Make it sound like someone's pulsing a multitool one or multiple times.
	addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/weapons/empty.ogg', 30, TRUE), 0.8 SECONDS)
	if(hacking_time > 4.5 SECONDS)
		addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/weapons/empty.ogg', 30, TRUE), 3 SECONDS)
		if(prob(50))
			addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/weapons/empty.ogg', 30, TRUE), 3.5 SECONDS)

	if(hacking_time > 5.5 SECONDS)
		addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/weapons/empty.ogg', 30, TRUE), 5 SECONDS)

	addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, 'sound/machines/airlockforced.ogg', 30, TRUE), rand(4 SECONDS, 8 SECONDS))
	return ..()

/datum/hallucination/fake_sound/weird
	sound_vary = FALSE
	/// if FALSE, we will pass "null" in as the turf source, meaning the sound will just play without direction / etc.
	var/no_source = FALSE

/datum/hallucination/fake_sound/weird/start()
	if(!no_source)
		return ..()

	hallucinator.playsound_local(null, sound_type, volume, sound_vary)
	qdel(src)
	return TRUE

/datum/hallucination/fake_sound/weird/phone
	volume = 15
	sound_type = 'sound/weapons/ring.ogg'

/datum/hallucination/fake_sound/weird/phone/start()
	for(var/next_ring in 1 to 3)
		addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, sound_type, volume, sound_vary), 2.5 SECONDS * next_ring)
	return ..()

/datum/hallucination/fake_sound/weird/hallelujah
	sound_type = 'sound/effects/pray_chaplain.ogg'

/datum/hallucination/fake_sound/weird/hyperspace
	sound_type = 'sound/runtime/hyperspace/hyperspace_begin.ogg'
	no_source = TRUE

/datum/hallucination/fake_sound/weird/highlander
	sound_type = 'sound/misc/highlander.ogg'
	no_source = TRUE

/datum/hallucination/fake_sound/weird/game_over
	sound_type = 'sound/misc/compiler-failure.ogg'

/datum/hallucination/fake_sound/weird/laugher
	sound_vary = TRUE
	sound_type = list(
		'sound/voice/human/womanlaugh.ogg',
		'sound/voice/human/manlaugh1.ogg',
		'sound/voice/human/manlaugh2.ogg',
	)

/datum/hallucination/fake_sound/weird/creepy
	sound_vary = TRUE

/datum/hallucination/fake_sound/weird/creepy/New(mob/living/hallucinator)
	. = ..()
	//These sounds are (mostly) taken from Hidden: Source
	sound_type = GLOB.creepy_ambience

/datum/hallucination/fake_sound/weird/tesloose
	volume = 35
	sound_vary = TRUE
	sound_type = 'sound/magic/lightningbolt.ogg'

/datum/hallucination/fake_sound/weird/tesloose/start()
	for(var/next_shock in 1 to rand(2, 4))
		addtimer(CALLBACK(hallucinator, /mob/.proc/playsound_local, sound_source, sound_type, volume + (15 * next_shock), sound_vary), 3 SECONDS * next_shock)
	return ..()
