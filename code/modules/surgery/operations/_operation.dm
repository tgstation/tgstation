/**
 * Attempts to perform a surgery with whatever tool is passed
 *
 * * src - the surgeon
 * * patient - the mob being operated on
 * * potential_tool - the tool being used for the operation (can be null / IMPLEMENT_HAND)
 * * intentionally_fail - if TRUE, forces the operation to fail (for testing purposes)
 *
 * Returns an ITEM_INTERACT_* flag
 */
/mob/living/proc/perform_surgery(mob/living/patient, potential_tool = IMPLEMENT_HAND, intentionally_fail = FALSE)
	if(DOING_INTERACTION(src, (HAS_TRAIT(src, TRAIT_HIPPOCRATIC_OATH) ? patient : DOAFTER_SOURCE_SURGERY)))
		patient.balloon_alert(src, "already performing surgery!")
		return ITEM_INTERACT_BLOCKING

	// allow cyborgs to use "hands"
	if(istype(potential_tool, /obj/item/borg/cyborghug))
		potential_tool = IMPLEMENT_HAND

	var/operating_zone = zone_selected
	var/list/operations = get_available_operations(patient, potential_tool, operating_zone)

	// we failed to undertake any operations?
	if(!length(operations))
		if(!isitem(potential_tool))
			return NONE
		var/obj/item/realtool = potential_tool
		// try self-cauterization if applicable
		if(src == patient)
			var/manual_cauterization = try_manual_cauterize(realtool)
			if(manual_cauterization & ITEM_INTERACT_ANY_BLOCKER)
				return manual_cauterization
		// for surgical tools specifically, we have some special handling
		if(!(realtool.item_flags & SURGICAL_TOOL))
			return NONE
		// if the targeted limb isn't prepped for surgery, i suppose we can allow an attack
		var/obj/item/bodypart/operating = patient.get_bodypart(operating_zone)
		if(operating && !HAS_TRAIT(operating, TRAIT_READY_TO_OPERATE))
			return NONE
		// at this point we can be relatively sure they messed up so let's give a feedback message...
		if(!patient.is_location_accessible(operating_zone, IGNORED_OPERATION_CLOTHING_SLOTS))
			patient.balloon_alert(src, "operation site is obstructed!")
		else if(!IS_LYING_OR_CANNOT_LIE(patient))
			patient.balloon_alert(src, "not lying down!")
		else
			patient.balloon_alert(src, "nothing to do with [realtool.name]!")
		//  ...then, block attacking. prevents the surgeon from viciously stabbing the patient on a mistake
		return ITEM_INTERACT_BLOCKING

	var/list/radial_operations = list()
	for(var/radial_slice in operations)
		radial_operations[radial_slice] = radial_slice // weird but makes it easier to index later

	sortTim(radial_operations, GLOBAL_PROC_REF(cmp_name_asc))

	var/picked = show_radial_menu(
		user = src,
		anchor = patient,
		choices = radial_operations,
		require_near = TRUE,
		autopick_single_option = TRUE,
		radius = 56,
		custom_check = CALLBACK(src, PROC_REF(surgery_check), potential_tool, patient),
	)
	if(isnull(picked))
		return ITEM_INTERACT_BLOCKING

	var/datum/surgery_operation/picked_op = operations[picked][1]
	var/atom/movable/operating_on = operations[picked][2]
	var/list/op_info = operations[picked][3]
	op_info[OPERATION_TARGET_ZONE] = operating_zone
	op_info[OPERATION_FORCE_FAIL] = intentionally_fail

	return picked_op.try_perform(operating_on, src, potential_tool, op_info)

/**
 * Returns a list of all surgery operations the mob can currently perform on the patient with the potential tool
 *
 * * src - the surgeon
 * * patient - the mob being operated on
 * * potential_tool - the tool being used for the operation (can be null / IMPLEMENT_HAND)
 * * operating_zone - the body zone being operated on
 *
 * Returns a list where the keys are radial menu slices and the values are lists of:
 * * [0] - the operation datum
 * * [1] - the atom being operated on
 * * [2] - a list of option-specific info
 */
/mob/living/proc/get_available_operations(mob/living/patient, potential_tool = IMPLEMENT_HAND, operating_zone = zone_selected)
	// List of typepaths of operations we *can* do
	var/list/possible_operations = GLOB.operations.unlocked.Copy()
	// Signals can add operation types to the list to unlock special ones
	SEND_SIGNAL(src, COMSIG_LIVING_OPERATING_ON, patient, possible_operations)
	SEND_SIGNAL(patient, COMSIG_LIVING_BEING_OPERATED_ON, patient, possible_operations)

	var/list/operations = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(possible_operations))
		var/atom/movable/operate_on = operation.get_operation_target(patient, operating_zone)
		if(!operation.check_availability(patient, operate_on, src, potential_tool, operating_zone))
			continue
		var/potential_options = operation.get_radial_options(operate_on, potential_tool, operating_zone)
		if(!islist(potential_options))
			potential_options = list(potential_options)
		for(var/datum/radial_menu_choice/radial_slice as anything in potential_options)
			if(operations[radial_slice])
				stack_trace("Duplicate radial surgery option '[radial_slice.name]' detected for operation '[operation.type]'.")
				continue
			var/option_specific_info = potential_options[radial_slice] || list("[OPERATION_ACTION]" = "default")
			operations[radial_slice] = list(operation, operate_on, option_specific_info)

	return operations

/// Callback for checking if the surgery radial can be kept open
/mob/living/proc/surgery_check(obj/item/tool, mob/living/patient)
	var/obj/item/holding = get_active_held_item()

	if(tool == IMPLEMENT_HAND)
		return isnull(holding) || istype(holding, /obj/item/borg/cyborghug) // still holding nothing (or "hands")
	if(QDELETED(holding))
		return FALSE // i dunno, a stack item? not our problem

	return tool == holding.get_proxy_attacker_for(patient, src) // tool (or its proxy) is still being held

/// src attempts to cauterize themselves to reset their surgery state. Basically a manual form of the real "close skin" operation
/mob/living/proc/try_manual_cauterize(obj/item/tool)
	var/cauterize_zone = deprecise_zone(zone_selected)
	var/obj/item/bodypart/limb = get_bodypart(cauterize_zone)
	if(!manual_cauterize_check(tool, limb))
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(src, src))
		return ITEM_INTERACT_BLOCKING

	visible_message(
		span_notice("[src] attempts to close [p_their()] own [limb.plaintext_zone] with [tool]..."),
		span_notice("You attempt to close your own [limb.plaintext_zone] with [tool]..."),
		span_hear("You hear singing."),
		vision_distance = 5,
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
	playsound(src, istype(tool, /obj/item/stack/medical/suture) ? SFX_SUTURE_BEGIN : 'sound/items/handling/surgery/cautery1.ogg', 50, TRUE)
	if(!do_after(
		user = src,
		delay = /datum/surgery_operation/limb/close_skin::time * 2 * tool.toolspeed,
		target = src,
		extra_checks = CALLBACK(src, PROC_REF(manual_cauterize_check), tool, limb),
	))
		return ITEM_INTERACT_BLOCKING

	visible_message(
		span_notice("[src] closes [p_their()] own [limb.plaintext_zone] with [tool]."),
		span_notice("You close your own [limb.plaintext_zone] with [tool]."),
		span_hear("You hear singing."),
		vision_distance = 5,
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
	playsound(src, istype(tool, /obj/item/stack/medical/suture) ? SFX_SUTURE_END : 'sound/items/handling/surgery/cautery2.ogg', 50, TRUE)
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)
	if(istype(tool, /obj/item/stack/medical/suture))
		var/obj/item/stack/medical/suture/suture_tool = tool
		suture_tool.use(1)
	else
		limb.receive_damage(burn = 5, wound_bonus = CANT_WOUND, damage_source = tool)
	return ITEM_INTERACT_SUCCESS

/// Callback for checking if the cauterization do-after can continue
/mob/living/proc/manual_cauterize_check(obj/item/tool, obj/item/bodypart/limb)
	PRIVATE_PROC(TRUE)

	if(QDELETED(limb) || limb.owner != src)
		return FALSE

	if(QDELETED(tool))
		return FALSE
	else if(istype(tool, /obj/item/stack/medical/suture))
		var/obj/item/stack/medical/suture/suture_tool = tool
		if(suture_tool.amount <= 0)
			return FALSE
	else if(tool.tool_behaviour != TOOL_CAUTERY)
		if(tool.get_temperature() <= 0)
			return FALSE

	// we need to have a surgery state worth closing
	var/states_to_check = ALL_SURGERY_STATES_UNSET_ON_CLOSE
	if(!LIMB_HAS_BONES(limb))
		states_to_check &= ~BONELESS_SURGERY_STATES
	if(!LIMB_HAS_VESSELS(limb))
		states_to_check &= ~VESSELLESS_SURGERY_STATES
	if(!LIMB_HAS_SKIN(limb))
		states_to_check &= ~SKINLESS_SURGERY_STATES
	if(!states_to_check || !LIMB_HAS_ANY_SURGERY_STATE(limb, states_to_check))
		return FALSE

	// skin has to be open or cut to do anything (we can't have a negative state without also having skin open anyways)
	if(!LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_SKIN_STATES))
		return FALSE

	return TRUE

/// Debug proc to print all surgeries available to whoever called the proc
/mob/living/proc/debug_get_all_available_surgeries()
	var/mob/living/surgeon = usr
	if(!isliving(surgeon))
		return

	var/list/operations = surgeon.get_available_operations(src, surgeon.get_active_held_item())
	if(!length(operations))
		to_chat(surgeon, boxed_message(span_info("No available surgeries.")))
		return

	var/list/operations_info = list()
	for(var/radial_slice in operations)
		var/datum/surgery_operation/operation = operations[radial_slice][1]
		var/atom/movable/operating_on = operations[radial_slice][2]
		operations_info += "[radial_slice]: [operation.name] on [operating_on]"

	to_chat(surgeon, boxed_message(span_info("Available surgeries:<br><hr>[jointext(operations_info, "<br>")]")))

/// Takes a target zone and returns a list of readable surgery states for that zone.
/// Example output may be list("Skin is cut", "Blood vessels are unclamped", "Bone is sawed")
/mob/living/proc/get_surgery_state_as_list(target_zone)
	var/list/state = list()
	if(has_limbs)
		var/obj/item/bodypart/part = get_bodypart(target_zone)
		if(isnull(part))
			return list("Bodypart missing")

		if(HAS_TRAIT(part, TRAIT_READY_TO_OPERATE))
			state += "Ready for surgery"
		if(!is_location_accessible(target_zone, IGNORED_OPERATION_CLOTHING_SLOTS))
			state += "Bodypart is obstructed by clothing"

		var/part_state = part?.surgery_state || NONE

		if(!LIMB_HAS_BONES(part))
			part_state &= ~BONELESS_SURGERY_STATES
			state += "Bodypart lacks bones (counts as [jointext(bitfield_to_list(BONELESS_SURGERY_STATES, SURGERY_STATE_READABLE), ", ")])"
		if(!LIMB_HAS_VESSELS(part))
			part_state &= ~VESSELLESS_SURGERY_STATES
			state += "Bodypart lacks blood vessels (counts as [jointext(bitfield_to_list(VESSELLESS_SURGERY_STATES, SURGERY_STATE_READABLE), ", ")])"
		if(!LIMB_HAS_SKIN(part))
			part_state &= ~SKINLESS_SURGERY_STATES
			state += "Bodypart lacks skin (counts as [jointext(bitfield_to_list(SKINLESS_SURGERY_STATES, SURGERY_STATE_READABLE), ", ")])"

		state += bitfield_to_list(part_state, SURGERY_STATE_READABLE)

	else
		if(HAS_TRAIT(src, TRAIT_READY_TO_OPERATE))
			state += "Ready for surgery"

		var/datum/status_effect/basic_surgery_state/state_holder = has_status_effect(__IMPLIED_TYPE__)
		state += bitfield_to_list(state_holder?.surgery_state, SURGERY_STATE_READABLE)

	return state

/**
 * Adds a speed modifier to this mob
 *
 * * id - id of the modifier, string
 * * amount - the multiplier to apply to surgery speed.
 * This is multiplicative with other modifiers.
 * * duration - how long the modifier should last in deciseconds.
 * If null, it will be permanent until removed.
 */
/mob/living/proc/add_surgery_speed_mod(id, amount, duration)
	ASSERT(!isnull(id), "Surgery speed mod ID cannot be null")
	ASSERT(isnum(amount), "Surgery speed mod amount must be a number")
	ASSERT(isnum(duration) || isnull(duration), "Surgery speed mod duration must be a number or null")

	var/existing = LAZYACCESS(mob_surgery_speed_mods, id)
	if(existing == amount)
		return

	if(isnum(existing))
		if(amount > 1 && existing > 1)
			// both are speed decreases, take the better one
			LAZYSET(mob_surgery_speed_mods, id, max(amount, existing))
		else if(amount < 1 && existing < 1)
			// both are speed increases, take the better one
			LAZYSET(mob_surgery_speed_mods, id, min(amount, existing))
		else
			// one of each, just multiply them
			LAZYSET(mob_surgery_speed_mods, id, amount * existing)
	else
		LAZYSET(mob_surgery_speed_mods, id, amount)

	if(isnum(duration))
		addtimer(CALLBACK(src, PROC_REF(remove_surgery_speed_mod), id), duration, TIMER_DELETE_ME|TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT)

/**
 * Removes a speed modifier from this mob
 *
 * * id - id of the modifier to remove, string
 */
/mob/living/proc/remove_surgery_speed_mod(id)
	LAZYREMOVE(mob_surgery_speed_mods, id)

GLOBAL_DATUM_INIT(operations, /datum/operation_holder, new)

/// Singleton containing all surgery operation, as well as some helpers for organizing them
/datum/operation_holder
	/// All operation singletons, indexed by typepath
	/// It is recommended to use get_instances_from() where possible, rather than accessing this directly
	var/list/operations_by_typepath
	/// All operation typepaths which are unlocked by default, indexed by typepath
	var/list/unlocked
	/// All operation typepaths which are locked by something, indexed by typepath
	var/list/locked

/datum/operation_holder/New()
	. = ..()
	operations_by_typepath = list()
	unlocked = list()
	locked = list()

	for(var/operation_type in valid_subtypesof(/datum/surgery_operation))
		var/datum/surgery_operation/operation = new operation_type()
		if(isnull(operation.name))
			stack_trace("Surgery operation '[operation_type]' is missing a name!")

		operations_by_typepath[operation_type] = operation
		if(operation.operation_flags & OPERATION_LOCKED)
			locked += operation_type
		else
			unlocked += operation_type

/// Takes in a list of operation typepaths and returns their singleton instances. Optionally can filter out replaced surgeries and by certain operation flags.
/datum/operation_holder/proc/get_instances_from(list/typepaths, filter_replaced = TRUE)
	var/list/result = list()
	for(var/datum/surgery_operation/operation_type as anything in typepaths)
		var/datum/surgery_operation/operation = operations_by_typepath[operation_type]
		if(isnull(operation))
			continue
		if(filter_replaced && is_replaced(operation, typepaths))
			continue
		result += operation
	return result

/// Check if the passed operation has been replaced by a typepath in the provided operation pool
/datum/operation_holder/proc/is_replaced(datum/surgery_operation/operation, list/operation_pool)
	if(isnull(operation.replaced_by) || !length(operation_pool))
		return FALSE
	if(operation.replaced_by == operation.type)
		return FALSE
	if(operation.replaced_by in operation_pool)
		return TRUE
	// recursively check if the operation that replaces us is itself replaced
	var/datum/surgery_operation/next_highest_operation = operations_by_typepath[operation.replaced_by]
	if(isnull(next_highest_operation))
		return FALSE
	return is_replaced(next_highest_operation, operation_pool)

/**
 * ## Surgery operation datum
 *
 * A singleton datum which represents a surgical operation that can be performed on a mob.
 *
 * Surgery operations can be something simple, like moving between surgery states (tend wounds, clamp vessels),
 * or more complex, like outright replacing limbs or organs. As such the datum is very flexible.
 *
 * At most basic, you must implement the vars:
 * * - [name][/datum/surgery_operation/var/name]
 * * - [desc][/datum/surgery_operation/var/desc]
 * * - [implements][/datum/surgery_operation/var/implements]
 * And the procs:
 * * - [on success][/datum/surgery_operation/proc/on_success] - put the effects of the operation here
 * Other noteworthy vars and procs you probably want to implement or override:
 * * - [operation flags][/datum/surgery_operation/var/operation_flags] - flags modifying the behavior of the operation
 * * - [required surgery state][/datum/surgery_operation/var/all_surgery_states_required] - target must have ALL of these states to be eligible for the operation
 * * - [blocked surgery state][/datum/surgery_operation/var/any_surgery_states_blocked] - target must NOT have ANY these states to be eligible for the operation
 * * - [state check][/datum/surgery_operation/proc/state_check] - extra checks for if the operating target is valid
 * * - [get default radial image][/datum/surgery_operation/proc/get_default_radial_image] - what icon to use for this operation on the radial menu
 *
 * It's recommended to work off of [/datum/surgery_operation/limb] or [/datum/surgery_operation/organ]
 * as they implement a lot of common functionality for targeting limbs or organs for you.
 *
 * See also [/datum/surgery_operation/basic], which is a bit more complex to use
 * but allows for operations to target any mob type, rather than only those with limbs or organs.
 */
/datum/surgery_operation
	abstract_type = /datum/surgery_operation
	/// Required - Name of the operation, keep it short and format it like an action - "amputate limb", "remove organ"
	/// Don't capitalize it, it will be capitalized automatically where necessary.
	var/name
	/// Required - Description of the operation, keep it short and format it like an action - "Amputate a patient's limb.", "Remove a patient's organ.".
	// Use "a patient" instead of "the patient" to keep it generic.
	var/desc

	/// Optional - the name of the operation shown in RND consoles and the operating computer.
	/// You can get fancier here, givin an official surgery name ("Lobectomy") or rephrase it to be more descriptive ("Brain Lobectomy").
	/// Capitalize it as necessary.
	var/rnd_name
	/// Optional - the description of the operation shown in RND consoles and the operating computer.
	/// Here is where you may want to provide more information on why an operation is done ("Fixes a broken liver") or special requirements ("Requires Synthflesh").
	/// Use "the patient" instead of "a patient" to keep it specific.
	var/rnd_desc

	/**
	 * What tool(s) can be used to perform this operation?
	 *
	 * Assoc list of item typepath, TOOL_X, or IMPLEMENT_HAND to a multiplier for how effective that tool is at performing the operation.
	 * For example, list(TOOL_SCALPEL = 2, TOOL_SAW = 0.5) means that you can use a scalpel to operate, and it will double the time the operation takes.
	 * Likewise using a saw will halve the time it takes. If a tool is not listed, it cannot be used for this operation.
	 *
	 * Order matters! If a tool matches multiple entries, the first one will always be used.
	 * For example, if you have list(TOOL_SCREWDRIVER = 2, /obj/item/screwdriver = 1), and use a screwdriver
	 * it will use the TOOL_SCREWDRIVER modifier, making your operation 2x slower, even though the latter entry would have been faster.
	 *
	 * For this, it is handy to keep in mind SURGERY_MODIFIER_FAILURE_THRESHOLD.
	 * While speeds are soft capped and cannot be reduced beyond this point, larger modifiers still increase failure chances.
	 *
	 * Lastly, while most operations have its main tool with a 1x modifier (representing the "intended" tool),
	 * some will have its main tool's multiplier above or below 1x to represent an innately easier or harder operation
	 */
	var/list/implements
	/// Base time to perform this operation
	var/time = 1 SECONDS

	/// Flags modifying the behavior of this operation
	var/operation_flags = NONE

	/// The target must have ALL of these surgery states for the operation to be available
	var/all_surgery_states_required = NONE
	/// The target must have ANY of these surgery states for the operation to be available
	var/any_surgery_states_required = NONE
	/// The target must NOT have ANY of these surgery states for the operation to be available
	var/any_surgery_states_blocked = NONE

	/// Typepath of a surgical operation that supersedes this one
	/// If this operation and the replaced_by operation are both available, only the replaced_by one will be usable
	var/datum/surgery_operation/replaced_by

	/// SFX played before the do-after begins
	/// Can be a sound path or an assoc list of item typepath to sound path to make different sounds for different tools
	var/preop_sound
	/// SFX played on success, after the do-after
	/// Can be a sound path or an assoc list of item typepath to sound path to make different sounds for different tools
	var/success_sound
	/// SFX played on failure, after the do-after
	/// Can be a sound path or an assoc list of item typepath to sound path to make different sounds for different tools
	var/failure_sound

	/// The default radial menu choice for this operation, lazily created on first use
	/// Some subtypes won't have this set as they provide their own options
	VAR_PRIVATE/datum/radial_menu_choice/main_option

	/// Which mood event to give the patient when surgery is starting while they're conscious.
	/// This should be permanent/not have a timer until the surgery either succeeds or fails, as those states will immediately replace it.
	/// Mostly just flavor text.
	var/datum/mood_event/surgery/surgery_started_mood_event = /datum/mood_event/surgery
	/// Which mood event to give the conscious patient when surgery succeeds.
	/// Lasts far shorter than if it failed.
	var/datum/mood_event/surgery/surgery_success_mood_event = /datum/mood_event/surgery/success
	/// Which mood event to give the consious patient when surgery fails.
	/// Lasts muuuuuch longer.
	var/datum/mood_event/surgery/surgery_failure_mood_event = /datum/mood_event/surgery/failure

/**
 * Checks to see if this operation can be performed
 * This is the main entry point for checking availability
 */
/datum/surgery_operation/proc/check_availability(mob/living/patient, atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_BE_PURE(TRUE)

	if(isnull(patient) || isnull(operating_on))
		return FALSE

	if(!(operation_flags & OPERATION_STANDING_ALLOWED) && !IS_LYING_OR_CANNOT_LIE(patient))
		return FALSE

	if(!(operation_flags & OPERATION_SELF_OPERABLE) && patient == surgeon && !HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY))
		return FALSE

	if(get_tool_quality(tool) <= 0)
		return FALSE

	if(!is_available(operating_on, operated_zone))
		return FALSE

	return snowflake_check_availability(operating_on, surgeon, tool, operated_zone)

/**
 * Snowflake checks for surgeries which need many interconnected conditions to be met
 */
/datum/surgery_operation/proc/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	PROTECTED_PROC(TRUE)
	return TRUE

/**
 * Returns the quality of the passed tool for this operation
 * Quality directly affects the time taken to perform the operation
 *
 * 0 = unusable
 * 1 = standard quality
 */
/datum/surgery_operation/proc/get_tool_quality(tool = IMPLEMENT_HAND)
	PROTECTED_PROC(TRUE)
	if(!length(implements))
		return 1
	if(!isitem(tool))
		return implements[tool]
	if(!tool_check(tool))
		return 0

	var/obj/item/realtool = tool
	return (realtool.toolspeed) * (implements[realtool.tool_behaviour] || is_type_in_list(realtool, implements, zebra = TRUE) || 0)

/**
 * Return a radial slice, a list of radial slices, or an assoc list of radial slice to operation info
 *
 * By default it returns a single option with the operation name and description,
 * but you can override this proc to return multiple options for one operation, like selecting which organ to operate on.
 */
/datum/surgery_operation/proc/get_radial_options(atom/movable/operating_on, obj/item/tool, operating_zone)
	if(!main_option)
		main_option = new()
		main_option.image = get_default_radial_image()
		main_option.name = name
		main_option.info = desc

	return main_option

/**
 * Checks to see if this operation can be performed on the provided target
 */
/datum/surgery_operation/proc/is_available(atom/movable/operating_on, operated_zone)
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(all_surgery_states_required && !has_surgery_state(operating_on, all_surgery_states_required))
		return FALSE

	if(any_surgery_states_required && !has_any_surgery_state(operating_on, any_surgery_states_required))
		return FALSE

	if(any_surgery_states_blocked && has_any_surgery_state(operating_on, any_surgery_states_blocked))
		return FALSE

	if(!state_check(operating_on))
		return FALSE

	var/mob/living/patient = get_patient(operating_on)
	if(!(operation_flags & OPERATION_IGNORE_CLOTHES) && !patient.is_location_accessible(operated_zone, IGNORED_OPERATION_CLOTHING_SLOTS))
		return FALSE

	return TRUE

/// Check if the movable being operated on has all the passed surgery states
/datum/surgery_operation/proc/has_surgery_state(atom/movable/operating_on, state)
	PROTECTED_PROC(TRUE)
	return FALSE

/// Check if the movable being operated on has any of the passed surgery states
/datum/surgery_operation/proc/has_any_surgery_state(atom/movable/operating_on, state)
	PROTECTED_PROC(TRUE)
	return FALSE

/**
 * Any operation specific state checks, such as checking for traits or more complex state requirements
 */
/datum/surgery_operation/proc/state_check(atom/movable/operating_on)
	PROTECTED_PROC(TRUE)
	return TRUE

/**
 * Checks to see if the provided tool is valid for this operation
 * You can override this to add more specific checks, such as checking sharpness
 */
/datum/surgery_operation/proc/tool_check(obj/item/tool)
	PROTECTED_PROC(TRUE)
	return TRUE

/**
 * Returns the name of whatever tool is recommended for this operation, such as "hemostat"
 */
/datum/surgery_operation/proc/get_recommended_tool()
	if(!length(implements))
		return null
	var/recommendation = implements[1]
	if(istext(recommendation))
		return recommendation // handles tools or IMPLEMENT_HAND
	if(recommendation == /obj/item)
		return get_any_tool()
	if(ispath(recommendation, /obj/item))
		var/obj/item/tool = recommendation
		return tool::name
	return null

/**
 * For surgery operations that can be performed with any item, this explains what kind of item is needed
 */
/datum/surgery_operation/proc/get_any_tool()
	return "Any item"

/**
 * Return a list of lists of strings indicating the various requirements for this operation
 */
/datum/surgery_operation/proc/get_requirements()
	SHOULD_NOT_OVERRIDE(TRUE)
	return list(
		all_required_strings(),
		any_required_strings(),
		any_optional_strings(),
		all_blocked_strings(),
	)

/// Returns a list of strings indicating requirements for this operation
/// "All requirements" are formatted as "All of the following must be true:"
/datum/surgery_operation/proc/all_required_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = bitfield_to_list(all_surgery_states_required, SURGERY_STATE_GUIDES("must"))
	if(!(operation_flags & OPERATION_STANDING_ALLOWED))
		. += "the patient must be lying down"

/// Returns a list of strings indicating any of the requirements for this operation
/// "Any requirements" are formatted as "At least one of the following must be true:"
/datum/surgery_operation/proc/any_required_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	// grouped states are filtered down to make it more readable
	var/parsed_any_flags = any_surgery_states_required
	if((parsed_any_flags & ALL_SURGERY_BONE_STATES) == ALL_SURGERY_BONE_STATES)
		parsed_any_flags &= ~ALL_SURGERY_BONE_STATES
		. += "the bone must be sawed or drilled"
	if((parsed_any_flags & ALL_SURGERY_SKIN_STATES) == ALL_SURGERY_SKIN_STATES)
		parsed_any_flags &= ~ALL_SURGERY_SKIN_STATES
		. += "the skin must be cut or opened"
	if((parsed_any_flags & ALL_SURGERY_VESSEL_STATES) == ALL_SURGERY_VESSEL_STATES)
		parsed_any_flags &= ~ALL_SURGERY_VESSEL_STATES
		. += "the blood vessels must be clamped or unclamped" // weird phrasing but whatever

	. += bitfield_to_list(parsed_any_flags, SURGERY_STATE_GUIDES("must"))

/// Returns a list of strings indicating optional conditions for this operation
/// "Optional conditions" are formatted as "Additionally, any of the following may be true:"
/datum/surgery_operation/proc/any_optional_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	if(operation_flags & OPERATION_SELF_OPERABLE)
		. += "a surgeon may perform this on themselves"

/// Returns a list of strings indicating blocked states for this operation
/// "Blocked requirements" are formatted as "However, none of the following may be true:"
/datum/surgery_operation/proc/all_blocked_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	// grouped states are filtered down to make it more readable
	var/parsed_blocked_flags = any_surgery_states_blocked
	if((parsed_blocked_flags & ALL_SURGERY_BONE_STATES) == ALL_SURGERY_BONE_STATES)
		parsed_blocked_flags &= ~ALL_SURGERY_BONE_STATES
		. += "the bone must be intact"
	if((parsed_blocked_flags & ALL_SURGERY_SKIN_STATES) == ALL_SURGERY_SKIN_STATES)
		parsed_blocked_flags &= ~ALL_SURGERY_SKIN_STATES
		. += "the skin must be intact"
	if((parsed_blocked_flags & ALL_SURGERY_VESSEL_STATES) == ALL_SURGERY_VESSEL_STATES)
		parsed_blocked_flags &= ~ALL_SURGERY_VESSEL_STATES
		. += "the blood vessels must be intact"

	. += bitfield_to_list(parsed_blocked_flags, SURGERY_STATE_GUIDES("must not"))
	if(!(operation_flags & OPERATION_IGNORE_CLOTHES))
		. += "the operation site must not be obstructed by clothing"

/**
 * Returns what icon this surgery uses by default on the radial wheel if it does not implement its own radial options
 *
 * Also used when generating icons for the wiki
 */
/datum/surgery_operation/proc/get_default_radial_image()
	return image(icon = 'icons/effects/random_spawners.dmi', icon_state = "questionmark")

/// Helper to get a generic limb radial image based on body zone
/datum/surgery_operation/proc/get_generic_limb_radial_image(body_zone)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	if(body_zone == BODY_ZONE_HEAD || body_zone == BODY_ZONE_CHEST || body_zone == BODY_ZONE_PRECISE_EYES || body_zone == BODY_ZONE_PRECISE_MOUTH)
		return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_[body_zone]")
	if(body_zone == BODY_ZONE_L_ARM || body_zone == BODY_ZONE_R_ARM)
		return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_arms")
	if(body_zone == BODY_ZONE_L_LEG || body_zone == BODY_ZONE_R_LEG)
		return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_legs")
	return get_default_radial_image()

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
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

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
	PROTECTED_PROC(TRUE)
	var/total_mod = 1.0
	total_mod *= get_tool_quality(tool) || 1.0
	// Ignore alllll the penalties (but also all the bonuses)
	if(!HAS_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS))
		var/mob/living/patient = get_patient(operating_on)
		total_mod *= get_location_modifier(get_turf(patient))
		total_mod *= get_morbid_modifier(surgeon, tool)
		total_mod *= get_mob_surgery_speed_mod(patient)
		// Using TRAIT_SELF_SURGERY on a surgery which doesn't normally allow self surgery imparts a penalty
		if(patient == surgeon && HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY) && !(operation_flags & OPERATION_SELF_OPERABLE))
			total_mod *= 1.5
	return round(total_mod, 0.01)

/// Returns a time modifier for morbid operations
/datum/surgery_operation/proc/get_morbid_modifier(mob/living/surgeon, obj/item/tool)
	PROTECTED_PROC(TRUE)
	if(!(operation_flags & OPERATION_MORBID))
		return 1.0
	if(!HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		return 1.0
	if(!isitem(tool) || !(tool.item_flags & CRUEL_IMPLEMENT))
		return 1.0

	return 0.7

/// Returns a time modifier based on the mob's status
/datum/surgery_operation/proc/get_mob_surgery_speed_mod(mob/living/patient)
	PROTECTED_PROC(TRUE)
	var/basemod = 1.0
	for(var/mod_id, mod_amt in patient.mob_surgery_speed_mods)
		basemod *= mod_amt
	if(HAS_TRAIT(patient, TRAIT_SURGICALLY_ANALYZED))
		basemod *= 0.8
	if(HAS_TRAIT(patient, TRAIT_ANALGESIA))
		basemod *= 0.8
	return basemod

/// Gets the surgery speed modifier for a given mob, based off what sort of table/bed/whatever is on their turf.
/datum/surgery_operation/proc/get_location_modifier(turf/operation_turf)
	PROTECTED_PROC(TRUE)
	// Technically this IS a typecache, just not the usual kind :3
	// The order of the modifiers matter, latter entries override earlier ones
	var/static/list/modifiers = zebra_typecacheof(list(
		/obj/structure/table = 1.25,
		/obj/structure/table/optable = 1.0,
		/obj/structure/table/optable/abductor = 0.85,
		/obj/machinery/stasis = 1.15,
		/obj/structure/bed = 1.5,
	))
	var/mod = 2.0
	for(var/obj/thingy in operation_turf)
		mod = min(mod, modifiers[thingy.type] || 2.0)
	return mod

/**
 * Gets what movable is being operated on by a surgeon during this operation
 * Determines what gets passed into the try_perform() proc
 * If null is returned, the operation cannot be performed
 *
 * * patient - The mob being operated on
 * * body_zone - The body zone being operated on
 *
 * Returns the atom/movable being operated on
 */
/datum/surgery_operation/proc/get_operation_target(mob/living/patient, body_zone)
	return patient

/**
 * Called by operating computers to hint that this surgery could come next given the target's current state
 */
/datum/surgery_operation/proc/show_as_next_step(mob/living/potential_patient, operated_zone)
	var/atom/movable/operate_on = get_operation_target(potential_patient, operated_zone)
	return !isnull(operate_on) && is_available(operate_on, operated_zone)


/**
 * The actual chain of performing the operation
 *
 * * operating_on - The atom being operated on, probably a bodypart or occasionally a mob directly
 * * surgeon - The mob performing the operation
 * * tool - The tool being used to perform the operation. CAN BE A STRING, ie, IMPLEMENT_HAND, be careful
 * * operation_args - Additional arguments passed into the operation. Contains largely niche info that only certain operations care about or can be accessed through other means
 *
 * Returns an item interaction flag - intended to be invoked from the interaction chain
 */
/datum/surgery_operation/proc/try_perform(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args = list())
	SHOULD_NOT_OVERRIDE(TRUE)
	var/mob/living/patient = get_patient(operating_on)

	if(!check_availability(patient, operating_on, surgeon, tool, operation_args[OPERATION_TARGET_ZONE]))
		return ITEM_INTERACT_BLOCKING
	if(!start_operation(operating_on, surgeon, tool, operation_args))
		return ITEM_INTERACT_BLOCKING

	var/was_sleeping = (patient.stat != DEAD && HAS_TRAIT(patient, TRAIT_KNOCKEDOUT))
	var/result = NONE

	update_surgery_mood(patient, SURGERY_STATE_STARTED)
	SEND_SIGNAL(patient, COMSIG_LIVING_SURGERY_STARTED, src, operating_on, tool)

	do
		operation_args[OPERATION_SPEED] = get_time_modifiers(operating_on, surgeon, tool)

		if(!do_after(
			user = surgeon,
			// Actual delay is capped - think of the excess time as being added to failure chance instead
			delay = time * min(operation_args[OPERATION_SPEED], SURGERY_MODIFIER_FAILURE_THRESHOLD),
			target = patient,
			extra_checks = CALLBACK(src, PROC_REF(operate_check), patient, operating_on, surgeon, tool, operation_args),
			// You can only operate on one mob at a time without a hippocratic oath
			interaction_key = HAS_TRAIT(surgeon, TRAIT_HIPPOCRATIC_OATH) ? patient : DOAFTER_SOURCE_SURGERY,
		))
			result |= ITEM_INTERACT_BLOCKING
			update_surgery_mood(patient, SURGERY_STATE_FAILURE)
			break

		if(ishuman(surgeon))
			var/mob/living/carbon/human/surgeon_human = surgeon
			surgeon_human.add_blood_DNA_to_items(patient.get_blood_dna_list(), ITEM_SLOT_GLOVES)
		else
			surgeon.add_mob_blood(patient)

		// This will annoy doctors immensely
		// if(isitem(tool))
		// 	var/obj/item/realtool = tool
		// 	realtool.add_mob_blood(patient)

		// We modify speed modifier here AFTER the do after to increase failure chances, that's intentional
		// Think of it as modifying "effective time" rather than "real time". Failure chance goes up but the time it took is unchanged

		// Using TRAIT_SELF_SURGERY on a surgery which doesn't normally allow self surgery imparts a flat penalty
		// (On top of the 1.5x real time surgery modifier, an effective time modifier of 3x under standard conditions)
		if(patient == surgeon && HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY) && !(operation_flags & OPERATION_SELF_OPERABLE))
			operation_args[OPERATION_SPEED] += 1.5

		// Otherwise if we have TRAIT_IGNORE_SURGERY_MODIFIERS we cannot possibly fail, unless we specifically allow failure
		if(HAS_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS) && !(operation_flags & OPERATION_ALWAYS_FAILABLE))
			operation_args[OPERATION_SPEED] = 0

		if(operation_args[OPERATION_FORCE_FAIL] || prob(clamp(GET_FAILURE_CHANCE(time, operation_args[OPERATION_SPEED]), 0, 99)))
			failure(operating_on, surgeon, tool, operation_args)
			result |= ITEM_INTERACT_FAILURE
			update_surgery_mood(patient, SURGERY_STATE_FAILURE)
		else
			success(operating_on, surgeon, tool, operation_args)
			result |= ITEM_INTERACT_SUCCESS
			update_surgery_mood(patient, SURGERY_STATE_SUCCESS)

		if(isstack(tool))
			var/obj/item/stack/tool_stack = tool
			tool_stack.use(1)

	while ((operation_flags & OPERATION_LOOPING) && can_loop(patient, operating_on, surgeon, tool, operation_args))

	SEND_SIGNAL(patient, COMSIG_LIVING_SURGERY_FINISHED, src, operating_on, tool)

	if(patient.stat == DEAD && was_sleeping)
		surgeon.client?.give_award(/datum/award/achievement/jobs/sandman, surgeon)

	return result

/// Called after an operation to check if it can be repeated/looped
/datum/surgery_operation/proc/can_loop(mob/living/patient, atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	return operate_check(patient, operating_on, surgeon, tool, operation_args)

/// Called during the do-after to check if the operation can continue
/datum/surgery_operation/proc/operate_check(mob/living/patient, atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)

	if(isstack(tool))
		var/obj/item/stack/tool_stack = tool
		if(tool_stack.amount <= 0)
			return FALSE

	if(!surgeon.surgery_check(tool, patient))
		return FALSE

	if(!check_availability(patient, operating_on, surgeon, tool, operation_args[OPERATION_TARGET_ZONE]))
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
	PROTECTED_PROC(TRUE)
	return TRUE

/// Used to display messages to the surgeon and patient
/datum/surgery_operation/proc/display_results(mob/living/surgeon, mob/living/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	ASSERT(istext(self_message), "[type] operation display_results must have a self_message!")
	ASSERT(istext(detailed_message), "[type] operation display_results must have a detailed_message!")
	ASSERT(istext(vague_message) || target_detailed, "[type] operation display_results must have either a vague_message or target_detailed = TRUE!")

	surgeon.visible_message(
		message = detailed_message,
		self_message = self_message,
		vision_distance = 1,
		ignored_mobs = target_detailed ? null : target
	)
	if(target_detailed)
		return

	var/you_feel = pick("a brief pain", "your body tense up", "an unnerving sensation")
	target.show_message(
		msg = vague_message || detailed_message || span_notice("You feel [you_feel] as you are operated on."),
		type = MSG_VISUAL,
		alt_msg = span_notice("You feel [you_feel] as you are operated on."),
	)

/// Display pain message to the target based on their traits and condition
/datum/surgery_operation/proc/display_pain(mob/living/target, pain_message, mechanical_surgery = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

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
	PROTECTED_PROC(TRUE)

	if(isitem(tool) && (operation_flags & OPERATION_MECHANIC))
		var/obj/item/realtool = tool
		realtool.play_tool_sound(operating_on)
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

/// Helper for getting an operating compupter the patient is linked to
/datum/surgery_operation/proc/locate_operating_computer(atom/movable/operating_on)
	SHOULD_NOT_OVERRIDE(TRUE)
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
	PROTECTED_PROC(TRUE)
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
	PRIVATE_PROC(TRUE)

	var/preop_time = world.time
	var/mob/living/patient = get_patient(operating_on)
	if(!pre_preop(operating_on, surgeon, tool, operation_args))
		return FALSE
	// if pre_preop slept, sanity check that everything is still valid
	if(preop_time != world.time && (patient != get_patient(operating_on) || !surgeon.Adjacent(patient) || !surgeon.is_holding(tool) || !operate_check(patient, operating_on, surgeon, tool, operation_args)))
		return FALSE

	play_operation_sound(operating_on, surgeon, tool, preop_sound)
	on_preop(operating_on, surgeon, tool, operation_args)
	return TRUE

/**
 * Used to customize behavior when the operation starts
 */
/datum/surgery_operation/proc/on_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
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
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

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
	PROTECTED_PROC(TRUE)
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
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

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
	PROTECTED_PROC(TRUE)
	var/mob/living/patient = get_patient(operating_on)

	var/screwedmessage = ""
	switch(operation_args[OPERATION_SPEED])
		if(2.5 to 3)
			screwedmessage = " You almost had it, though."
		if(3 to 4)
			pass()
		if(4 to 5)
			screwedmessage = " This is hard to get right in these conditions..."
		if(5 to INFINITY)
			screwedmessage = " This is practically impossible in these conditions..."
	if(operation_args[OPERATION_FORCE_FAIL])
		screwedmessage = " Intentionally."

	display_results(
		surgeon,
		patient,
		span_warning("You screw up![screwedmessage]"),
		span_warning("[surgeon] screws up!"),
		span_notice("[surgeon] finishes."),
		TRUE, //By default the patient will notice if the wrong thing has been cut
	)

/**
 * Basic operations are a simple base type for surgeries that
 * 1. Target a specific zone on humans
 * 2. Work on non-humans
 *
 * Use this as a bsae if your surgery needs to work on everyone
 *
 * "operating_on" is the mob being operated on, be it carbon or non-carbon.
 * If the mob is carbon, we check the relevant bodypart for surgery states and traits. No bodypart, no operation.
 * If the mob is non-carbon, we just check the mob directly.
 */
/datum/surgery_operation/basic
	abstract_type = /datum/surgery_operation/basic
	/// Biotype required to perform this operation
	var/required_biotype = ~MOB_ROBOTIC
	/// The zone we are expected to be working on, even if the target is a non-carbon mob
	var/target_zone = BODY_ZONE_CHEST
	/// When working on carbons, what bodypart are we working on? Keep it representative of the required biotype
	var/required_bodytype = ~BODYTYPE_ROBOTIC

/datum/surgery_operation/basic/all_required_strings()
	. = list()
	if(required_biotype)
		. += "operate on [target_zone ? "[parse_zone(target_zone)] (target [parse_zone(target_zone)])" : "patient"]"
	else if(target_zone)
		. += "operate on [parse_zone(target_zone)] (target [parse_zone(target_zone)])"
	. += ..()

/datum/surgery_operation/basic/all_blocked_strings()
	. = ..()
	if(required_biotype & MOB_ROBOTIC)
		. += "the patient must not be organic"
	else if(required_biotype)
		. += "the patient must not be robotic"

/datum/surgery_operation/basic/is_available(mob/living/patient, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(target_zone && target_zone != operated_zone)
		return FALSE
	if(!HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE))
		return FALSE
	if(required_biotype && !(patient.mob_biotypes & required_biotype))
		return FALSE
	if(!patient.has_limbs || !target_zone)
		return ..()

	var/obj/item/bodypart/carbon_part = patient.get_bodypart(target_zone)
	if(isnull(carbon_part))
		return FALSE
	if(!HAS_TRAIT(carbon_part, TRAIT_READY_TO_OPERATE))
		return FALSE
	if(required_bodytype && !(carbon_part.bodytype & required_bodytype))
		return FALSE
	return ..()

/datum/surgery_operation/basic/has_surgery_state(mob/living/patient, state)
	var/obj/item/bodypart/carbon_part = patient.get_bodypart(target_zone)
	if(isnull(carbon_part)) // non-carbon
		var/datum/status_effect/basic_surgery_state/state_holder = patient.has_status_effect(__IMPLIED_TYPE__)
		return HAS_SURGERY_STATE(state_holder?.surgery_state, state & (SURGERY_BONE_SAWED|SURGERY_SKIN_OPEN)) // these are the only states basic mobs support, update this if that changes

	return LIMB_HAS_SURGERY_STATE(carbon_part, state)

/datum/surgery_operation/basic/has_any_surgery_state(mob/living/patient, state)
	var/obj/item/bodypart/carbon_part = patient.get_bodypart(target_zone)
	if(isnull(carbon_part)) // non-carbon
		var/datum/status_effect/basic_surgery_state/state_holder = patient.has_status_effect(__IMPLIED_TYPE__)
		return HAS_ANY_SURGERY_STATE(state_holder?.surgery_state, state)

	return LIMB_HAS_ANY_SURGERY_STATE(carbon_part, state)

/**
 * Limb opterations are a base focused on the limb the surgeon is targeting
 *
 * Use this if your surgery targets a specific limb on the mob
 *
 * "operating_on" is asserted to be a bodypart - the bodypart the surgeon is targeting.
 * If there is no bodypart, there's no operation.
 */
/datum/surgery_operation/limb
	abstract_type = /datum/surgery_operation/limb
	/// Body type required to perform this operation
	var/required_bodytype = NONE

/datum/surgery_operation/limb/all_blocked_strings()
	. = ..()
	if(required_bodytype & BODYTYPE_ROBOTIC)
		. += "the limb must not be organic"
	else if(required_bodytype & BODYTYPE_ORGANIC)
		. += "the limb must not be cybernetic"

/datum/surgery_operation/limb/get_operation_target(mob/living/patient, body_zone)
	return patient.get_bodypart(deprecise_zone(body_zone))

/datum/surgery_operation/limb/is_available(obj/item/bodypart/limb, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	// targeting groin will redirect you to the chest
	if(limb.body_zone != deprecise_zone(operated_zone))
		return FALSE
	if(required_bodytype && !(limb.bodytype & required_bodytype))
		return FALSE
	if(!HAS_TRAIT(limb, TRAIT_READY_TO_OPERATE))
		return FALSE

	return ..()

/datum/surgery_operation/limb/has_surgery_state(obj/item/bodypart/limb, state)
	return LIMB_HAS_SURGERY_STATE(limb, state)

/datum/surgery_operation/limb/has_any_surgery_state(obj/item/bodypart/limb, state)
	return LIMB_HAS_ANY_SURGERY_STATE(limb, state)

/datum/surgery_operation/limb/get_patient(obj/item/bodypart/limb)
	return limb.owner

/**
 * Organ operations are a base focused on a specific organ typepath
 *
 * Use this if your surgery targets a specific organ type
 *
 * "operating_on" is asserted to be an organ of the type defined by target_type.
 * No organ of that type, no operation.
 */
/datum/surgery_operation/organ
	abstract_type = /datum/surgery_operation/organ
	/// Biotype required to perform this operation
	var/required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	/// The type of organ this operation can target
	var/obj/item/organ/target_type

/datum/surgery_operation/organ/all_required_strings()
	return list("operate on [target_type::name] (target [target_type::zone])") + ..()

/datum/surgery_operation/organ/all_blocked_strings()
	. = ..()
	if(required_organ_flag & BODYTYPE_ROBOTIC)
		. += "the organ must not be organic"
	else if(required_organ_flag & ORGAN_TYPE_FLAGS)
		. += "the organ must not be cybernetic"

/datum/surgery_operation/organ/get_default_radial_image()
	return get_generic_limb_radial_image(target_type::zone)

/datum/surgery_operation/organ/get_operation_target(mob/living/patient, body_zone)
	return patient.get_organ_by_type(target_type)

/datum/surgery_operation/organ/get_patient(obj/item/organ/organ)
	return organ.owner

/datum/surgery_operation/organ/is_available(obj/item/organ/organ, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(organ.zone != operated_zone) // this check prevents eyes from showing up in head operations
		return FALSE
	if(required_organ_flag && !(organ.organ_flags & required_organ_flag))
		return FALSE
	if(!HAS_TRAIT(organ.bodypart_owner, TRAIT_READY_TO_OPERATE))
		return FALSE

	return ..()

/datum/surgery_operation/organ/has_surgery_state(obj/item/organ/organ, state)
	return LIMB_HAS_SURGERY_STATE(organ.bodypart_owner, state)

/datum/surgery_operation/organ/has_any_surgery_state(obj/item/organ/organ, state)
	return LIMB_HAS_ANY_SURGERY_STATE(organ.bodypart_owner, state)
