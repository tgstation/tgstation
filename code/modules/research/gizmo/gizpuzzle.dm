/// Holds the puzzle sequences, receives the pulses, decides if theyre correct, and gives feedback and calls the right callbacks when it does
/datum/gizmo_puzzle
	/// The wires we need to pulse for cracking the code
	var/list/cryptic_pulse = list(
		GIZMO_PULSE_1,
		GIZMO_PULSE_2,
		GIZMO_PULSE_3,
		GIZMO_PULSE_4,
		GIZMO_PULSE_5,
		GIZMO_PULSE_6,
		GIZMO_PULSE_7,
		GIZMO_PULSE_8,
	)

	/// How long a code sequence can be
	var/code_length = 3
	/// The codes that got generated, formatted as (1 = list(CRYPTIC_WIRE_5, CRYPTIC_WIRE_3, CRYPTIC_WIRE_7, 2 = list(...)))
	var/list/code_sequences
	/// The current sequence we're on. Will reset if it doesn't match anything
	var/list/current_sequence = list()
	/// List of callbacks that the solutions will call on succes
	var/list/solution_callbacks

	/// For if you want something to happen on merely being pulsed. If null, simply ping, bleep and creak or whatever as feedback
	var/datum/callback/pulsed_callback

	COOLDOWN_DECLARE(feedback_cooldown)
	/// So the ping buzz feedback doesnt spam too much
	var/feedback_cooldown_time = 0.2 SECONDS

/datum/gizmo_puzzle/New(datum/callback/pulsed)
	if(pulsed)
		pulsed_callback = pulsed
	else
		pulsed_callback = CALLBACK(src, PROC_REF(default_on_pulsed))
	return ..()

/// Make up a sequence
/datum/gizmo_puzzle/proc/generate_code_sequences(list/solution_callbacks)
	src.solution_callbacks = solution_callbacks
	code_sequences = list()

	for(var/i in 1 to solution_callbacks.len)
		code_sequences += list(list())
		for(var/j in 1 to code_length)
			code_sequences[i] += pick(cryptic_pulse)

/// Whenever a puzzle attempt is made
/datum/gizmo_puzzle/proc/on_pulse(pulse_number, mob/living/user, atom/movable/holder, no_feedback = FALSE)
	current_sequence += cryptic_pulse[pulse_number]
	. = GIZMO_PUZZLE_CORRECT

	var/succeeded = FALSE

	for(var/i in 1 to code_sequences.len)
		var/list/a = code_sequences[i]
		for(var/j in 1 to current_sequence.len)
			if(current_sequence[j] != a[j])
				break
			if(current_sequence.len == j)
				succeeded = TRUE
			if(j == a.len)
				var/datum/callback/callback = solution_callbacks[i]
				callback.Invoke(holder)
				current_sequence.Cut()
				. = GIZMO_PUZZLE_SOLVED
				break

	if(!succeeded)
		current_sequence.Cut()
		. = GIZMO_PUZZLE_WRONG

	pulsed_callback?.Invoke(holder, user, ., no_feedback)

/// Just some feedback so people can start forcing sequences. No feedback if it's done automatically
/datum/gizmo_puzzle/proc/default_on_pulsed(atom/movable/holder, mob/living/user, solved_type, no_feedback = FALSE)
	if(!COOLDOWN_FINISHED(src, feedback_cooldown) || !isliving(user) || no_feedback)
		return

	COOLDOWN_START(src, feedback_cooldown, feedback_cooldown_time)

	switch(solved_type)
		if(GIZMO_PUZZLE_WRONG)
			holder.balloon_alert(user, "buzz")
			playsound(holder, 'sound/machines/buzz/buzz-sigh.ogg', 30, FALSE)
		if(GIZMO_PUZZLE_CORRECT)
			holder.balloon_alert(user, "ping")
			playsound(holder, 'sound/machines/ping.ogg', 30, FALSE)
		if(GIZMO_PUZZLE_SOLVED)
			holder.balloon_alert(user, "creak")
			playsound(holder, 'sound/machines/creak.ogg', 30, FALSE)
