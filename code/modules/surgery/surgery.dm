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
	return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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
		if( S.tool_quality(tool))
			var/canuse = S.can_use(user, M, user.zone_sel.selecting, tool)
			if(canuse == -1) sleep_fail = 1
			if(canuse && S.is_valid_mutantrace(M) && !(M in S.doing_surgery))
				S.doing_surgery += M
				S.begin_step(user, M, user.zone_sel.selecting, tool)		//start on it
				var/selection = user.zone_sel.selecting
				//We had proper tools! (or RNG smiled.) and user did not move or change hands.
				if(do_mob(user, M, rand(S.min_duration, S.max_duration)) && (prob(S.tool_quality(tool) / (sleep_fail + clumsy + 1))) && selection == user.zone_sel.selecting)
					S.end_step(user, M, user.zone_sel.selecting, tool)		//finish successfully
				else
					if ((tool in user.contents) && (user.Adjacent(M)))											//or
						if(sleep_fail)
							user << "<span class='warning'>The patient is squirming around in pain!</span>"
							M.emote("scream",,, 1)
						S.fail_step(user, M, user.zone_sel.selecting, tool)		//malpractice~
				if(M) //good, we still exist
					S.doing_surgery -= M
				else
					S.doing_surgery.Remove(null) //get rid of that now null reference
				return	1	  												//don't want to do weapony things after surgery
	if (user.a_intent == I_HELP)
		user << "<span class='warning'>You can't see any useful way to use [tool] on [M].</span>"
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
