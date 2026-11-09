/// The words (or tones really) the gizmo voice interface can listen for. Limit to 2 characters (or it breaks because im cringe)
GLOBAL_LIST_INIT(gizmo_words, world.file2list("strings/gizmo_words.txt"))

/// Listen to the tones and send the sequence to the puzzle datum
/datum/component/gizmo_voice
	var/datum/gizmo_puzzle/puzzle
	/// they're not really words but you get it
	var/static/list/active_words = list()

/datum/component/gizmo_voice/Initialize(datum/gizmo_puzzle/puzzle)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/movable = parent
	movable.become_hearing_sensitive(type)
	RegisterSignal(movable, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

	src.puzzle = puzzle

	if(!active_words.len)
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

			/// needle + position because assocs need to be unique, we splice it away later when sending it
			text_position_index[needle + "[position]"] = position
			// So for the next loop we dont find the exact same word again
			position++

	if(!text_position_index.len)
		return

	text_position_index = sortTim(text_position_index, associative = TRUE)
	for(var/thing, position in text_position_index)
		// Only send feedback for the last speech packet
		var/no_feedback = text_position_index.Find(thing) != text_position_index.len
		// When solved, accept no further packets from this
		if(puzzle.on_pulse(active_words.Find(copytext(thing, 1, 3)), hearing_args[HEARING_SPEAKER], parent, no_feedback = no_feedback) == GIZMO_PUZZLE_SOLVED)
			return
