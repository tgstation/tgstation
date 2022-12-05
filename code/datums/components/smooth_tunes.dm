///how many lines multiplied by tempo should at least be higher than this.
#define LONG_ENOUGH_SONG 220

///Smooth tunes component! Applied to musicians to give the songs they play special effects, according to a rite!
///Comes with BARTICLES!!!
/datum/component/smooth_tunes
	///if applied due to a rite, we link it here
	var/datum/religion_rites/song_tuner/linked_songtuner_rite
	///linked song
	var/datum/song/linked_song
	///if repeats count as continuations instead of a song's end, TRUE
	var/allow_repeats = TRUE
	///particles to apply, if applicable
	var/particles_path
	///the particle holder of the particle path (created when song starts) ((no i cant think of a better var name because i made the typepath and im perfect))
	var/obj/effect/abstract/particle_holder/particle_holder
	///a funny little glow applied to the instrument while playing
	var/glow_color
	///whether to call the rite's finish effect, only true when the song is long enough
	var/viable_for_final_effect = FALSE

/datum/component/smooth_tunes/Initialize(linked_songtuner_rite, allow_repeats, particles_path, glow_color)
	if(!isinstrument(parent) && !isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.linked_songtuner_rite = linked_songtuner_rite
	src.allow_repeats = allow_repeats
	src.particles_path = particles_path
	src.glow_color = glow_color

/datum/component/smooth_tunes/Destroy(force, silent)
	if(particle_holder)
		QDEL_NULL(particle_holder)
	qdel(linked_songtuner_rite)
	return ..()

/datum/component/smooth_tunes/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_STARTING_INSTRUMENT, PROC_REF(start_singing))

/datum/component/smooth_tunes/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_STARTING_INSTRUMENT)

///Initiates the effect when the song begins playing.
/datum/component/smooth_tunes/proc/start_singing(datum/source, datum/song/starting_song)
	SIGNAL_HANDLER
	if(!starting_song)
		return
	if(istype(starting_song.parent, /obj/structure/musician))
		return //TODO: make stationary instruments work with no hiccups

	if(starting_song.lines.len * starting_song.tempo > LONG_ENOUGH_SONG)
		viable_for_final_effect = TRUE
	else
		to_chat(parent, span_warning("This song is too short, so it won't include the song finishing effect."))

	START_PROCESSING(SSobj, src) //even though WE aren't an object, our parent is!
	if(linked_songtuner_rite.song_start_message)
		starting_song.parent.visible_message(linked_songtuner_rite.song_start_message)

	///prevent more songs from being blessed concurrently, mob signal
	UnregisterSignal(parent, COMSIG_ATOM_STARTING_INSTRUMENT)
	///and hook into the instrument this time, preventing other weird exploity stuff.
	RegisterSignal(starting_song.parent, COMSIG_INSTRUMENT_TEMPO_CHANGE, PROC_REF(tempo_change))
	RegisterSignal(starting_song.parent, COMSIG_INSTRUMENT_END, PROC_REF(stop_singing))
	if(!allow_repeats)
		RegisterSignal(starting_song.parent, COMSIG_INSTRUMENT_REPEAT, PROC_REF(stop_singing))

	linked_song = starting_song

	//barticles
	if(particles_path && ismovable(linked_song.parent))
		particle_holder = new(linked_song.parent, particles_path)
	//filters
	linked_song.parent?.add_filter("smooth_tunes_outline", 9, list("type" = "outline", "color" = glow_color))

///Prevents changing tempo during a song to sneak in final effects quicker

/datum/component/smooth_tunes/proc/tempo_change(datum/source, datum/song/modified_song)
	SIGNAL_HANDLER
	if(modified_song.playing && viable_for_final_effect)
		to_chat(parent, span_warning("Modifying the song mid-performance has removed your ability to perform the song finishing effect."))
		viable_for_final_effect = FALSE

///Ends the effect when the song is no longer playing.
/datum/component/smooth_tunes/proc/stop_singing(datum/source, finished)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	if(viable_for_final_effect)
		if(finished && linked_songtuner_rite && linked_song)
			for(var/mob/living/carbon/human/listener in linked_song.hearing_mobs)
				if(listener == parent || listener.can_block_magic(MAGIC_RESISTANCE_HOLY, charge_cost = 1))
					continue

				linked_songtuner_rite.finish_effect(listener, parent)
		else
			to_chat(parent, span_warning("The song was interrupted, you cannot activate the finishing ability!"))

	linked_song.parent?.remove_filter("smooth_tunes_outline")
	UnregisterSignal(linked_song.parent, list(
		COMSIG_INSTRUMENT_TEMPO_CHANGE,
		COMSIG_INSTRUMENT_END,
		COMSIG_INSTRUMENT_REPEAT,
	))
	linked_song = null
	qdel(src)

/datum/component/smooth_tunes/process(delta_time = SSOBJ_DT)
	if(linked_songtuner_rite && linked_song)
		for(var/mob/living/carbon/human/listener in linked_song.hearing_mobs)
			if(listener == parent || listener.can_block_magic(MAGIC_RESISTANCE_HOLY, charge_cost = 0))
				continue

			linked_songtuner_rite.song_effect(listener, parent)
	else
		stop_singing()

#undef LONG_ENOUGH_SONG
