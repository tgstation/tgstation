/datum/surgery
	///The name of the surgery operation
	var/name = "surgery"
	///The description of the surgery, what it does.
	var/desc

	///From __DEFINES/surgery.dm
	///Selection: SURGERY_IGNORE_CLOTHES | SURGERY_SELF_OPERABLE | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	var/surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB
	///The surgery step we're currently on, increases each time we do a step.
	var/status = 1
	///All steps the surgery has to do to complete.
	var/list/steps = list()
	///Boolean on whether a surgery step is currently being done, to prevent multi-surgery.
	var/step_in_progress = FALSE

	///The bodypart this specific surgery is being performed on.
	var/location = BODY_ZONE_CHEST
	///The possible bodyparts that the surgery can be started on.
	var/list/possible_locs = list()
	///Mobs that are valid to have surgery performed on them.
	var/list/target_mobtypes = list(/mob/living/carbon/human)
	///The person the surgery is being performed on. Funnily enough, it isn't always a carbon.
	var/mob/living/carbon/target
	///The specific bodypart being operated on.
	var/obj/item/bodypart/operated_bodypart
	///The wound datum that is being operated on.
	var/datum/wound/operated_wound
	///Types of wounds this surgery can target.
	var/datum/wound/targetable_wound

	///The types of bodyparts that this surgery can have performed on it. Used for augmented surgeries.
	var/requires_bodypart_type = BODYTYPE_ORGANIC
	///The speed modifier given to the surgery through external means.
	var/speed_modifier = 0
	///Whether the surgery requires research to do. You need to add a design if using this!
	var/requires_tech = FALSE
	///typepath of a surgery that will, once researched, replace this surgery in the operating menu.
	var/replaced_by
	/// Organ being directly manipulated, used for checking if the organ is still in the body after surgery has begun
	var/organ_to_manipulate

/datum/surgery/New(atom/surgery_target, surgery_location, surgery_bodypart)
	. = ..()
	if(!surgery_target)
		return
	target = surgery_target
	target.surgeries += src
	if(surgery_location)
		location = surgery_location
	if(!surgery_bodypart)
		return
	operated_bodypart = surgery_bodypart
	if(targetable_wound)
		operated_wound = operated_bodypart.get_wound_type(targetable_wound)
		operated_wound.attached_surgery = src

	SEND_SIGNAL(surgery_target, COMSIG_MOB_SURGERY_STARTED, src, surgery_location, surgery_bodypart)

/datum/surgery/Destroy()
	if(operated_wound)
		operated_wound.attached_surgery = null
		operated_wound = null
	if(target)
		target.surgeries -= src
	target = null
	operated_bodypart = null
	return ..()


/datum/surgery/proc/can_start(mob/user, mob/living/patient) //FALSE to not show in list
	. = TRUE
	if(replaced_by == /datum/surgery)
		return FALSE

	// True surgeons (like abductor scientists) need no instructions
	if(HAS_TRAIT(user, TRAIT_SURGEON) || (!isnull(user.mind) && HAS_TRAIT(user.mind, TRAIT_SURGEON)))
		if(replaced_by) // only show top-level surgeries
			return FALSE
		else
			return TRUE

	if(!requires_tech && !replaced_by)
		return TRUE

	if(requires_tech)
		. = FALSE

	var/surgery_signal = SEND_SIGNAL(user, COMSIG_SURGERY_STARTING, src, patient)
	if(surgery_signal & COMPONENT_FORCE_SURGERY)
		return TRUE
	if(surgery_signal & COMPONENT_CANCEL_SURGERY)
		return FALSE

	var/turf/patient_turf = get_turf(patient)

	//Get the relevant operating computer
	var/obj/machinery/computer/operating/opcomputer = locate_operating_computer(patient_turf)
	if (isnull(opcomputer))
		return .
	if(replaced_by in opcomputer.advanced_surgeries)
		return FALSE
	if(type in opcomputer.advanced_surgeries)
		return TRUE

/datum/surgery/proc/next_step(mob/living/user, modifiers)
	if(location != user.zone_selected)
		return FALSE
	if(user.combat_mode)
		return FALSE
	if(step_in_progress)
		return TRUE

	var/try_to_fail = FALSE
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		try_to_fail = TRUE

	var/datum/surgery_step/step = get_surgery_step()
	if(step)
		var/obj/item/tool = user.get_active_held_item()
		if(step.try_op(user, target, user.zone_selected, tool, src, try_to_fail))
			return TRUE
		if(tool && tool.item_flags & SURGICAL_TOOL) //Just because you used the wrong tool it doesn't mean you meant to whack the patient with it
			to_chat(user, span_warning("This step requires a different tool!"))
			return TRUE
	return FALSE

/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[status]
	return new step_type

/datum/surgery/proc/get_surgery_next_step()
	if(status < steps.len)
		var/step_type = steps[status + 1]
		return new step_type
	return null

/datum/surgery/proc/complete(mob/surgeon)
	SSblackbox.record_feedback("tally", "surgeries_completed", 1, type)
	surgeon.add_mob_memory(/datum/memory/surgery, deuteragonist = surgeon, surgery_type = name)
	qdel(src)

/// Returns a nearby operating computer linked to an operating table
/datum/surgery/proc/locate_operating_computer(turf/patient_turf)
	if (isnull(patient_turf))
		return null

	var/obj/structure/table/optable/operating_table = locate(/obj/structure/table/optable, patient_turf)
	var/obj/machinery/computer/operating/operating_computer = operating_table?.computer

	if (isnull(operating_computer))
		return null

	if(operating_computer.machine_stat & (NOPOWER|BROKEN))
		return null

	return operating_computer

/datum/surgery/advanced
	name = "advanced surgery"
	requires_tech = TRUE

/obj/item/disk/surgery
	name = "Surgery Procedure Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/list/surgeries

/obj/item/disk/surgery/debug
	name = "Debug Surgery Disk"
	desc = "A disk that contains all existing surgery procedures."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)

/obj/item/disk/surgery/debug/Initialize(mapload)
	. = ..()
	surgeries = list()
	var/list/req_tech_surgeries = subtypesof(/datum/surgery)
	for(var/datum/surgery/beep as anything in req_tech_surgeries)
		if(initial(beep.requires_tech))
			surgeries += beep

//INFO
//Check /mob/living/carbon/attackby for how surgery progresses, and also /mob/living/carbon/attack_hand.
//As of Feb 21 2013 they are in code/modules/mob/living/carbon/carbon.dm, lines 459 and 51 respectively.
//Other important variables are var/list/surgeries (/mob/living) and var/list/organs (/mob/living/carbon)
// var/list/bodyparts (/mob/living/carbon/human) is the LIMBS of a Mob.
//Surgical procedures are initiated by attempt_initiate_surgery(), which is called by surgical drapes and bedsheets.


//TODO
//specific steps for some surgeries (fluff text)
//more interesting failure options
//randomised complications
//more surgeries!
//add a probability modifier for the state of the surgeon- health, twitching, etc. blindness, god forbid.
//helper for converting a zone_sel.selecting to body part (for damage)


//RESOLVED ISSUES //"Todo" jobs that have been completed
//combine hands/feet into the arms - Hands/feet were removed - RR
//surgeries (not steps) that can be initiated on any body part (corresponding with damage locations) - Call this one done, see possible_locs var - c0
