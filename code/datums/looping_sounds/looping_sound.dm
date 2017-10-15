/datum/looping_sound
	var/list/atom/output_atoms

	var/mid_sounds	// Can be either a list or a single sound file
	var/mid_length

	var/start_sound
	var/start_length

	var/end_sound

	var/chance
	var/volume
	var/muted
	var/max_loops

/datum/looping_sound/New(list/_output_atoms, start_immediately=FALSE)
	if(_output_atoms)
		output_atoms = _output_atoms
	else
		output_atoms = list()

	if(start_immediately)
		start()
	else
		muted = TRUE

/datum/looping_sound/proc/start()
	if(!muted)
		return
	muted = FALSE
	on_start()

/datum/looping_sound/proc/stop()
	if(muted)
		return
	muted = TRUE

/datum/looping_sound/proc/sound_loop(looped=0)
	if(muted || (max_loops && looped > max_loops))
		on_stop(looped)
		return
	if(!chance || prob(chance))
		play(get_sound(looped))
	addtimer(CALLBACK(src, .proc/sound_loop, ++looped), mid_length)

/datum/looping_sound/proc/play(soundfile)
	for(var/i in 1 to output_atoms.len)
		var/atom/thing = output_atoms[i]
		playsound(thing, soundfile, volume)

/datum/looping_sound/proc/get_sound(looped, _mid_sounds)
	if(!_mid_sounds)
		. = mid_sounds
	else
		. = _mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/datum/looping_sound/proc/on_start()
	if(start_sound)
		play(start_sound)
	addtimer(CALLBACK(src, .proc/sound_loop), start_length)

/datum/looping_sound/proc/on_stop(looped)
	if(end_sound)
		play(end_sound)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
