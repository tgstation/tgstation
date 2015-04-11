/datum/surgery
	var/name = "surgery"
	var/status = 1
	var/list/steps = list()										//Steps in a surgery
	var/step_in_progress = 0									//Actively performing a Surgery
	var/list/species = list(/mob/living/carbon/human)			//Acceptable Species
	var/location = "chest"										//Surgery location
	var/target_must_be_dead = 0									//Needs to be dead
	var/target_must_be_fat = 0									//Needs to be fat
	var/requires_organic_chest = 0								//Prevents you from performing an operation on Robotic chests***
	var/has_multi_loc = 0 										//Multiple locations - RR
	var/user_species_restricted = 0 							//Surgery only performable BY species
	var/list/user_species_ids

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


//*** This may seem entirely redundant because of Organic organs only having operations but you CAN circumvent that due to
//all surgeries (except augmentation) not checking where the surgeon aims so this is just a double check, it IS needed - RR