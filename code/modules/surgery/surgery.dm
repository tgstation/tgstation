<<<<<<< HEAD
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
	var/obj/item/organ/organ								//Operable body part
	var/requires_bodypart = TRUE							//Surgery available only when a bodypart is present, or only when it is missing.
	var/success_multiplier = 0								//Step success propability multiplier


/datum/surgery/New(surgery_target, surgery_location, surgery_organ)
	..()
	if(surgery_target)
		target = surgery_target
		target.surgeries += src
		if(surgery_location)
			location = surgery_location
		if(surgery_organ)
			organ = surgery_organ

/datum/surgery/Destroy()
	if(target)
		target.surgeries -= src
	target = null
	organ = null
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
		if(S.try_op(user, target, user.zone_selected, user.get_active_hand(), src))
			return 1
	return 0

/datum/surgery/proc/get_surgery_step()
	var/step_type = steps[status]
	return new step_type

/datum/surgery/proc/complete()
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
=======
/* SURGERY STEPS */

/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	// type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = null
	var/list/disallowed_species = null

	// duration of the step
	var/min_duration = 0
	var/max_duration = 0

	var/list/mob/doing_surgery = list() //who's doing this RIGHT NOW

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

	//returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	for (var/T in allowed_tools)
		if (istype(tool,T))
			return allowed_tools[T]
	return 0

/datum/surgery_step/proc/check_anesthesia(var/mob/living/carbon/human/target)
	if( (target.sleeping>0 || target.stat))
		return 1
	if(prob(25)) // Pain is tolerable?  Pomf wanted this. - N3X
		return 1
	return 0

	// Checks if this step applies to the mutantrace of the user.
/datum/surgery_step/proc/is_valid_mutantrace(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return 0

	if(allowed_species)
		for(var/species in allowed_species)
			if(target.dna.mutantrace == species)
				return 1

	if(disallowed_species)
		for(var/species in disallowed_species)
			if (target.dna.mutantrace == species)
				return 0

	return 1

	// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return 0

	// once a surgery is selected, let's check if we can actually accomplish it
/datum/surgery_step/proc/can_operate(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return 1

	// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return 0
	if (can_infect && affected)
		spread_germs_to_organ(affected, user)
	if (ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if (blood_level)
			H.bloody_hands(target,0)
		if (blood_level > 1)
			H.bloody_body(target,0)
	if(istype(tool,/obj/item/weapon/scalpel/laser) || istype(tool,/obj/item/weapon/retractor/manager))
		tool.icon_state = "[initial(tool.icon_state)]_on"
		spawn(max_duration * tool.surgery_speed)//in case the player doesn't go all the way through the step (if he moves away, puts the tool away,...)
			tool.icon_state = "[initial(tool.icon_state)]_off"
	return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(istype(tool,/obj/item/weapon/scalpel/laser) || istype(tool,/obj/item/weapon/retractor/manager))
		tool.icon_state = "[initial(tool.icon_state)]_off"
	return

	// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return null

proc/spread_germs_to_organ(datum/organ/external/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E)) return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level
	if(!(E.status & (ORGAN_ROBOT|ORGAN_PEG))) //Germs on robotic limbs bad
		E.germ_level = max(germ_level,E.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.

proc/do_surgery(mob/living/M, mob/living/user, obj/item/tool)
	if(!istype(M,/mob/living/carbon/human))
		return 0
	if (user.a_intent == I_HURT)	//check for Hippocratic Oath
		return 0
	var/sleep_fail = 0
	var/clumsy = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		clumsy = ((M_CLUMSY in H.mutations) && prob(50))
	for(var/datum/surgery_step/S in surgery_steps)
		//check if tool is right or close enough and if this step is possible
		sleep_fail = 0
		if(S.tool_quality(tool))
			var/canuse = S.can_use(user, M, user.zone_sel.selecting, tool)
			if(canuse == -1) sleep_fail = 1
			if(canuse && S.is_valid_mutantrace(M) && !(M in S.doing_surgery))
				if(!S.can_operate(user, M, user.zone_sel.selecting, tool)) //ruh oh, we picked this step, but we can't actually do it for some special raisin
					return 1
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] started by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Started surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
				log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to perform surgery type [S.type] on [M.name] ([M.ckey])</font>")
				S.doing_surgery += M
				S.begin_step(user, M, user.zone_sel.selecting, tool)		//start on it
				var/selection = user.zone_sel.selecting
				//We had proper tools! (or RNG smiled.) and user did not move or change hands.
				if(do_mob(user, M, rand(S.min_duration, S.max_duration) * tool.surgery_speed) && (prob(S.tool_quality(tool) / (sleep_fail + clumsy + 1))) && selection == user.zone_sel.selecting)
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] successfully completed by [user.name] ([user.ckey])</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Successfully completed surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
					log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to successfully complete surgery type [S.type] on [M.name] ([M.ckey])</font>")
					S.end_step(user, M, user.zone_sel.selecting, tool)		//finish successfully
				else
					if ((tool in user.contents) && (user.Adjacent(M)))											//or
						if(sleep_fail)
							to_chat(user, "<span class='warning'>The patient is squirming around in pain!</span>")
							M.emote("scream",,, 1)
						M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] failed by [user.name] ([user.ckey])</font>")
						user.attack_log += text("\[[time_stamp()]\] <font color='red'>Failed surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
						log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to fail the surgery type [S.type] on [M.name] ([M.ckey])</font>")
						S.fail_step(user, M, user.zone_sel.selecting, tool)		//malpractice~
				if(M) //good, we still exist
					S.doing_surgery -= M
				else
					S.doing_surgery.Remove(null) //get rid of that now null reference
				return	1	  												//don't want to do weapony things after surgery
	if (user.a_intent == I_HELP)
		to_chat(user, "<span class='warning'>You can't see any useful way to use [tool] on [M].</span>")
		return 1
	return 0

proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1

/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/appendix =	0
	var/ribcage = 0
	var/butt = 0
	var/genitals = 0
	var/head_reattach = 0
	var/current_organ
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
