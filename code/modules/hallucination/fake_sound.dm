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
	sound_type = 'sound/machines/airlock/airlock.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry
	volume = 100
	sound_type = 'sound/machines/airlock/airlock_alien_prying.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	queue_fake_sound(source, 'sound/machines/airlock/airlockforced.ogg', 50, TRUE, delay = 5 SECONDS)

/datum/hallucination/fake_sound/normal/console
	volume = 25
	sound_type = 'sound/machines/terminal/terminal_prompt.ogg'

/datum/hallucination/fake_sound/normal/boom
	sound_type = list('sound/effects/explosion/explosion1.ogg', 'sound/effects/explosion/explosion2.ogg')

/datum/hallucination/fake_sound/normal/distant_boom
	sound_type = 'sound/effects/explosion/explosionfar.ogg'

/datum/hallucination/fake_sound/normal/glass
	sound_type = list('sound/effects/glass/glassbr1.ogg', 'sound/effects/glass/glassbr2.ogg', 'sound/effects/glass/glassbr3.ogg')

/datum/hallucination/fake_sound/normal/alarm
	volume = 70
	sound_type = 'sound/announcer/alarm/nuke_alarm.ogg'

/datum/hallucination/fake_sound/normal/beepsky
	volume = 35
	sound_type = 'sound/mobs/non-humanoids/beepsky/freeze.ogg'

/datum/hallucination/fake_sound/normal/mech
	volume = 40
	sound_type = 'sound/vehicles/mecha/mechstep.ogg'
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
	sound_type = 'sound/items/tools/welder.ogg'

/datum/hallucination/fake_sound/normal/wall_deconstruction/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	queue_fake_sound(source, 'sound/items/tools/welder2.ogg', delay = 10.5 SECONDS)
	queue_fake_sound(source, 'sound/items/tools/ratchet.ogg', delay = 12 SECONDS)

/datum/hallucination/fake_sound/normal/door_hacking
	sound_type = 'sound/items/tools/screwdriver.ogg'
	volume = 30

/datum/hallucination/fake_sound/normal/door_hacking/play_fake_sound(turf/source, sound_to_play)
	// Make it sound like someone's pulsing a multitool one or multiple times.
	// Screwdriver happens immediately...
	. = ..()

	var/hacking_time = rand(4 SECONDS, 8 SECONDS)
	// Multitool sound.
	queue_fake_sound(source, 'sound/items/weapons/empty.ogg', delay = 0.8 SECONDS)
	if(hacking_time > 4.5 SECONDS)
		// Another multitool sound if the hacking time is long.
		queue_fake_sound(source, 'sound/items/weapons/empty.ogg', delay = 3 SECONDS)
		if(prob(50))
			// Bonus multitool sound, rapidly after the last.
			queue_fake_sound(source, 'sound/items/weapons/empty.ogg', delay = 3.5 SECONDS)

	if(hacking_time > 5.5 SECONDS)
		// A final multitool sound if the hacking time is very long.
		queue_fake_sound(source, 'sound/items/weapons/empty.ogg', delay = 5 SECONDS)

	// Crowbarring it open.
	queue_fake_sound(source, 'sound/machines/airlock/airlockforced.ogg', delay = hacking_time)

/datum/hallucination/fake_sound/normal/steam
	volume = 75
	sound_type = 'sound/machines/steam_hiss.ogg'

/datum/hallucination/fake_sound/normal/flash
	random_hallucination_weight = 2 // "it's revs"
	volume = 90
	sound_type = 'sound/items/weapons/flash.ogg'

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
		'sound/music/antag/bloodcult/bloodcult_gain.ogg',
		'sound/music/antag/clockcultalr.ogg',
		'sound/music/antag/heretic/heretic_gain.ogg',
		'sound/music/antag/ling_alert.ogg',
		'sound/music/antag/malf.ogg',
		'sound/music/antag/ops.ogg',
		'sound/music/antag/spy.ogg',
		'sound/music/antag/traitor/tatoralert.ogg',
	)

/datum/hallucination/fake_sound/weird/chimp_event
	volume = 90
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/music/antag/monkey.ogg'

/datum/hallucination/fake_sound/weird/colossus
	sound_type = 'sound/effects/magic/clockwork/invoke_general.ogg'

/datum/hallucination/fake_sound/weird/creepy

/datum/hallucination/fake_sound/weird/creepy/New(mob/living/hallucinator)
	. = ..()
	//These sounds are (mostly) taken from Hidden: Source
	sound_type = GLOB.creepy_ambience

/datum/hallucination/fake_sound/weird/curse_sound
	volume = 40
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/effects/magic/curse.ogg'

/datum/hallucination/fake_sound/weird/game_over
	sound_vary = FALSE
	sound_type = 'sound/machines/compiler/compiler-failure.ogg'

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
		'sound/mobs/humanoids/human/laugh/womanlaugh.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)

/datum/hallucination/fake_sound/weird/phone
	volume = 15
	sound_vary = FALSE
	sound_type = 'sound/items/weapons/ring.ogg'

/datum/hallucination/fake_sound/weird/phone/play_fake_sound(turf/source, sound_to_play)
	for(var/next_ring in 1 to 3)
		queue_fake_sound(source, sound_to_play, delay = 2.5 SECONDS * next_ring)

	return ..()

/datum/hallucination/fake_sound/weird/spell
	sound_type = list(
		'sound/effects/magic/disintegrate.ogg',
		'sound/effects/magic/ethereal_enter.ogg',
		'sound/effects/magic/ethereal_exit.ogg',
		'sound/effects/magic/fireball.ogg',
		'sound/effects/magic/forcewall.ogg',
		'sound/effects/magic/teleport_app.ogg',
		'sound/effects/magic/teleport_diss.ogg',
	)

/datum/hallucination/fake_sound/weird/spell/just_jaunt // A few antags use jaunts, so this sound specifically is fun to isolate
	sound_type = 'sound/effects/magic/ethereal_enter.ogg'

/datum/hallucination/fake_sound/weird/summon_sound // Heretic circle sound, notably
	volume = 75
	sound_type = 'sound/effects/magic/castsummon.ogg'

/datum/hallucination/fake_sound/weird/tesloose
	volume = 35
	sound_type = 'sound/effects/magic/lightningbolt.ogg'

/datum/hallucination/fake_sound/weird/tesloose/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	for(var/next_shock in 1 to rand(2, 4))
		queue_fake_sound(source, sound_to_play, volume_override = volume + (15 * next_shock), delay = 3 SECONDS * next_shock)

/datum/hallucination/fake_sound/weird/xeno
	random_hallucination_weight = 2 // Some of these are ambience sounds too
	volume = 25
	sound_type = list(
		'sound/mobs/non-humanoids/hiss/lowHiss1.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss2.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss3.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss4.ogg',
		'sound/mobs/non-humanoids/hiss/hiss1.ogg',
		'sound/mobs/non-humanoids/hiss/hiss2.ogg',
		'sound/mobs/non-humanoids/hiss/hiss3.ogg',
		'sound/mobs/non-humanoids/hiss/hiss4.ogg',
	)

/datum/hallucination/fake_sound/weird/radio_static
	volume = 75
	no_source = TRUE
	sound_vary = FALSE
	sound_type = 'sound/effects/hallucinations/radio_static.ogg'

/datum/hallucination/fake_sound/weird/ice_crack
	random_hallucination_weight = 2
	volume = 100
	no_source = TRUE
	sound_type = 'sound/effects/ice_shovel.ogg'
