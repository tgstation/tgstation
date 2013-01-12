/* SURGERY STEPS */

/datum/surgery_step
	// type path referencing the required tool for this step
	var/required_tool = null

	// type path referencing tools that can be used as substitude for this step
	var/list/allowed_tools = null

	// When multiple steps can be applied with the current tool etc., choose the one with higher priority

	// checks whether this step can be applied with the given user and target
	proc/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return 0

	// does stuff to begin the step, usually just printing messages
	proc/begin_step(user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
	proc/end_step(user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return

	// stuff that happens when the step fails
	proc/fail_step(user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return null

	// duration of the step
	var/min_duration = 0
	var/max_duration = 0

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0

	proc/isright(obj/item/tool)			//is it is a required surgical tool for this step
		return (istype(tool,required_tool))

	proc/isacceptable(obj/item/tool)	//is it is an accepted replacement tool for this step
		if (allowed_tools)
			for (var/T in allowed_tools)
				if (istype(tool,T))
					return 1
		return 0

proc/spread_germs_to_organ(datum/organ/external/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E)) return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level

	E.germ_level = max(germ_level,E.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.

proc/do_surgery(mob/living/M, mob/living/user, obj/item/tool)
	if(!istype(M,/mob/living/carbon))
		return 0
	if (user.a_intent == "harm")	//check for Hippocratic Oath
		return 0
	for(var/datum/surgery_step/S in surgery_steps)
		if( S.isright(tool) || S.isacceptable(tool) && \
		S.can_use(user, M, user.zone_sel.selecting, tool))	 	//check if tool is right or close enough and if this step is possible
			S.begin_step(user, M, user.zone_sel.selecting, tool)			//start on it
			if(do_mob(user, M, rand(S.min_duration, S.max_duration)))	//if user did nto move or changed hands
				S.end_step(user, M, user.zone_sel.selecting, tool)		//finish successfully
			else														//or
				S.fail_step(user, M, user.zone_sel.selecting, tool)		//malpractice~
			return	1	  												//don't want to do weapony things after surgery
	return 0

/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/appendix =	0
	var/ribcage =	0