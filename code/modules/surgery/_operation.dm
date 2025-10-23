/// Applies moodlets after the surgical operation is complete
#define OPERATION_AFFECTS_MOOD (1<<0)
/// Notable operations are specially logged and also leave memories
#define OPERATION_NOTABLE (1<<1)
/// Operation will automatically repeat until it can no longer be performed
#define OPERATION_LOOPING (1<<2)
/// Grants a speed bonus if the user is morbid and their tool is morbid
#define OPERATION_MORBID (1<<3)
/// Not innately available to doctors, requires some tech to perform
#define OPERATION_REQUIRES_TECH (1<<4)
/// Operation can be performed on standing patients
#define OPERATION_STANDING_ALLOWED (1<<6)

/// Dummy "tool" for surgeries which use hands
#define IMPLEMENT_HAND "hands"

GLOBAL_LIST_INIT(operations, init_subtypes(/datum/surgery_operation))

/mob/living/proc/perform_surgery(mob/living/patient, obj/item/potential_tool)
	if(combat_mode)
		return NONE

	// if(tool)
	// 	tool = tool.get_proxy_attacker_for(limb, src)

	var/list/operations = list()
	var/list/radial_operations = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations)
		var/atom/movable/operate_on = operation.get_operation_target(src, patient, potential_tool)
		if(isnull(operate_on))
			continue
		if(!operation.check_availability(operate_on, src, potential_tool))
			continue
		for(var/radial_slice, option_info in operation.get_radial_options(operate_on, src, potential_tool))
			operations[radial_slice] = list("operation" = operation, "target" = operate_on) + option_info
			radial_operations[radial_slice] = radial_slice

	if(!length(operations))
		return NONE // allow attacking

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

/mob/living/proc/surgery_check(obj/item/tool)
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

	/// SFX played before the do-after begins
	var/preop_sound
	/// SFX played on success, after the do-after
	var/success_sound
	/// SFX played on failure, after the do-after
	var/failure_sound

	/// Option displayed when this operation is available
	VAR_PRIVATE/datum/radial_menu_choice/main_option

/**
 * Checks to see if this operation can be performed
 * This is the main entry point for checking availability
 */
/datum/surgery_operation/proc/check_availability(atom/movable/operating_on, mob/living/surgeon, obj/item/tool = IMPLEMENT_HAND)

	var/mob/patient = get_patient(operating_on)

	if(isnull(patient))
		return FALSE

	if(patient.body_position != LYING_DOWN && !(operation_flags & OPERATION_STANDING_ALLOWED))
		return FALSE

	if(!get_tool_quality(tool))
		return FALSE

	if(!is_available(operating_on))
		return FALSE

	if(operation_flags & OPERATION_REQUIRES_TECH)
		// melbert todo
		return FALSE

	return TRUE

/**
 * Returns the quality of the passed tool for this operation
 * Quality directly affects the time taken to perform the operation
 *
 * 0 = unusable
 * 1 = standard quality
 */
/datum/surgery_operation/proc/get_tool_quality(obj/item/tool = IMPLEMENT_HAND)
	if(!length(implements))
		return 1
	if(istype(tool, /obj/item/borg/cyborghug))
		tool = IMPLEMENT_HAND // melbert todo
	if(!tool_check(tool))
		return 0
	return implements[tool.tool_behaviour] || is_type_in_list(tool, implements, zebra = TRUE) || 0

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
 */
/datum/surgery_operation/proc/tool_check(obj/item/tool)
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
/datum/surgery_operation/proc/get_time_modifiers(atom/movable/operating_on, mob/living/surgeon, obj/item/tool)
	var/implement_modifier = get_tool_quality(tool) || 1.0
	var/location_modifier = get_location_modifier(get_turf(operating_on))
	var/morbid_modifier = get_morbid_modifier(surgeon, tool)
	var/mob_modifier = get_mob_surgery_speed_mod(operating_on)
	// modifiers are expressed as fractions of the base time - ie, 1.2x = 1.2x faster surgery
	// but since we're multiplying time, we invert here - ie, 1.2x = 0.83x smaller time
	return round(1.0 / (implement_modifier * location_modifier * morbid_modifier), 0.01)

/// Returns a time modifier for morbid operations
/datum/surgery_operation/proc/get_morbid_modifier(mob/living/surgeon, obj/item/tool)
	if(!(operation_flags & OPERATION_MORBID))
		return 1.0
	if(!HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		return 1.0
	if(!isitem(tool) || !(tool.item_flags & CRUEL_IMPLEMENT))
		return 1.0

	return 0.7

/datum/surgery_operation/proc/get_mob_surgery_speed_mod(atom/movable/operating_on)
	return get_patient(operating_on).mob_surgery_speed_mod

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
/datum/surgery_operation/proc/try_perform(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	if(!check_availability(operating_on, surgeon, tool))
		return ITEM_INTERACT_BLOCKING

	if(!start_operation(operating_on, surgeon, tool, operation_args))
		return ITEM_INTERACT_BLOCKING

	var/mob/living/patient = get_patient(operating_on)
	var/result = NONE

	do
		var/total_modifier = get_time_modifiers(operating_on, surgeon, tool)
		var/final_time = time * total_modifier
		if(!do_after(surgeon, final_time, patient, extra_checks = CALLBACK(src, PROC_REF(operate_check), operating_on, surgeon, tool, operation_args)))
			result |= ITEM_INTERACT_BLOCKING
			break

		if(ishuman(surgeon))
			var/mob/living/carbon/human/surgeon_human = surgeon
			surgeon_human.add_blood_DNA_to_items(patient.get_blood_dna_list(), ITEM_SLOT_GLOVES)
		else
			surgeon.add_mob_blood(patient)

		if(isitem(tool))
			var/obj/item/realtool = tool
			realtool.add_mob_blood(patient)

		if(is_successful(final_time))
			success(operating_on, surgeon, tool, operation_args)
			result |= ITEM_INTERACT_SUCCESS
		else
			failure(operating_on, surgeon, tool, operation_args, total_modifier)
			result |= ITEM_INTERACT_FAILURE

	while ((operation_flags & OPERATION_LOOPING) && can_loop(operating_on, surgeon, tool, operation_args))

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
 * Checks if the operation was successful
 *
 * Returns TRUE if successful, FALSE if failed
 */
/datum/surgery_operation/proc/is_successful(operation_speed)
	if(operation_speed > time * 2.5)
		return FALSE
	return TRUE

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

/datum/surgery_operation/proc/get_patient(atom/movable/operating_on) as /mob/living
	return operating_on

/datum/surgery_operation/proc/locate_operating_computer(turf/patient_turf)
	if (isnull(patient_turf))
		return null

	var/obj/structure/table/optable/operating_table = locate(/obj/structure/table/optable, patient_turf)
	var/obj/machinery/computer/operating/operating_computer = operating_table?.computer

	if (isnull(operating_computer))
		return null

	if(operating_computer.machine_stat & (NOPOWER|BROKEN))
		return null

	return operating_computer

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

	SEND_SIGNAL(surgeon, COMSIG_MOB_SURGERY_STEP_SUCCESS, src, operating_on, tool)
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
/datum/surgery_operation/proc/failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args, total_penalty_modifier)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(operation_flags & OPERATION_NOTABLE)
		SSblackbox.record_feedback("tally", "surgeries_failed", 1, type)

	play_operation_sound(operating_on, surgeon, tool, failure_sound)
	on_failure(operating_on, surgeon, tool, operation_args, total_penalty_modifier)

/**
 * Used to customize behavior when the operation fails
 *
 * total_penalty_modifier is the final modifier applied to the time taken to perform the operation,
 * and it can be interpreted as how badly the operation was performed
 *
 * At its lowest, it will be just above 2.5 (the threshold for success), and can go up to infinity (theoretically)
 */
/datum/surgery_operation/proc/on_failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args, total_penalty_modifier = 1)
	var/mob/living/patient = get_patient(operating_on)

	var/screwedmessage = ""
	switch(total_penalty_modifier)
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

/// Operation that specifically targets limbs
/datum/surgery_operation/limb
	/// Body type required to perform this operation
	var/required_bodytype = NONE

/datum/surgery_operation/limb/get_operation_target(mob/living/surgeon, mob/living/patient, obj/item/tool = IMPLEMENT_HAND)
	return patient.get_bodypart(deprecise_zone(surgeon.selected_body_zone))

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

// melbert todos
// - figure out simplemobs
// - do something with surgical drapes (+speed bonus, +safety?)
// - wounds put you in certain bodypart states (limb bleeding -> vessels cut, broken bone -> bone drilled, etc)
// - trait for mobs which require a saw to break skin
// - tie organ fishing to an open cavity
