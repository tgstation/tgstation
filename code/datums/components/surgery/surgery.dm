
//makes this file more readable
///return value on next_step that will cause the surgeon to hit the victim
#define WHACK_PATIENT FALSE
///return value on next_step that will cause the surgeon to not hit the victim
#define DONT_WHACK_PATIENT TRUE


/**
 * ## surgery component!
 *
 * component attached to mobs when they're undergoing a surgery
 * todo list at bottom of the file- it was left from an older age but heck maybe it's still useful to someone bored enough
 * very unorthodox thing here: there are global instances of the surgery component attached to SSdcs, they have no signals and are used in surgery initiation checks.
 */
/datum/component/surgery
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///name of the surgery
	var/name = "surgery"
	///a description of the surgery
	var/desc = "surgery description"
	///doesn't allow this surgery if this type is unlocked. used for prototypes (set it to /datum/component/surgery/surgery) or upgraded surgeries replacing former ones (set it to what its superior version is)
	var/replaced_by

	//prerequisites to starting a surgery

	///types of mobs this surgery can be performed on
	var/list/target_mobtypes = list(/mob/living/carbon/human)
	///wound type this surgery targets
	var/datum/wound/targetable_wound
	///prevents you from performing an operation on incorrect limb types. ANY_BODYPART_ACCEPTED for any limb type
	var/requires_bodypart_type = BODYPART_ORGANIC
	///locations starting the surgery is possible in
	var/list/possible_locs = list()
	///makes this surgery available only when a bodypart is present, or only when it is missing.
	var/requires_bodypart = TRUE
	///makes this surgery not work on limbs that don't really exist
	var/requires_real_bodypart = FALSE
	///bool for whether this surgery requires the target to be lying down
	var/lying_required = TRUE
	///bool for whether this surgery can be self-performed
	var/self_operable = FALSE
	///handles techweb-oriented surgeries, previously restricted to the /advanced subtype (You still need to add designs)
	var/requires_tech = FALSE
	///bool that allows this surgery to ignore clothes- prevents starting otherwise!
	var/ignore_clothes = FALSE

	//surgery states

	///limb the surgery is being done on
	var/operated_body_zone
	///body part getting operated on
	var/obj/item/bodypart/operated_bodypart
	///wound datum instance getting operated on
	var/datum/wound/operated_wound

	//step vars

	///index of the step the surgery is on
	var/step_index = 1
	///list of datum/surgery_step that need to be completed in order to finish the surgery
	var/list/steps = list()
	///sanity boolean for a surgery step being performed
	var/step_in_progress = FALSE
	///whether the surgery is cancellable with a cautery tool (after the first surgery_step)
	var/can_cancel = TRUE
	///step speed modifier
	var/speed_modifier = 0

/datum/component/surgery/Initialize(operated_body_zone, operated_bodypart, operated_wound)
	if(!iscarbon(parent) && !istype(parent, /datum/controller/subsystem))
		return COMPONENT_INCOMPATIBLE
	src.operated_body_zone = operated_body_zone
	src.operated_bodypart = operated_bodypart
	if(operated_wound)
		src.operated_wound = src.operated_bodypart.get_wound_type(targetable_wound)
	ADD_TRAIT(parent, TRAIT_SURGERY_PATIENT, src)

/datum/component/surgery/Destroy(force, silent)
	operated_bodypart = null
	REMOVE_TRAIT(parent, TRAIT_SURGERY_PATIENT, src)
	. = ..()

/datum/component/surgery/RegisterWithParent()
	. = ..()
	if(istype(parent, /datum/controller/subsystem))
		return

	RegisterSignal(parent, COMSIG_CARBON_REMOVE_LIMB, .proc/on_dropped_limb)

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(parent, COMSIG_CARBON_STERILIZED, .proc/on_sterilization)
	RegisterSignal(parent, COMSIG_SURGERY_INITIATED, .proc/on_new_surgery_initiated)
	if(operated_wound)
		RegisterSignal(operated_wound, COMSIG_PARENT_QDELETING, .proc/on_wound_destroy)

/datum/component/surgery/UnregisterFromParent()
	. = ..()
	if(istype(parent, /datum/controller/subsystem))
		return
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY))
	if(operated_wound)
		UnregisterSignal(operated_wound, COMSIG_PARENT_QDELETING)

///signal called on the operated_wound reference being destroyed (performing a surgery on a wound and then the wound healing mid surgery destroys the surgery.)
/datum/component/surgery/proc/on_wound_destroy(force)
	SIGNAL_HANDLER
	qdel(src)

///signal called on the patient being sterilized in some way
/datum/component/surgery/proc/on_sterilization(datum/source, bonus_speed_mod)
	SIGNAL_HANDLER
	//if you get more from the sterilization, then set it to that
	speed_modifier = max(bonus_speed_mod, speed_modifier)

///signal called on the patient gaining a limb
/datum/component/surgery/proc/limbs_added_burden(datum/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER
	//limb replacement on a now replaced limb
	if(new_limb.body_zone == operated_body_zone)
		qdel(src)

///signal called on the patient losing a limb
/datum/component/surgery/proc/on_dropped_limb(datum/source, obj/item/bodypart/old_limb, special)
	SIGNAL_HANDLER
	//surgery on a now removed limb
	if(old_limb.body_zone == operated_body_zone)
		qdel(src)

///signal called on parent being attacked with an open hand
/datum/component/surgery/proc/on_attack_hand(datum/source, mob/living/surgeon, modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/next_step_attempt, surgeon, modifiers)

///signal called on parent being attacked with an item
/datum/component/surgery/proc/on_attackby(datum/source, obj/item/surgery_tool, mob/living/surgeon, params)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/next_step_attempt, surgeon, params2list(params))

/datum/component/surgery/proc/next_step_attempt(datum/source, mob/living/surgeon, modifiers)
	var/mob/living/carbon/patient = parent
	//split each fail case into a different check for readability
	if(lying_required && patient.body_position != LYING_DOWN)
		return
	if(!self_operable && surgeon == patient)
		return
	if(surgeon.combat_mode)
		return
	if(next_step(surgeon, modifiers))
		return COMPONENT_NO_AFTERATTACK

/datum/component/surgery/proc/next_step(mob/living/surgeon, modifiers)
	if(operated_body_zone != surgeon.zone_selected)
		return WHACK_PATIENT
	if(step_in_progress)
		return DONT_WHACK_PATIENT

	var/try_to_fail = FALSE
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		try_to_fail = TRUE

	var/datum/surgery_step/current_step = get_current_surgery_step()
	if(current_step)
		var/obj/item/tool = surgeon.get_active_held_item()
		if(current_step.try_op(surgeon, parent, surgeon.zone_selected, tool, src, try_to_fail))
			return DONT_WHACK_PATIENT
		if(tool?.item_flags & SURGICAL_TOOL) //Just because you used the wrong tool it doesn't mean you meant to whack the patient with it
			surgeon.balloon_alert(parent, "different tool required!")
			return DONT_WHACK_PATIENT
	return WHACK_PATIENT

/**
 * get_current_surgery_step is a small helper that gets the current step in the surgery and initializes it
 *
 * Returns initialized surgery_step datum
 */
/datum/component/surgery/proc/get_current_surgery_step()
	var/step_type = steps[step_index]
	return new step_type

/**
 * get_current_surgery_step is a small helper that gets the NEXT step in the surgery and initializes it (if possible)
 *
 * Returns initialized surgery_step datum if possible, null otherwise
 */
/datum/component/surgery/proc/get_next_surgery_step()
	if(step_index < steps.len)
		var/step_type = steps[step_index + 1]
		return new step_type

/datum/component/surgery/proc/complete()
	SSblackbox.record_feedback("tally", "surgeries_completed", 1, type)
	qdel(src)

/**
 * can_start is all the checks needed to see if a surgeon can start this surgery
 *
 * Arguments:
 * * surgeon: mob performing the surgery
 * * patient: mob being operated on
 * Returns TRUE if it should show as a possible surgery, FALSE if not
 */
/datum/component/surgery/proc/can_start(mob/surgeon, mob/living/patient)
	. = TRUE
	if(replaced_by == /datum/component/surgery)
		return FALSE

	// True surgeons (like abductor scientists) need no instructions
	if(HAS_TRAIT(surgeon, TRAIT_SURGEON) || HAS_TRAIT(surgeon.mind, TRAIT_SURGEON))
		if(replaced_by) // only show top-level surgeries
			return FALSE
		else
			return TRUE

	if(!requires_tech && !replaced_by)
		return TRUE

	if(requires_tech)
		. = FALSE

	if(iscyborg(surgeon))
		var/mob/living/silicon/robot/robo_surgeon = surgeon
		var/obj/item/surgical_processor/surgical_processor = locate() in robo_surgeon.model.modules
		if(surgical_processor) //no early return for !surgical_processor since we want to check optable should this not exist.
			if(replaced_by in surgical_processor.advanced_surgeries)
				return FALSE
			if(type in surgical_processor.advanced_surgeries)
				return TRUE

	var/turf/patient_turf = get_turf(patient)

	//Get the relevant operating computer
	var/obj/machinery/computer/operating/opcomputer
	var/obj/structure/table/optable/optable = locate(/obj/structure/table/optable, patient_turf)
	if(optable?.computer)
		opcomputer = optable.computer
	if(!opcomputer)
		return
	if(opcomputer.machine_stat & (NOPOWER|BROKEN))
		return .
	if(replaced_by in opcomputer.advanced_surgeries)
		return FALSE
	if(type in opcomputer.advanced_surgeries)
		return TRUE

#undef WHACK_PATIENT
#undef DONT_WHACK_PATIENT

///signal called on a new surgery being attempted on the patient. try_cancellation will send the special return value but will not actually try removing this surgery.
/datum/component/surgery/proc/on_new_surgery_initiated(datum/source, selected_zone, obj/item/surgery_drape, mob/living/patient, mob/living/surgeon, try_cancellation)
	SIGNAL_HANDLER
	if(selected_zone != operated_body_zone)
		return
	. = CANCEL_INITIATION
	if(step_in_progress || !try_cancellation)
		return
	if(step_index == 1)
		surgeon.visible_message(
			span_notice("[surgeon] removes [surgery_drape] from [patient]'s [parse_zone(selected_zone)]."), \
			span_notice("You remove [surgery_drape] from [patient]'s [parse_zone(selected_zone)].") \
		)
		qdel(src)
		return
	if(!can_cancel)
		return
	var/required_tool_type = TOOL_CAUTERY
	var/obj/item/close_tool = surgeon.get_inactive_held_item()
	var/is_robotic = requires_bodypart_type == BODYPART_ROBOTIC
	if(is_robotic)
		required_tool_type = TOOL_SCREWDRIVER
	if(iscyborg(surgeon))
		close_tool = locate(/obj/item/cautery) in surgeon.held_items
		if(!close_tool)
			to_chat(surgeon, span_warning("You need to equip a cautery in an inactive slot to stop [patient]'s surgery!"))
			return
	else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
		to_chat(surgeon, span_warning("You need to hold a [tool_behaviour_name(required_tool_type)] in your inactive hand to stop [patient]'s surgery!"))
		return
	operated_bodypart?.generic_bleedstacks -= 5
	surgeon.visible_message(
		span_notice("[surgeon] closes [patient]'s [parse_zone(selected_zone)] with [close_tool] and removes [surgery_drape]."), \
		span_notice("You close [patient]'s [parse_zone(selected_zone)] with [close_tool] and remove [surgery_drape].") \
	)
	qdel(src)

/*
/// Does the surgery de-initiation.
/datum/component/surgery/proc/try_ending_surgery(selected_zone, mob/living/patient, mob/living/surgeon)
*/
