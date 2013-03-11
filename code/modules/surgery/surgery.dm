/datum/surgery
	var/name = "surgery"
	var/status = 1
	var/list/steps = list()
	var/step_in_progress = 0
	var/list/species = list(/mob/living/carbon/human)
	var/location = "chest"
	var/target_must_be_dead = 0
	var/target_must_be_fat = 0


/datum/surgery/proc/next_step(mob/user, mob/living/carbon/target)
	if(step_in_progress)	return

	var/procedure = steps[status]
	var/datum/surgery_step/S = new procedure
	if(S)
		if(S.try_op(user, target, user.zone_sel.selecting, user.get_active_hand(), src))
			return 1
	return 0


/datum/surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries -= src
	src = null


//INFO
//Check /mob/living/carbon/attackby for how surgery progresses, and also /mob/living/carbon/attack_hand.
//As of Feb 21 2013 they are in code/modules/mob/living/carbon/carbon.dm, lines 459 and 51 respectively.
//Other important variables are var/list/surgeries (/mob/living) and var/list/internal_organs (/mob/living/carbon).
//Surgical procedures are initiated by attempt_initiate_surgery(), which is called by surgical drapes and bedsheets.


//TODO
//specific steps for some surgeries (fluff text)
//R&D researching new surgeries (especially for non-humans)
//surgeries (not steps) that can be initiated on any body part (corresponding with damage locations)
//more interesting failure options
//randomised complications
//more surgeries!
//add a probability modifier for the state of the surgeon- health, twitching, etc. blindness, god forbid.
//helper for converting a zone_sel.selecting to body part (for damage)
//combine hands/feet into the arms