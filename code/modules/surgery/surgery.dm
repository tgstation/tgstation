/datum/surgery
	var/name = "surgery"
	var/status = 1
	var/list/steps = list()										//Steps in a surgery
	var/step_in_progress = 0									//Actively performing a Surgery
	var/can_cancel = 1											//Can cancel this surgery after step 1 with cautery
	var/list/species = list(/mob/living/carbon/human)			//Acceptable Species
	var/location = "chest"										//Surgery location
	var/requires_organic_bodypart = 1							//Prevents you from performing an operation on robotic limbs
	var/list/possible_locs = list() 							//Multiple locations -- c0
	var/ignore_clothes = 0										//This surgery ignores clothes
	var/obj/item/organ/organ									//Operable body part


/datum/surgery/proc/can_start(mob/user, mob/living/carbon/target)
	// if 0 surgery wont show up in list
	// put special restrictions here
	return 1


/datum/surgery/proc/next_step(mob/user, mob/living/carbon/target)
	if(step_in_progress)	return

	var/datum/surgery_step/S = get_surgery_step()
	if(S)
		if(S.try_op(user, target, user.zone_sel.selecting, user.get_active_hand(), src))
			return 1
	return 0

/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[status]
	return new step_type


/datum/surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries -= src
	src = null



//INFO
//Check /mob/living/carbon/attackby for how surgery progresses, and also /mob/living/carbon/attack_hand.
//As of Feb 21 2013 they are in code/modules/mob/living/carbon/carbon.dm, lines 459 and 51 respectively.
//Other important variables are var/list/surgeries (/mob/living) and var/list/internal_organs (/mob/living/carbon)
// var/list/organs (/mob/living/carbon/human) is the LIMBS of a Mob.
//Surgical procedures are initiated by attempt_initiate_surgery(), which is called by surgical drapes and bedsheets.
// /code/modules/surgery/multiple_location_example.dm contains steps to setup a multiple location operation.


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
//surgeries (not steps) that can be initiated on any body part (corresponding with damage locations) - Call this one done, see multiple_location_example.dm - RR