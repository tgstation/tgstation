/// The words (or tones really) the gizmo voice interface can listen for
GLOBAL_LIST_INIT(gizmo_words, world.file2list("strings/gizmo_words.txt"))

/// Listen to the tones and send the sequence to the puzzle datum
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

/// Pick the activate keywords
/datum/component/gizmo_voice/proc/generate_active_words()
	var/list/possible_words = GLOB.gizmo_words.Copy()
	for(var/i in 1 to puzzle.cryptic_pulse.len)
		active_words += pick_n_take(possible_words)

/// Listen to a message, and pick out the puzzle words
/datum/component/gizmo_voice/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	if(hearing_args[HEARING_SPEAKER] == parent)
		return

	var/haystack = hearing_args[HEARING_RAW_MESSAGE]
	var/list/text_position_index = list()

	for(var/needle in active_words)
		var/position = 1
		// we can have multiple of the same keyword in one sequence
		for(var/i in 1 to puzzle.code_length)
			position = findtext(haystack, needle, position)

			if(!position)
				break

			text_position_index[needle] = position
			// So for the next loop we dont find the exact same word again
			position++

	if(!text_position_index.len)
		return

	text_position_index = sortTim(text_position_index, associative = TRUE)
	for(var/thing in text_position_index)
		// Only one solved per speech packet
		if(puzzle.on_pulse(active_words.Find(thing), hearing_args[HEARING_SPEAKER], parent) == GIZMO_PUZZLE_SOLVED)
			return
