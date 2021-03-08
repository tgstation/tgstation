/**
 * # Looping sound datums
 *
 * Used to play sound(s) on repeat until they are stopped
 * Processed by the SSloopingsounds [/datum/controller/subsystem/loopingsounds]
 */
/datum/looping_sound
	///(list of atoms) The destination(s) for the sounds
	var/list/atom/output_atoms
	/// (list or soundfile) Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	var/mid_sounds
	/// (num) The length to wait between playing mid_sounds
	var/mid_length
	///(num) Override for volume of start sound
	var/start_volume
	/// (soundfile) Sound played before starting the mid_sounds loop
	var/start_sound
	///(num) How long to wait in ticks before starting the main loop after playing start_sound
	var/start_length
	///(num) Override for volume of end sound
	var/end_volume
	/// (soundfile) The sound played after the main loop has concluded
	var/end_sound
	///(num) % Chance per loop to play a mid_sound
	var/chance
	/// (num) Sound output volume
	var/volume = 100
	///(bool) Whether sounds played by this datum should be slightly varied by [/proc/playsound()]
	var/vary = FALSE
	/// (num) The max amount of loops to run for.
	var/max_loops
	///(bool) If true plays directly to provided atoms instead of from them
	var/direct = FALSE
	var/extra_range = 0
	var/falloff_exponent
	var/falloff_distance

	///(bool) Whether this datum is currently going through the subsystem on a loop
	var/looping = FALSE
	///(num) Next sceduled time for the sound to be played, used in subsystem fire to scedule
	var/nextlooptime = 0
	///(num) world.time when the datum started looping
	var/start_time = 0

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

///Performs checks for looping and optinally adds a new atom to output_atoms, then calls [/datum/looping_sound/proc/on_start()]
/datum/looping_sound/proc/start(atom/add_thing)
	if(add_thing)
		output_atoms |= add_thing
	if(looping)
		return
	looping = TRUE
	on_start()

///Performs checks for ending looping and optinally removes an atom from output_atoms, then calls [/datum/looping_sound/proc/on_stop()]
/datum/looping_sound/proc/stop(atom/remove_thing)
	if(remove_thing)
		output_atoms -= remove_thing
	if(!looping)
		return
	looping = FALSE
	SSloopingsounds.looping_sound_queue -= src
	on_stop()

///Performs checks for sound loop; returns TRUE to rescedule for another loop and FALSE to stop looping.
/datum/looping_sound/proc/sound_loop()
	if(max_loops && world.time >= start_time + mid_length * max_loops)
		return FALSE
	if(!chance || prob(chance))
		play(get_sound(start_time))
	return TRUE

/**
 * Plays a sound file to our output_atoms
 * Arguments:
 * * soundfile: sound file to be played
 * * volume_override: Optional argument to override the usual volume var for this sound
 */
/datum/looping_sound/proc/play(soundfile, volume_override)
	var/list/atoms_cache = output_atoms
	var/sound/S = sound(soundfile)
	if(direct)
		S.channel = SSsounds.random_available_channel()
		S.volume = volume_override || volume //Use volume as fallback if theres no override
	for(var/i in 1 to atoms_cache.len)
		var/atom/thing = atoms_cache[i]
		if(direct)
			SEND_SOUND(thing, S)
		else
			playsound(thing, S, volume, vary, extra_range, falloff_exponent = falloff_exponent, falloff_distance = falloff_distance)

/**
 * Picks and returns soundfile
 * Arguments:
 * * starttime: world.time when this loop started
 * * _mid_sounds: sound selection override as compared to the usual mid_sounds
 */
/datum/looping_sound/proc/get_sound(starttime, _mid_sounds)
	. = _mid_sounds || mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/**
 * Called on loop start
 * plays start sound, sets start_time
 * then inserts into subsystem
 */
/datum/looping_sound/proc/on_start()
	var/start_wait = 1
	if(start_sound)
		play(start_sound, start_volume)
		start_wait = start_length
	nextlooptime = REALTIMEOFDAY + start_wait
	start_time = nextlooptime
	BINARY_INSERT(src, SSloopingsounds.looping_sound_queue, /datum/looping_sound, src, nextlooptime, COMPARE_KEY)

/**
 * Called on loop end
 * if there is a end_sound, plays it
 */
/datum/looping_sound/proc/on_stop()
	if(end_sound)
		play(end_sound, end_volume)
