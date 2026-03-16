GLOBAL_LIST_INIT(gizmo_words, world.file2list("strings/gizmo_words.txt"))

/datum/component/gizmo_voice
	var/datum/gizmo_puzzle/puzzle
	/// they're not really words but you get it
	var/list/active_words = list()


/datum/component/gizmo_voice/Initialize(datum/gizmo_puzzle/_puzzle)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/movable = parent
	movable.become_hearing_sensitive(type)
	RegisterSignal(movable, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

	puzzle = _puzzle
	generate_active_words()

/datum/component/gizmo_voice/proc/generate_active_words()
	var/list/possible_words = GLOB.gizmo_words.Copy()
	for(var/i in 1 to puzzle.cryptic_pulse.len)
		active_words += pick_n_take(possible_words)

/datum/component/gizmo_voice/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	if(hearing_args[HEARING_SPEAKER] == parent)
		return

	var/haystack = hearing_args[HEARING_RAW_MESSAGE]
	var/list/text_position_index = list()
	for(var/needle in active_words)
		var/position = findtext(haystack, needle)
		// fix having multiple same keywords in a sleuth
		if(!position)
			continue

		text_position_index[needle] = position

	if(!text_position_index.len)
		return

	text_position_index = sortTim(text_position_index, associative = TRUE)
	for(var/THING in text_position_index)
		puzzle.on_pulse(active_words.Find(THING), hearing_args[HEARING_SPEAKER], parent)
