/// Handles the guessing aspect of the gizmo.
/datum/gizmo_puzzle_handler
    /// Possible wire numbers we can trigger.
    var/list/possible_wire_numbers = list("1", "2", "3", "4", "5", "6", "7", "8")
    /// The current guessing progress.
    var/entered_sequence = ""
    /// How long can a code sequence be.
    var/sequence_size = DEFAULT_SEQUENCE_SIZE

    /// Generated sequences (maps sequence_string -> gizmo_effect_combination).
    var/list/code_sequences = list()
    /// List of callbacks that the solutions will call on success (maps gizmo_effect_combination -> callback).
    var/list/solution_callbacks

    /// Additional feedback on getting pulsed.
    var/datum/callback/pulsed_callback
    /// Interaction cooldown
    var/feedback_cooldown_time = DEFAULT_FEEDBACK_COOLDOWN

    COOLDOWN_DECLARE(feedback_cooldown)

/datum/gizmo_puzzle_handler/New(datum/callback/pulsed)
    if(pulsed)
        pulsed_callback = pulsed
    else
        pulsed_callback = CALLBACK(src, PROC_REF(default_on_pulsed))
    return ..()

/// Generate a sequence that will serve as a key to the list of possible interactions.
/datum/gizmo_puzzle_handler/proc/generate_code_sequences(list/new_solution_callbacks)
    solution_callbacks = new_solution_callbacks

    for(var/datum/gizmo_effect_combination/this_gizmo_mode in solution_callbacks)
        var/sequence_string = ""
        for(var/i in 1 to sequence_size)
            sequence_string += "[pick(possible_wire_numbers)]"
        code_sequences[sequence_string] = this_gizmo_mode

/// Progresses guessing the sequence or resets the progress if guessed wrong.
/datum/gizmo_puzzle_handler/proc/on_pulse(pulse_number, mob/living/user, atom/movable/holder, no_feedback = FALSE)
    entered_sequence += "[pulse_number]"

    var/succeeded = FALSE
    var/solved = FALSE
    var/datum/gizmo_effect_combination/matched_mode

    for(var/sequence_string in code_sequences)
        if(sequence_string == entered_sequence)
            solved = TRUE
            succeeded = TRUE
            matched_mode = code_sequences[sequence_string]
            break
        if(findtext(sequence_string, entered_sequence) == 1)
            succeeded = TRUE

    if(solved)
        var/datum/callback/callback = solution_callbacks[matched_mode]
        if(callback)
            callback.Invoke(holder)
        if(matched_mode)
            matched_mode.activate(holder)
        entered_sequence = ""
        . = GIZMO_PUZZLE_SOLVED
    else if(succeeded)
        . = GIZMO_PUZZLE_CORRECT
    else
        entered_sequence = ""
        . = GIZMO_PUZZLE_WRONG

    pulsed_callback?.Invoke(holder, user, ., no_feedback)

/datum/gizmo_puzzle_handler/proc/default_on_pulsed(atom/movable/holder, mob/living/user, solved_type, no_feedback = FALSE)
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

/datum/gizmo_puzzle_handler/voice
    sequence_size = VOICE_SEQUENCE_SIZE
