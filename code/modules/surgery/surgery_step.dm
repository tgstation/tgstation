/datum/surgery_step
	var/name
	var/list/implements = list()	//format is path = probability of success. alternatively
	var/implement_type = null		//the current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/accept_hand = 0				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = 0			//does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/time = 10					//how long does the step take?


/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/success = 0
	if(accept_hand)
		if(!tool)
			success = 1
	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = 1
	else
		for(var/path in implements)
			if(istype(tool, path))
				implement_type = path
				if(tool_check(user, tool))
					success = 1

	if(success)
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone) || surgery.ignore_clothes)
				initiate(user, target, target_zone, tool, surgery)
				return 1
			else
				user << "<span class='warning'>You need to expose [target]'s [parse_zone(target_zone)] to perform surgery on it!</span>"
				return 1	//returns 1 so we don't stab the guy in the dick or wherever.
	if(iscyborg(user) && user.a_intent != INTENT_HARM) //to save asimov borgs a LOT of heartache
		return 1
	return 0


/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.step_in_progress = 1

	var/speed_mod = 1

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = 0
		return

	if(tool)
		speed_mod = tool.toolspeed

	if(do_after(user, time * speed_mod, target = target))
		var/advance = 0
		var/prob_chance = 100

		if(implement_type)	//this means it isn't a require hand or any item step.
			prob_chance = implements[implement_type]
		prob_chance *= surgery.get_propability_multiplier()

		if(prob(prob_chance) || iscyborg(user))
			if(success(user, target, target_zone, tool, surgery))
				advance = 1
		else
			if(failure(user, target, target_zone, tool, surgery))
				advance = 1

		if(advance)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete()

	surgery.step_in_progress = 0


/datum/surgery_step/proc/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to perform surgery on [target].", "<span class='notice'>You begin to perform surgery on [target]...</span>")


/datum/surgery_step/proc/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] succeeds!", "<span class='notice'>You succeed.</span>")
	return 1

/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] screws up!</span>", "<span class='warning'>You screw up!</span>")
	return 0

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return 1
