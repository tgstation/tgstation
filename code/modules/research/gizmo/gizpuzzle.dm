/datum/gizmo_puzzle
	var/complexity

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

/datum/gizmo_puzzle/New()
	return ..()

/datum/gizmo_puzzle/proc/generate_code_sequences(list/_solution_callbacks)
	solution_callbacks = _solution_callbacks
	code_sequences = list()

	for(var/i in 1 to solution_callbacks.len)
		code_sequences += list(list())
		for(var/j in 1 to code_length)
			code_sequences[i] += pick(cryptic_pulse)

/datum/gizmo_puzzle/proc/on_pulse(pulse_number, mob/living/user, atom/movable/holder)
	current_sequence += cryptic_pulse[pulse_number]

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
				break

	if(succeeded)
		holder.balloon_alert(user, "ping")
		playsound(holder, 'sound/machines/ping.ogg', 30, FALSE)

	else
		holder.balloon_alert(user, "buzz")
		playsound(holder, 'sound/machines/buzz/buzz-sigh.ogg', 30, FALSE)
		current_sequence.Cut()
