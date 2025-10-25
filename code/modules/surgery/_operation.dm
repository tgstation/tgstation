/// Applies moodlets after the surgical operation is complete
#define OPERATION_AFFECTS_MOOD (1<<0)
/// Notable operations are specially logged and also leave memories
#define OPERATION_NOTABLE (1<<1)
/// Operation will automatically repeat until it can no longer be performed
#define OPERATION_LOOPING (1<<2)
/// Grants a speed bonus if the user is morbid and their tool is morbid
#define OPERATION_MORBID (1<<3)
/// Not innately available to doctors, must be added via COMSIG_MOB_ATTEMPT_SURGERY to show up
#define OPERATION_LOCKED (1<<4)
/// A surgeon can perform this operation on themselves
#define OPERATION_SELF_OPERABLE (1<<5)
/// Operation can be performed on standing patients
#define OPERATION_STANDING_ALLOWED (1<<6)
/// Normally operations cannot be failed by silicons, but this flag allows for failure chances to be applied to silicons as well
#define OPERATION_SILICON_CAN_FAIL (1<<7)
/// If set, the operation will ignore clothing when checking for access to the target body part.
#define OPERATION_IGNORE_CLOTHES (1<<8)

// Mood defines
#define SURGERY_STATE_STARTED "surgery_started"
#define SURGERY_STATE_FAILURE "surgery_failed"
#define SURGERY_STATE_SUCCESS "surgery_success"
#define SURGERY_MOOD_CATEGORY "surgery"

/// Dummy "tool" for surgeries which use hands
#define IMPLEMENT_HAND "hands"

/// Surgery speed modifiers are soft-capped at this value
/// The actual modifier can exceed this but it gets
#define SURGERY_MODIFIER_FAILURE_THRESHOLD 2.5
/// There is an x percent chance of failure per second beyond 2.5x the base surgery time
#define FAILURE_CHANCE_PER_SECOND 10
/// Calculates failure chance based on expected time and the actual time
#define FAILURE_CHANCE(threshold_time, real_time) (FAILURE_CHANCE_PER_SECOND * (((real_time) - (threshold_time)) / (1 SECONDS)))

/// All operation singletons indexed by typepath
GLOBAL_LIST_INIT(operations, init_subtypes_w_path_keys(/datum/surgery_operation))

/// Attempts to perform a surgery with whatever tool is passed
/mob/living/proc/perform_surgery(mob/living/patient, obj/item/potential_tool = IMPLEMENT_HAND)
	if(combat_mode)
		return NONE

	var/list/possible_operations = list()
	for(var/datum/surgery_operation/operation_type as anything in GLOB.operations)
		if(operation_type::operation_flags & OPERATION_LOCKED)
			continue
		possible_operations += operation_type

	// Signals can add operation types
	SEND_SIGNAL(src, COMSIG_LIVING_OPERATING_ON, patient, possible_operations)
	SEND_SIGNAL(patient, COMSIG_LIVING_BEING_OPERATED_ON, patient, possible_operations)

	var/list/operations = list()
	var/list/radial_operations = list()
	for(var/operation_type in possible_operations)
		var/datum/surgery_operation/operation = GLOB.operations[operation_type]
		if(!(operation.operation_flags & OPERATION_STANDING_ALLOWED) && patient.body_position != LYING_DOWN)
			continue
		if(!(operation.operation_flags & OPERATION_SELF_OPERABLE) && patient == src && !HAS_TRAIT(src, TRAIT_SELF_SURGERY))
			continue
		if(operation.replaced_by && (operation.replaced_by in possible_operations))
			continue
		var/atom/movable/operate_on = operation.get_operation_target(src, patient, potential_tool)
		if(isnull(operate_on))
			continue
		if(!operation.check_availability(operate_on, src, potential_tool))
			continue
		for(var/datum/radial_menu_choice/radial_slice, option_info in operation.get_radial_options(operate_on, src, potential_tool))
			if(radial_operations[radial_slice])
				stack_trace("Duplicate radial surgery option '[radial_slice.name]' detected for operation '[operation_type]'.")
				continue
			operations[radial_slice] = list("operation" = operation, "target" = operate_on) + option_info
			radial_operations[radial_slice] = radial_slice

	if(!length(operations))
		return NONE // allow attacking

	sortTim(radial_operations, GLOBAL_PROC_REF(cmp_name_asc))

	var/picked = show_radial_menu(
		user = src,
		anchor = patient,
		choices = radial_operations,
		require_near = TRUE,
		autopick_single_option = TRUE,
		radius = 56,
		custom_check = CALLBACK(src, PROC_REF(surgery_check), potential_tool),
	)
	if(!picked)
		return ITEM_INTERACT_BLOCKING // cancelled

	var/datum/surgery_operation/picked_operation = operations[picked]["operation"]
	return picked_operation.try_perform(operations[picked]["target"], src, potential_tool, operations[picked])

/// Callback for checking if the surgery radial can be kept open
/mob/living/proc/surgery_check(obj/item/tool)
	PRIVATE_PROC(TRUE)
	if(!is_holding(tool))
		return FALSE
	return TRUE

/datum/surgery_operation
	/// Name of the operation
	var/name = "surgery operation"
	/// Description of the operation, keep it short
	var/desc = "A surgery operation that can be performed on a bodypart."

	/// What tool(s) are needed to perform this operation
	var/list/implements
	/// How long to perform this operation
	var/time = 1 SECONDS

	var/operation_flags = NONE

	/// Typepath of a surgical operation that supersedes this one
	var/replaced_by

	/// SFX played before the do-after begins
	var/preop_sound
	/// SFX played on success, after the do-after
	var/success_sound
	/// SFX played on failure, after the do-after
	var/failure_sound

	/// Option displayed when this operation is available
	VAR_PRIVATE/datum/radial_menu_choice/main_option

	///Which mood event to give the patient when surgery is starting while they're conscious. This should be permanent/not have a timer until the surgery either succeeds or fails, as those states will immediately replace it. Mostly just flavor text.
	var/datum/mood_event/surgery/surgery_started_mood_event = /datum/mood_event/surgery
	///Which mood event to give the conscious patient when surgery succeeds. Lasts far shorter than if it failed.
	var/datum/mood_event/surgery/surgery_success_mood_event = /datum/mood_event/surgery/success
	///Which mood event to give the consious patient when surgery fails. Lasts muuuuuch longer.
	var/datum/mood_event/surgery/surgery_failure_mood_event = /datum/mood_event/surgery/failure

/**
 * Checks to see if this operation can be performed
 * This is the main entry point for checking availability
 */
/datum/surgery_operation/proc/check_availability(atom/movable/operating_on, mob/living/surgeon, tool)

	var/mob/living/patient = get_patient(operating_on)

	if(isnull(patient))
		return FALSE

	if(!get_tool_quality(tool))
		return FALSE

	if(!is_available(operating_on))
		return FALSE

	if(!(operation_flags & OPERATION_IGNORE_CLOTHES) && !patient.is_location_accessible(get_working_zone(operating_on)))
		return FALSE

	return TRUE

/**
 * Returns the quality of the passed tool for this operation
 * Quality directly affects the time taken to perform the operation
 *
 * 0 = unusable
 * 1 = standard quality
 */
/datum/surgery_operation/proc/get_tool_quality(tool = IMPLEMENT_HAND)
	if(!length(implements))
		return 1
	if(istype(tool, /obj/item/borg/cyborghug))
		tool = IMPLEMENT_HAND // melbert todo
	if(!tool_check(tool))
		return 0
	if(!isitem(tool))
		return implements[tool]

	var/obj/item/realtool = tool
	return (1 / realtool.toolspeed) * (implements[realtool.tool_behaviour] || is_type_in_list(realtool, implements, zebra = TRUE) || 0)

/**
 * Return an assoc list or a list of radial slices to display when this operation is available
 *
 * Operations are "available" if they pass the check_availability() check, ie the bodypart is in a correct state
 *
 * By default it returns a single option with the operation name and description,
 * but you can override this proc to return multiple options for one operation, like selecting which organ to operate on.
 */
/datum/surgery_operation/proc/get_radial_options(atom/movable/operating_on, mob/living/surgeon, obj/item/tool)
	if(!main_option)
		main_option = new()
		main_option.image = get_default_radial_image(operating_on, surgeon, tool)
		main_option.name = name
		main_option.info = desc

	var/list/result = list()
	result[main_option] = list("action" = "default")
	return result

/**
 * Checks to see if this operation can be performed
 * You can override this to add more specific checks, such as if a tool can be used on the target
 * or if the surgeon has a specific trait / skill
 *
 * Don't call this, call check_availability() instead
 */
/datum/surgery_operation/proc/is_available(atom/movable/operating_on, mob/living/surgeon, obj/item/tool)
	return TRUE

/**
 * Checks to see if the provided tool is valid for this operation
 * You can override this to add more specific checks, such as checking sharpness
 *
 * Tool is only asserted to be an item if IMPLEMENT_HAND is not used
 */
/datum/surgery_operation/proc/tool_check(tool)
	return TRUE

/**
 * Returns the name of whatever tool is recommended for this operation, such as "hemostat"
 */
/datum/surgery_operation/proc/get_recommended_tool()
	if(!length(implements))
		return null
	var/recommendation = implements[1]
	if(istext(recommendation))
		return recommendation
	if(ispath(recommendation, /obj/item))
		var/obj/item/tool = recommendation
		return tool::name
	return null

/// Returns what icon this surgery uses by default on the radial wheel, if it doesn't implement its own radial options
/datum/surgery_operation/proc/get_default_radial_image(atom/movable/operating_on, mob/living/surgeon, obj/item/tool)
	return image(icon = 'icons/effects/random_spawners.dmi', icon_state = "questionmark")

/**
 * Helper for constructing overlays to apply to a radial image
 *
 * Input can be
 * * - An atom typepath
 * * - An atom instance
 * * - Another image
 *
 * Returns a list of images
 */
/datum/surgery_operation/proc/add_radial_overlays(list/overlay_icons)
	if(!islist(overlay_icons))
		overlay_icons = list(overlay_icons)

	var/list/created_list = list()
	for(var/input in overlay_icons)
		var/image/created = isimage(input) ? input : image(input)
		created.layer = FLOAT_LAYER
		created.plane = FLOAT_PLANE
		created.pixel_w = 0
		created.pixel_x = 0
		created.pixel_y = 0
		created.pixel_z = 0
		created_list += created

	return created_list


/**
 * Collates all time modifiers for this operation and returns the final modifier
 */
/datum/surgery_operation/proc/get_time_modifiers(atom/movable/operating_on, mob/living/surgeon, tool)
	var/total_mod = 1.0
	total_mod *= get_tool_quality(tool) || 1.0
	if(!iscyborg(surgeon))
		var/mob/living/patient = get_patient(operating_on)
		total_mod *= get_location_modifier(get_turf(patient))
		total_mod *= get_morbid_modifier(surgeon, tool)
		total_mod *= get_mob_surgery_speed_mod(patient)
		// Using TRAIT_SELF_SURGERY on a surgery which doesn't normally allow self surgery imparts a penalty
		if(patient == surgeon && HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY) && !(operation_flags & OPERATION_SELF_OPERABLE))
			total_mod *= 1.5
	// modifiers are expressed as fractions of the base time - ie, 1.2x = 1.2x faster surgery
	// but since we're multiplying time, we invert here - ie, 1.2x = 0.83x smaller time
	return round(1.0 / total_mod, 0.01)

/// Returns a time modifier for morbid operations
/datum/surgery_operation/proc/get_morbid_modifier(mob/living/surgeon, obj/item/tool)
	if(!(operation_flags & OPERATION_MORBID))
		return 1.0
	if(!HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		return 1.0
	if(!isitem(tool) || !(tool.item_flags & CRUEL_IMPLEMENT))
		return 1.0

	return 0.7

/// Returns a time modifier based on the mob's status
/datum/surgery_operation/proc/get_mob_surgery_speed_mod(mob/living/patient)
	var/basemod = patient.mob_surgery_speed_mod
	if(HAS_TRAIT(patient, TRAIT_SURGICALLY_ANALYZED))
		basemod *= 0.8
	if(HAS_TRAIT(patient, TRAIT_ANALGESIA))
		basemod *= 0.8
	return basemod

/// Gets the surgery speed modifier for a given mob, based off what sort of table/bed/whatever is on their turf.
/datum/surgery_operation/proc/get_location_modifier(turf/operation_turf)
	// Technically this IS a typecache, just not the usual kind :3
	var/static/list/modifiers = zebra_typecacheof(list(
		/obj/structure/table = 0.8,
		/obj/structure/table/optable = 1.0,
		/obj/structure/table/optable/abductor = 1.2,
		/obj/machinery/stasis = 0.9,
		/obj/structure/bed = 0.7,
	))
	var/mod = 0.5
	for(var/obj/thingy in operation_turf)
		mod = max(mod, modifiers[thingy.type])
	return mod

/**
 * Gets what movable is being operated on by a surgeon during this operation
 * Determines what gets passed into the try_perform() proc
 * If null is returned, the operation cannot be performed
 *
 * * surgeon - The mob performing the operation
 * * patient - The mob being operated on
 * * tool - The tool being used to perform the operation
 *
 * Returns the atom/movable being operated on
 */
/datum/surgery_operation/proc/get_operation_target(mob/living/surgeon, mob/living/patient, obj/item/tool = IMPLEMENT_HAND)
	return patient

/**
 * The actual chain of performing the operation
 *
 * * operating_on - The atom being operated on, probably a bodypart or occasionally a mob directly
 * * surgeon - The mob performing the operation
 * * tool - The tool being used to perform the operation. CAN BE A STRING, ie, IMPLEMENT_HAND, be careful
 * * operation_args - Additional arguments passed from the radial menu selection
 *
 * Returns an item interaction flag - intended to be invoked from the interaction chain
 */
/datum/surgery_operation/proc/try_perform(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args = list())
	if(!check_availability(operating_on, surgeon, tool))
		return ITEM_INTERACT_BLOCKING

	if(!start_operation(operating_on, surgeon, tool, operation_args))
		return ITEM_INTERACT_BLOCKING

	var/mob/living/patient = get_patient(operating_on)
	var/was_sleeping = (patient.stat != DEAD && HAS_TRAIT(patient, TRAIT_KNOCKEDOUT))
	var/result = NONE

	update_surgery_mood(patient, SURGERY_STATE_STARTED)
	SEND_SIGNAL(patient, COMSIG_LIVING_SURGERY_STARTED, src, operating_on, tool)

	do
		operation_args["speed_modifier"] = get_time_modifiers(operating_on, surgeon, tool)
		var/modified_time = time * operation_args["speed_modifier"]
		var/failure_threshold = time * SURGERY_MODIFIER_FAILURE_THRESHOLD

		if(!do_after(
			user = surgeon,
			// Actual delay is capped  - think of the excess time as being added to failure chance instead
			delay = min(expected_time, modified_time),
			target = patient,
			extra_checks = CALLBACK(src, PROC_REF(operate_check), operating_on, surgeon, tool, operation_args),
			// You can only operate on one mob at a time without a hippocratic oath
			interaction_key = HAS_TRAIT(surgeon, TRAIT_HIPPOCRATIC_OATH) ? target : DOAFTER_SOURCE_SURGERY,
		))
			result |= ITEM_INTERACT_BLOCKING
			update_surgery_mood(patient, SURGERY_STATE_FAILURE)
			break

		if(ishuman(surgeon))
			var/mob/living/carbon/human/surgeon_human = surgeon
			surgeon_human.add_blood_DNA_to_items(patient.get_blood_dna_list(), ITEM_SLOT_GLOVES)
		else
			surgeon.add_mob_blood(patient)

		if(isitem(tool))
			var/obj/item/realtool = tool
			realtool.add_mob_blood(patient)

		// Now we calculate failure chance based on how long we exceeded intended operation time
		var/failure_modifier = 0
		// Using TRAIT_SELF_SURGERY on a surgery which doesn't normally allow self surgery imparts a penalty
		if(patient == surgeon && HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY) && !(operation_flags & OPERATION_SELF_OPERABLE))
			failure_modifier += 15
		// Cyborgs can't fail surgeries that don't have OPERATION_SILICON_CAN_FAIL
		if(iscyborg(surgeon) && !(operation_flags & OPERATION_SILICON_CAN_FAIL))
			failure_modifier = -INFINITY

		// This may look something like: 4 seconds - 2.5 seconds = 1.5 seconds * 10 = 15% failure chance
		if(prob(clamp(FAILURE_CHANCE(failure_threshold, modified_time) + failure_modifier, 0, 99)))
			failure(operating_on, surgeon, tool, operation_args, speed_modifier)
			result |= ITEM_INTERACT_FAILURE
			update_surgery_mood(patient, SURGERY_STATE_FAILURE)
		else
			success(operating_on, surgeon, tool, operation_args)
			result |= ITEM_INTERACT_SUCCESS
			update_surgery_mood(patient, SURGERY_STATE_SUCCESS)


	while ((operation_flags & OPERATION_LOOPING) && can_loop(operating_on, surgeon, tool, operation_args))

	SEND_SIGNAL(patient, COMSIG_LIVING_SURGERY_FINISHED, src, operating_on, tool)

	if(patient.stat == DEAD && was_sleeping)
		surgeon.client?.give_award(/datum/award/achievement/jobs/sandman, surgeon)

	return result

/// Called after an operation to check if it can be repeated/looped
/datum/surgery_operation/proc/can_loop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	return operate_check(operating_on, surgeon, tool, operation_args)

/// Called during the do-after to check if the operation can continue
/datum/surgery_operation/proc/operate_check(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	return check_availability(operating_on, surgeon, tool)

/**
 * Allows for any extra checks or setup when the operation starts
 * If you want user input before for an operation, do it here
 *
 * This proc can sleep, sanity checks are automatically performed after it completes
 *
 * Return FALSE to cancel the operation
 * Return TRUE to continue
 */
/datum/surgery_operation/proc/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	return TRUE

/// Used to display messages to the surgeon and patient
/datum/surgery_operation/proc/display_results(mob/living/surgeon, mob/living/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	surgeon.visible_message(detailed_message, self_message, vision_distance = 1, ignored_mobs = target_detailed ? null : target)
	if(target_detailed)
		return
	var/you_feel = pick("a brief pain", "your body tense up", "an unnerving sensation")
	if(!vague_message)
		if(detailed_message)
			stack_trace("DIDN'T GET PASSED A VAGUE MESSAGE.")
			vague_message = detailed_message
		else
			stack_trace("NO MESSAGES TO SEND TO TARGET!")
			vague_message = span_notice("You feel [you_feel] as you are operated on.")
	target.show_message(vague_message, MSG_VISUAL, span_notice("You feel [you_feel] as you are operated on."))

/// Display pain message to the target based on their traits and condition
/datum/surgery_operation/proc/display_pain(mob/living/target, pain_message, mechanical_surgery = FALSE)
	if(!pain_message)
		return

	// Determine how drunk our patient is
	var/drunken_patient = target.get_drunk_amount()
	// Create a probability to ignore the pain based on drunkenness level
	var/drunken_ignorance_probability = clamp(drunken_patient, 0, 90)

	if(target.stat >= UNCONSCIOUS || HAS_TRAIT(target, TRAIT_KNOCKEDOUT))
		return
	if(HAS_TRAIT(target, TRAIT_ANALGESIA) || drunken_patient && prob(drunken_ignorance_probability))
		to_chat(target, span_notice("You feel a dull, numb sensation as your body is surgically operated on."))
		return
	to_chat(target, span_userdanger(pain_message))
	if(prob(30) && !mechanical_surgery)
		target.emote("scream")

/// Plays a sound for the operation based on the tool used
/datum/surgery_operation/proc/play_operation_sound(atom/movable/operating_on, mob/living/surgeon, tool, sound_or_sound_list)
	if(!isitem(tool))
		return

	var/sound_to_play
	if(islist(sound_or_sound_list))
		var/list/sounds = sound_or_sound_list
		if(isitem(tool))
			var/obj/item/realtool = tool
			sound_to_play = sounds[realtool.tool_behaviour] || is_type_in_list(realtool, sounds, zebra = TRUE)
		else
			sound_to_play = sounds[tool]
	else
		sound_to_play = sound_or_sound_list

	if(sound_to_play)
		playsound(surgeon, sound_to_play, 50, TRUE)

/// Helper for getting the mob who is ultimately being operated on, given the movable that is truly being operated on.
/// For example in limb surgeries this would return the mob the limb is attached to.
/datum/surgery_operation/proc/get_patient(atom/movable/operating_on) as /mob/living
	return operating_on

/// Helper for getting what body zone we are ultimately operating on, given the movable that is truly being operated on.
/// For example in limb surgeries this would return the body zone of the limb being operated on.
/datum/surgery_operation/proc/get_working_zone(atom/movable/operating_on)
	return BODY_ZONE_CHEST

/// Helper for getting an operating compupter the patient is linked to
/datum/surgery_operation/proc/locate_operating_computer(atom/movable/operating_on)
	var/turf/operating_turf = get_turf(operating_on)
	if(isnull(operating_turf))
		return null

	var/obj/structure/table/optable/operating_table = locate() in operating_turf
	var/obj/machinery/computer/operating/operating_computer = operating_table?.computer

	if(isnull(operating_computer) || (operating_computer.machine_stat & (NOPOWER|BROKEN)))
		return null

	return operating_computer

/// Updates a patient's mood based on the surgery state and their traits
/datum/surgery_operation/proc/update_surgery_mood(mob/living/patient, surgery_state)
	if(!(operation_flags & OPERATION_AFFECTS_MOOD))
		return

	// Create a probability to ignore the pain based on drunkenness level
	var/drunk_ignore_prob = clamp(patient.get_drunk_amount(), 0, 90)

	if(HAS_TRAIT(patient, TRAIT_ANALGESIA) || prob(drunk_ignore_prob))
		patient.clear_mood_event(SURGERY_MOOD_CATEGORY) //incase they gained the trait mid-surgery (or became drunk). has the added side effect that if someone has a bad surgical memory/mood and gets drunk & goes back to surgery, they'll forget they hated it, which is kinda funny imo.
		return
	if(patient.stat >= UNCONSCIOUS)
		var/datum/mood_event/surgery/target_mood_event = patient.mob_mood?.mood_events[SURGERY_MOOD_CATEGORY]
		if(!target_mood_event || target_mood_event.surgery_completed) //don't give sleeping mobs trauma. that said, if they fell asleep mid-surgery after already getting the bad mood, lets make sure they wake up to a (hopefully) happy memory.
			return
	switch(surgery_state)
		if(SURGERY_STATE_STARTED)
			patient.add_mood_event(SURGERY_MOOD_CATEGORY, surgery_started_mood_event)
		if(SURGERY_STATE_SUCCESS)
			patient.add_mood_event(SURGERY_MOOD_CATEGORY, surgery_success_mood_event)
		if(SURGERY_STATE_FAILURE)
			patient.add_mood_event(SURGERY_MOOD_CATEGORY, surgery_failure_mood_event)
		else
			CRASH("passed invalid surgery_state, \"[surgery_state]\".")

/**
 * Called when the operation initiates
 * Don't touch this proc, override on_preop() instead
 */
/datum/surgery_operation/proc/start_operation(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/preop_time = world.time
	var/patient = get_patient(operating_on)
	if(!pre_preop(operating_on, surgeon, tool, operation_args))
		return FALSE
	// if pre_preop slept, sanity check that everything is still valid
	if(preop_time != world.time && (patient != get_patient(operating_on) || !surgeon.Adjacent(patient) || !surgeon.is_holding(tool) || !operate_check(operating_on, surgeon, tool, operation_args)))
		return FALSE

	play_operation_sound(operating_on, surgeon, tool, preop_sound)
	on_preop(operating_on, surgeon, tool, operation_args)
	return TRUE

/**
 * Used to customize behavior when the operation starts
 */
/datum/surgery_operation/proc/on_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/patient = get_patient(operating_on)

	display_results(
		surgeon,
		patient,
		span_notice("You begin to operate on [patient]..."),
		span_notice("[surgeon] begins to operate on [patient]."),
		span_notice("[surgeon] begins to operate on [patient]."),
	)

/**
 * Called when the operation is successful
 * Don't touch this proc, override on_success() instead
 */
/datum/surgery_operation/proc/success(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(operation_flags & OPERATION_NOTABLE)
		SSblackbox.record_feedback("tally", "surgeries_completed", 1, type)
		surgeon.add_mob_memory(/datum/memory/surgery, deuteragonist = surgeon, surgery_type = name)

	SEND_SIGNAL(surgeon, COMSIG_LIVING_SURGERY_SUCCESS, src, operating_on, tool)
	play_operation_sound(operating_on, surgeon, tool, success_sound)
	on_success(operating_on, surgeon, tool, operation_args)

/**
 * Used to customize behavior when the operation is successful
 */
/datum/surgery_operation/proc/on_success(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/patient = get_patient(operating_on)

	display_results(
		surgeon,
		patient,
		span_notice("You succeed."),
		span_notice("[surgeon] succeeds!"),
		span_notice("[surgeon] finishes."),
	)

/**
 * Called when the operation fails
 * Don't touch this proc, override on_failure() instead
 */
/datum/surgery_operation/proc/failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(operation_flags & OPERATION_NOTABLE)
		SSblackbox.record_feedback("tally", "surgeries_failed", 1, type)

	SEND_SIGNAL(surgeon, COMSIG_LIVING_SURGERY_FAILED, src, operating_on, tool)
	play_operation_sound(operating_on, surgeon, tool, failure_sound)
	on_failure(operating_on, surgeon, tool, operation_args)

/**
 * Used to customize behavior when the operation fails
 *
 * total_penalty_modifier is the final modifier applied to the time taken to perform the operation,
 * and it can be interpreted as how badly the operation was performed
 *
 * At its lowest, it will be just above 2.5 (the threshold for success), and can go up to infinity (theoretically)
 */
/datum/surgery_operation/proc/on_failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/patient = get_patient(operating_on)

	var/screwedmessage = ""
	switch(operation_args["speed_modifier"])
		if(2.5 to 3)
			screwedmessage = " You almost had it, though."
		if(3 to 4)
			pass()
		if(4 to 5)
			screwedmessage = " This is hard to get right in these conditions..."
		if(5 to INFINITY)
			screwedmessage = " This is practically impossible in these conditions..."

	display_results(
		surgeon,
		patient,
		span_warning("You screw up![screwedmessage]"),
		span_warning("[surgeon] screws up!"),
		span_notice("[surgeon] finishes."),
		TRUE, //By default the patient will notice if the wrong thing has been cut
	)

/// Simple surgery which works on any mob
/datum/surgery_operation/basic
	/// Biotype required to perform this operation
	var/required_biotype = MOB_ORGANIC

/datum/surgery_operation/basic/check_availability(atom/movable/operating_on, mob/living/surgeon, obj/item/tool)
	SHOULD_NOT_OVERRIDE(TRUE) // you are looking for is_available()

	. = ..()
	if(!.)
		return FALSE

	if(!isliving(operating_on))
		stack_trace("Basic operation being performed on non-living!")
		return FALSE

	var/mob/living/living_target = operating_on
	if(required_biotype && !(living_target.mob_biotypes & required_biotype))
		return FALSE

	return TRUE

/// Gets either the chest's skin state, or if no chest (non-carbon), gets it from the status effect holder
/datum/surgery_operation/basic/proc/get_skin_state(mob/living/patient)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	if(isnull(chest)) // non-carbon
		var/datum/status_effect/basic_surgery_state/state_holder = patient.has_status_effect(__IMPLIED_TYPE__)
		return state_holder?.skin_state || SURGERY_SKIN_CLOSED

	return chest.surgery_skin_state

/// Gets either the chest's vessel state, or if no chest (non-carbon), gets it from the status effect holder
/datum/surgery_operation/basic/proc/get_vessel_state(mob/living/patient)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	if(isnull(chest)) // non-carbon
		var/datum/status_effect/basic_surgery_state/state_holder = patient.has_status_effect(__IMPLIED_TYPE__)
		return state_holder?.vessel_state || SURGERY_VESSELS_NORMAL

	return chest.surgery_vessel_state

/// Sets either the chest's skin state, or if no chest (non-carbon), sets it on the status effect holder
/datum/surgery_operation/basic/proc/set_skin_state(mob/living/patient, new_state)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	if(isnull(chest)) // non-carbon
		patient.apply_status_effect(/datum/status_effect/basic_surgery_state, new_state, null)
		return

	chest.surgery_skin_state = new_state

/// Sets either the chest's vessel state, or if no chest (non-carbon), sets it on the status effect holder
/datum/surgery_operation/basic/proc/set_vessel_state(mob/living/patient, new_state)
	if(iscarbon(patient)) // non-carbon
		var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
		chest.surgery_vessel_state = new_state
		return

	patient.apply_status_effect(/datum/status_effect/basic_surgery_state, null, new_state)

/// Operation that specifically targets limbs
/datum/surgery_operation/limb
	/// Body type required to perform this operation
	var/required_bodytype = NONE

/datum/surgery_operation/limb/get_operation_target(mob/living/surgeon, mob/living/patient, obj/item/tool = IMPLEMENT_HAND)
	return patient.get_bodypart(deprecise_zone(surgeon.zone_selected))

/datum/surgery_operation/limb/check_availability(atom/movable/operating_on, mob/living/surgeon, obj/item/tool = IMPLEMENT_HAND)
	SHOULD_NOT_OVERRIDE(TRUE) // you are looking for is_available()

	. = ..()
	if(!.)
		return FALSE

	if(!isbodypart(operating_on))
		stack_trace("Limb operation being performed on non-limb!")
		return FALSE

	var/obj/item/bodypart/limb = operating_on
	if(required_bodytype && !(limb.bodytype & required_bodytype))
		return FALSE

	if(!state_check(limb))
		return FALSE

	return TRUE

/**
 * Specifically concerns itself with checking limb state to see if the operation can be performed
 */
/datum/surgery_operation/limb/proc/state_check(obj/item/bodypart/limb)
	return FALSE

/datum/surgery_operation/limb/get_patient(obj/item/bodypart/limb)
	return limb.owner

/datum/surgery_operation/limb/get_working_zone(obj/item/bodypart/limb)
	return limb.body_zone

/datum/surgery_operation/limb/play_operation_sound(atom/movable/operating_on, mob/living/surgeon, tool, sound_or_sound_list)
	if(isitem(tool) && (required_bodytype & BODYTYPE_ROBOTIC))
		var/obj/item/realtool = tool
		realtool.play_tool_sound(operating_on)
		return

	return ..()

/// Returns what icon this surgery uses by default on the radial wheel, if it doesn't implement its own radial options
/datum/surgery_operation/limb/get_default_radial_image(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	if(limb.body_zone == BODY_ZONE_HEAD || limb.body_zone == BODY_ZONE_CHEST)
		return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_[limb.body_zone]")
	if(limb.body_zone == BODY_ZONE_L_ARM || limb.body_zone == BODY_ZONE_R_ARM)
		return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_arms")
	if(limb.body_zone == BODY_ZONE_L_LEG || limb.body_zone == BODY_ZONE_R_LEG)
		return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_legs")
	return ..()

/// Operation that specifically targets organs
/datum/surgery_operation/organ
	/// Biotype required to perform this operation
	var/required_biotype = ORGAN_ORGANIC
	/// The type of organ this operation can target
	var/obj/item/organ/target_type

/datum/surgery_operation/organ/get_operation_target(mob/living/surgeon, mob/living/patient, obj/item/tool = IMPLEMENT_HAND)
	return patient.get_organ_by_type(target_type)

/datum/surgery_operation/organ/get_patient(obj/item/organ/organ)
	return organ.owner

/datum/surgery_operation/organ/get_working_zone(obj/item/organ/organ)
	return organ.zone

/datum/surgery_operation/organ/check_availability(atom/movable/operating_on, mob/living/surgeon, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE

	if(!isorgan(operating_on))
		stack_trace("Organ operation being performed on non-organ!")
		return FALSE

	var/obj/item/organ/organ = operating_on
	if(required_biotype && !(organ.organ_flags & required_biotype))
		return FALSE

	if(!organ_check(organ))
		return FALSE

	return TRUE

/**
 * Specifically concerns itself with checking organ state to see if the operation can be performed
 *
 * Also checks limb state if necessary (via organ.bodypart_owner)
 */
/datum/surgery_operation/organ/proc/organ_check(obj/item/organ/organ)
	return FALSE

// melbert todos
// - figure out simplemobs
// - do something with surgical drapes (+speed bonus, +safety?)
// - wounds put you in certain bodypart states (limb bleeding -> vessels cut, broken bone -> bone drilled, etc)
// - trait for mobs which require a saw to break skin
// - tie organ fishing to an open cavity
