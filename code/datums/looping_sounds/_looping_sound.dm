/datum/looping_sound
	///output_atoms	(list of atoms)			The destination(s) for the sounds
	var/list/atom/output_atoms
	///mid_sounds		(list or soundfile)		Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	var/mid_sounds
	///mid_length		(num)					The length to wait between playing mid_sounds
	var/mid_length
	///start_sound		(soundfile)				Played before starting the mid_sounds loop
	var/start_sound
	///start_length	(num)					How long to wait before starting the main loop after playing start_sound
	var/start_length
	///end_sound		(soundfile)				The sound played after the main loop has concluded
	var/end_sound
	///chance			(num)					Chance per loop to play a mid_sound
	var/chance
	///volume			(num)					Sound output volume
	var/volume = 100
	///Whether or not the sound varies every time it plays
	var/vary = FALSE
	///max_loops		(num)					The max amount of loops to run for.
	var/max_loops
	///direct			(bool)					If true plays directly to provided atoms instead of from them
	var/direct
	var/extra_range = 0
	var/falloff
	///If this is true, the audio in the list is meant to be played in order
	var/sequenced_loop = FALSE
	///Used when sequenced_loop is TRUE, keeps track of what part of the list we are at.
	var/current_sequence_index = 1

	var/timerid

/datum/looping_sound/New(list/_output_atoms=list(), start_immediately=FALSE, _direct=FALSE)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	output_atoms = _output_atoms
	direct = _direct

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	stop()
	output_atoms = null
	return ..()

/datum/looping_sound/proc/start(atom/add_thing)
	if(add_thing)
		output_atoms |= add_thing
	if(timerid)
		return
	on_start()

/datum/looping_sound/proc/stop(atom/remove_thing)
	if(remove_thing)
		output_atoms -= remove_thing
	if(!timerid)
		return
	on_stop()
	deltimer(timerid)
	timerid = null

/datum/looping_sound/proc/sound_loop(starttime)
	if(max_loops && world.time >= starttime + mid_length * max_loops)
		stop()
		return
	if(!chance || prob(chance))
		play(get_sound(starttime))
	if(!timerid)
		timerid = addtimer(CALLBACK(src, .proc/sound_loop, world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP)

/datum/looping_sound/proc/play(soundfile)
	var/list/atoms_cache = output_atoms
	var/sound/S = sound(soundfile)
	if(direct)
		S.channel = SSsounds.random_available_channel()
		S.volume = volume
	for(var/i in 1 to atoms_cache.len)
		var/atom/thing = atoms_cache[i]
		if(direct)
			SEND_SOUND(thing, S)
		else
			playsound(thing, S, volume, vary, extra_range, falloff)

/datum/looping_sound/proc/get_sound(starttime, _mid_sounds)
	var/list/sounds = _mid_sounds || mid_sounds
	if(!sequenced_loop)
		. = pickweight(sounds)
	else
		. = sounds[current_sequence_index]

		if(current_sequence_index >= sounds.len)
			current_sequence_index = 1
		else
			current_sequence_index++


/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound)
		play(start_sound)
		start_wait = start_length
	addtimer(CALLBACK(src, .proc/sound_loop), start_wait, TIMER_CLIENT_TIME)

/datum/looping_sound/proc/on_stop()
	current_sequence_index = 1 //Back to the start
	if(end_sound)
		play(end_sound)
