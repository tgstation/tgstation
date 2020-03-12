/datum/component/smooth_tunes
///if applied due to a rite, we link it here
	var/datum/religion_rites/song_tuner/linked_songtuner_rite
///linked song
	var/datum/song/linked_song
///if repeats count as continuations instead of a song's end, TRUE
	var/allow_repeats = TRUE

/datum/component/smooth_tunes/Initialize(rite, _allow_repeats)
	if(!isinstrument(parent) && !isliving(parent))
		return COMPONENT_INCOMPATIBLE
	allow_repeats = _allow_repeats
	if(istype(rite, /datum/religion_rites/song_tuner))
		linked_songtuner_rite = rite

	RegisterSignal(parent, COMSIG_SONG_START,.proc/timetosing)
	RegisterSignal(parent, COMSIG_SONG_END, .proc/stopsinging)
	if(!allow_repeats)
		RegisterSignal(parent, COMSIG_SONG_REPEAT, .proc/stopsinging)


///Initiates the effect when the song begins playing.
/datum/component/smooth_tunes/proc/timetosing(atom/A, datum/song/S)
	if(linked_songtuner_rite)
		START_PROCESSING(SSobj, src) //even though WE aren't an object, our parent is!
		if(linked_songtuner_rite.visible_message)
			S.instrumentObj?.visible_message(linked_songtuner_rite.visible_message)
	if(S)
		linked_song = S

///Ends the effect when the song is no longer playing.
/datum/component/smooth_tunes/proc/stopsinging()
	STOP_PROCESSING(SSobj, src)
	linked_song = null
	qdel(linked_songtuner_rite)

/datum/component/smooth_tunes/process()
	if(linked_songtuner_rite)
		linked_songtuner_rite.song_effect(parent, linked_song)
	else
		stopsinging()
