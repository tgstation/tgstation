/datum/component/smooth_tunes
	///if applied due to a rite, we link it here
	var/datum/religion_rites/song_tuner/linked_songtuner_rite
	///linked song
	var/datum/song/linked_song
	///if repeats count as continuations instead of a song's end, TRUE
	var/allow_repeats = TRUE

/datum/component/smooth_tunes/Initialize(linked_songtuner_rite, allow_repeats)
	if(!isinstrument(parent) && !isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.allow_repeats = allow_repeats
	if(istype(linked_songtuner_rite, /datum/religion_rites/song_tuner))
		src.linked_songtuner_rite = linked_songtuner_rite

/datum/component/smooth_tunes/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SONG_START,.proc/timetosing)
	RegisterSignal(parent, COMSIG_SONG_END, .proc/stopsinging)
	if(!allow_repeats)
		RegisterSignal(parent, COMSIG_SONG_REPEAT, .proc/stopsinging)

/datum/component/smooth_tunes/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_SONG_START,
		COMSIG_SONG_END,
		COMSIG_SONG_REPEAT,
	))

///Initiates the effect when the song begins playing.
/datum/component/smooth_tunes/proc/timetosing(datum/source, datum/song/starting_song)
	if(linked_songtuner_rite)
		START_PROCESSING(SSobj, src) //even though WE aren't an object, our parent is!
		if(linked_songtuner_rite.visible_message)
			starting_song.parent?.visible_message(linked_songtuner_rite.visible_message)
	if(starting_song)
		linked_song = starting_song

///Ends the effect when the song is no longer playing.
/datum/component/smooth_tunes/proc/stopsinging(datum/source)
	STOP_PROCESSING(SSobj, src)
	linked_song = null
	qdel(linked_songtuner_rite)

/datum/component/smooth_tunes/process(delta_time = SSOBJ_DT)
	if(linked_songtuner_rite)
		linked_songtuner_rite.song_effect(parent, linked_song)
	else
		stopsinging()
