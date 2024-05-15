/// Hallucination that plays a fake sound somewhere nearby.
/datum/hallucination/fake_sound
	abstract_hallucination_parent = /datum/hallucination/fake_sound

	/// Volume of the fake sound
	var/volume = 50
	/// Whether the fake sound has vary or not
	var/sound_vary = TRUE
	/// A path to a sound, or a list of sounds, that plays when we trigger
	var/sound_type

/datum/hallucination/fake_sound/start()
	var/sound_to_play = islist(sound_type) ? pick(sound_type) : sound_type
	play_fake_sound(random_far_turf(), sound_to_play)
	feedback_details += "Sound: [sound_to_play]"
	qdel(src)
	return TRUE

/// Actually plays the fake sound.
/datum/hallucination/fake_sound/proc/play_fake_sound(turf/source, sound_to_play = sound_type)
	hallucinator.playsound_local(source, sound_to_play, volume, sound_vary)

/// Used to queue additional, delayed fake sounds via a callback.
/datum/hallucination/fake_sound/proc/queue_fake_sound(turf/source, sound_to_play, volume_override, vary_override, delay)
	if(!delay)
		CRASH("[type] queued a fake sound without a timer.")

	// Queue the sound to be played with a timer on the mob, not the datum, because we'll probably get qdel'd
	addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source, sound_to_play, volume_override || volume, vary_override || sound_vary), delay)

/datum/hallucination/fake_sound/normal
	abstract_hallucination_parent = /datum/hallucination/fake_sound/normal
	random_hallucination_weight = 5

/datum/hallucination/fake_sound/normal/airlock
	volume = 30
	sound_type = 'sound/machines/airlock.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry
	volume = 100
	sound_type = 'sound/machines/airlock_alien_prying.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	queue_fake_sound(source, 'sound/machines/airlockforced.ogg', 50, TRUE, delay = 5 SECONDS)

/datum/hallucination/fake_sound/normal/console
	volume = 25
	sound_type = 'sound/machines/terminal_prompt.ogg'

/datum/hallucination/fake_sound/normal/boom
	sound_type = list('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg')

/datum/hallucination/fake_sound/normal/distant_boom
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
	volume = 40
	sound_type = 'sound/mecha/mechstep.ogg'
	/// The turf the mech started walking from.
	var/turf/mech_source
	/// What dir is the mech walking?
	var/mech_dir = NORTH
	/// How many steps are left in the walk?
	var/steps_left = 0

/datum/hallucination/fake_sound/normal/mech/Destroy()
	mech_source = null
	return ..()

/datum/hallucination/fake_sound/normal/mech/start()
	mech_dir = pick(GLOB.cardinals)
	steps_left = rand(4, 9)
	mech_source = random_far_turf()

	mech_walk()
	return TRUE

/datum/hallucination/fake_sound/normal/mech/proc/mech_walk()
	if(QDELETED(src))
		return

	if(prob(75))
		play_fake_sound(mech_source)
		mech_source = get_step(mech_source, mech_dir)
	else
		play_fake_sound(mech_source)
		mech_dir = pick(GLOB.cardinals)

	steps_left--
	if(steps_left <= 0)
		qdel(src)

	else
		addtimer(CALLBACK(src, PROC_REF(mech_walk)), 1 SECONDS)

/datum/hallucination/fake_sound/normal/wall_deconstruction
	sound_type = 'sound/items/welder.ogg'

/datum/hallucination/fake_sound/normal/wall_deconstruction/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	queue_fake_sound(source, 'sound/items/welder2.ogg', delay = 10.5 SECONDS)
	queue_fake_sound(source, 'sound/items/ratchet.ogg', delay = 12 SECONDS)

/datum/hallucination/fake_sound/normal/door_hacking
	sound_type = 'sound/items/screwdriver.ogg'
	volume = 30

/datum/hallucination/fake_sound/normal/door_hacking/play_fake_sound(turf/source, sound_to_play)
	// Make it sound like someone's pulsing a multitool one or multiple times.
	// Screwdriver happens immediately...
	. = ..()

	var/hacking_time = rand(4 SECONDS, 8 SECONDS)
	// Multitool sound.
	queue_fake_sound(source, 'sound/weapons/empty.ogg', delay = 0.8 SECONDS)
	if(hacking_time > 4.5 SECONDS)
		// Another multitool sound if the hacking time is long.
		queue_fake_sound(source, 'sound/weapons/empty.ogg', delay = 3 SECONDS)
		if(prob(50))
			// Bonus multitool sound, rapidly after the last.
			queue_fake_sound(source, 'sound/weapons/empty.ogg', delay = 3.5 SECONDS)

	if(hacking_time > 5.5 SECONDS)
		// A final multitool sound if the hacking time is very long.
		queue_fake_sound(source, 'sound/weapons/empty.ogg', delay = 5 SECONDS)

	// Crowbarring it open.
	queue_fake_sound(source, 'sound/machines/airlockforced.ogg', delay = hacking_time)

/datum/hallucination/fake_sound/normal/steam
	volume = 75
	sound_type = 'sound/machines/steam_hiss.ogg'

/datum/hallucination/fake_sound/normal/flash
	random_hallucination_weight = 2 // "it's revs"
	volume = 90
	sound_type = 'sound/weapons/flash.ogg'

/datum/hallucination/fake_sound/weird
	abstract_hallucination_parent = /datum/hallucination/fake_sound/weird
	random_hallucination_weight = 1

	/// if FALSE, we will pass "null" in as the turf source, meaning the sound will just play without direction / etc.
	var/no_source = FALSE

/datum/hallucination/fake_sound/weird/play_fake_sound(turf/source, sound_to_play)
	if(no_source)
		return ..(null, sound_to_play)

	return ..()

/datum/hallucination/fake_sound/weird/antag
	random_hallucination_weight = 0 // This one's a bit gamey, so I'll leave it disabled by default. Have fun badmins
	volume = 90
	sound_vary = FALSE
	no_source = TRUE
	sound_type = list(
		'sound/ambience/antag/bloodcult/bloodcult_gain.ogg',
		'sound/ambience/antag/clockcultalr.ogg',
		'sound/ambience/antag/heretic/heretic_gain.ogg',
		'sound/ambience/antag/ling_alert.ogg',
		'sound/ambience/antag/malf.ogg',
		'sound/ambience/antag/ops.ogg',
		'sound/ambience/antag/spy.ogg',
		'sound/ambience/antag/tatoralert.ogg',
	)

/datum/hallucination/fake_sound/weird/chimp_event
	volume = 90
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/ambience/antag/monkey.ogg'

/datum/hallucination/fake_sound/weird/colossus
	sound_type = 'sound/magic/clockwork/invoke_general.ogg'

/datum/hallucination/fake_sound/weird/creepy

/datum/hallucination/fake_sound/weird/creepy/New(mob/living/hallucinator)
	. = ..()
	//These sounds are (mostly) taken from Hidden: Source
	sound_type = GLOB.creepy_ambience

/datum/hallucination/fake_sound/weird/curse_sound
	volume = 40
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/magic/curse.ogg'

/datum/hallucination/fake_sound/weird/game_over
	sound_vary = FALSE
	sound_type = 'sound/misc/compiler-failure.ogg'

/datum/hallucination/fake_sound/weird/hallelujah
	sound_vary = FALSE
	sound_type = 'sound/effects/pray_chaplain.ogg'

/datum/hallucination/fake_sound/weird/highlander
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/misc/highlander.ogg'

/datum/hallucination/fake_sound/weird/hyperspace
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/runtime/hyperspace/hyperspace_begin.ogg'

/datum/hallucination/fake_sound/weird/laugher
	sound_type = list(
		'sound/voice/human/womanlaugh.ogg',
		'sound/voice/human/manlaugh1.ogg',
		'sound/voice/human/manlaugh2.ogg',
	)

/datum/hallucination/fake_sound/weird/phone
	volume = 15
	sound_vary = FALSE
	sound_type = 'sound/weapons/ring.ogg'

/datum/hallucination/fake_sound/weird/phone/play_fake_sound(turf/source, sound_to_play)
	for(var/next_ring in 1 to 3)
		queue_fake_sound(source, sound_to_play, delay = 2.5 SECONDS * next_ring)

	return ..()

/datum/hallucination/fake_sound/weird/spell
	sound_type = list(
		'sound/magic/disintegrate.ogg',
		'sound/magic/ethereal_enter.ogg',
		'sound/magic/ethereal_exit.ogg',
		'sound/magic/fireball.ogg',
		'sound/magic/forcewall.ogg',
		'sound/magic/teleport_app.ogg',
		'sound/magic/teleport_diss.ogg',
	)

/datum/hallucination/fake_sound/weird/spell/just_jaunt // A few antags use jaunts, so this sound specifically is fun to isolate
	sound_type = 'sound/magic/ethereal_enter.ogg'

/datum/hallucination/fake_sound/weird/summon_sound // Heretic circle sound, notably
	volume = 75
	sound_type = 'sound/magic/castsummon.ogg'

/datum/hallucination/fake_sound/weird/tesloose
	volume = 35
	sound_type = 'sound/magic/lightningbolt.ogg'

/datum/hallucination/fake_sound/weird/tesloose/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	for(var/next_shock in 1 to rand(2, 4))
		queue_fake_sound(source, sound_to_play, volume_override = volume + (15 * next_shock), delay = 3 SECONDS * next_shock)

/datum/hallucination/fake_sound/weird/xeno
	random_hallucination_weight = 2 // Some of these are ambience sounds too
	volume = 25
	sound_type = list(
		'sound/voice/lowHiss1.ogg',
		'sound/voice/lowHiss2.ogg',
		'sound/voice/lowHiss3.ogg',
		'sound/voice/lowHiss4.ogg',
		'sound/voice/hiss1.ogg',
		'sound/voice/hiss2.ogg',
		'sound/voice/hiss3.ogg',
		'sound/voice/hiss4.ogg',
	)

/datum/hallucination/fake_sound/weird/radio_static
	volume = 75
	no_source = TRUE
	sound_vary = FALSE
	sound_type = 'sound/hallucinations/radio_static.ogg'

/datum/hallucination/fake_sound/weird/ice_crack
	random_hallucination_weight = 2
	volume = 100
	no_source = TRUE
	sound_type = 'sound/effects/ice_shovel.ogg'
