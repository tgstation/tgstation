/**
 * Sound Player component
 *
 * Component that will play a sound upon recieving some signal
 */
/datum/component/sound_player
	///Volume of the sound when played
	var/volume
	///The list of sounds played, picked randomly.
	var/list/sounds
	///Uses left before the sound player deletes itself
	var/uses
	///List of all signals that must be recieved to trigger the sound
	var/signal_list

/datum/component/sound_player/Initialize(
	volume = 30,
	sounds = list('sound/items/bikehorn.ogg'),
	uses = -1,
	signal_list = list(COMSIG_ATOM_ATTACK_HAND),
)
	src.volume = volume
	src.sounds = sounds
	src.uses = uses
	src.signal_list = signal_list

	RegisterSignal(parent, signal_list, .proc/play_sound)



/**
 * Attempt to play the sound on parent
 *
 * If out of uses, will qdel itself.
 */
/datum/component/sound_player/proc/play_sound()
	SIGNAL_HANDLER

	playsound(parent, pick(sounds), volume, TRUE)
	if(uses <= -1)
		return
	uses--
	if(!uses)
		qdel(src)
