/datum/surgery
	var/name = "surgery"
	var/status = 1
	var/list/steps = list()									//Steps in a surgery
	var/step_in_progress = 0								//Actively performing a Surgery
	var/can_cancel = 1										//Can cancel this surgery after step 1 with cautery
	var/list/species = list(/mob/living/carbon/human)		//Acceptable Species
	var/location = "chest"									//Surgery location
	var/requires_organic_bodypart = 1						//Prevents you from performing an operation on robotic limbs
	var/list/possible_locs = list() 						//Multiple locations
	var/ignore_clothes = 0									//This surgery ignores clothes
	var/mob/living/carbon/target							//Operation target mob
	var/obj/item/bodypart/operated_bodypart					//Operable body part
	var/requires_bodypart = TRUE							//Surgery available only when a bodypart is present, or only when it is missing.
	var/success_multiplier = 0								//Step success propability multiplier


/datum/surgery/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(surgery_target)
		target = surgery_target
		target.surgeries += src
		if(surgery_location)
			location = surgery_location
		if(surgery_bodypart)
			operated_bodypart = surgery_bodypart

/datum/surgery/Destroy()
	if(target)
		target.surgeries -= src
	target = null
	operated_bodypart = null
	return ..()


/datum/surgery/proc/can_start(mob/user, mob/living/carbon/target)
	// if 0 surgery wont show up in list
	// put special restrictions here
	return 1


/datum/surgery/proc/next_step(mob/user)
	if(step_in_progress)
		return 1

	var/datum/surgery_step/S = get_surgery_step()
	if(S)
		if(S.try_op(user, target, user.zone_selected, user.get_active_held_item(), src))
			return 1
	return 0

/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[status]
	return new step_type

/datum/surgery/proc/complete()
	feedback_add_details("surgeries_completed", type)
	qdel(src)


/datum/surgery/proc/get_propability_multiplier()
	var/propability = 0.5
	var/turf/T = get_turf(target)

	if(locate(/obj/structure/table/optable, T))
		propability = 1
	else if(locate(/obj/structure/table, T))
		propability = 0.8
	else if(locate(/obj/structure/bed, T))
		propability = 0.7

	return propability + success_multiplier




//INFO
//Check /mob/living/carbon/attackby for how surgery progresses, and also /mob/living/carbon/attack_hand.
//As of Feb 21 2013 they are in code/modules/mob/living/carbon/carbon.dm, lines 459 and 51 respectively.
//Other important variables are var/list/surgeries (/mob/living) and var/list/internal_organs (/mob/living/carbon)
// var/list/bodyparts (/mob/living/carbon/human) is the LIMBS of a Mob.
//Surgical procedures are initiated by attempt_initiate_surgery(), which is called by surgical drapes and bedsheets.


//TODO
//specific steps for some surgeries (fluff text)
//R&D researching new surgeries (especially for non-humans)
//more interesting failure options
//randomised complications
//more surgeries!
//add a probability modifier for the state of the surgeon- health, twitching, etc. blindness, god forbid.
//helper for converting a zone_sel.selecting to body part (for damage)


//RESOLVED ISSUES //"Todo" jobs that have been completed
//combine hands/feet into the arms - Hands/feet were removed - RR
//surgeries (not steps) that can be initiated on any body part (corresponding with damage locations) - Call this one done, see possible_locs var - c0