/datum/surgery_step
	var/list/implements = list()	//format is path = probability of success. alternatively
	var/implement_type = null		//the current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/accept_hand = 0				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = 0			//does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/time = 10					//how long does the step take?
	var/new_organ = null 			//Used for multilocation operations
	var/list/allowed_organs = list()//Allowed organs, see Handle_Multi_Loc below - RR


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
	if(isrobot(user) && user.a_intent != "harm") //to save asimov borgs a LOT of heartache
		return 1
	return 0


/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.step_in_progress = 1

	if(surgery.has_multi_loc) //if it is multi-location, handle that
		Handle_Multi_Loc(user, target)

	preop(user, target, target_zone, tool)
	if(do_after(user, time))

		var/advance = 0
		var/prob_chance = 100

		if(implement_type)	//this means it isn't a require hand or any item step.
			prob_chance = implements[implement_type]
		prob_chance *= get_location_modifier(target)

		if(prob(prob_chance) || isrobot(user))
			if(success(user, target, target_zone, tool, surgery))
				advance = 1
		else
			if(failure(user, target, target_zone, tool, surgery))
				advance = 1

		if(advance)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete(target)

	surgery.step_in_progress = 0


/datum/surgery_step/proc/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to perform surgery on [target].", "<span class='notice'>You begin to perform surgery on [target]...</span>")


/datum/surgery_step/proc/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] succeeds!", "<span class='notice'>You succeed.</span>")
	return 1

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_damage(75,"brute","[target_zone]")
		user.visible_message("[user] saws [target]'s [parse_zone(target_zone)] open!", "<span class='notice'>You saw [target]'s [parse_zone(target_zone)] open.</span>")
	return 1

/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] screws up!</span>", "<span class='warning'>You screw up!</span>")
	return 0

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_organ_damage(45,0)
	return ..()

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return 1

/datum/surgery_step/proc/Handle_Multi_Loc(mob/user, mob/living/carbon/target) //this is here so MultiLoc Surgeries don't need to rewrite it each time - RR


	if(user.zone_sel.selecting in allowed_organs)

		switch(user.zone_sel.selecting) //Switch, for Aran - RR
			if("r_arm")
				new_organ = target.getlimb(/obj/item/organ/limb/r_arm)
			if("l_arm")
				new_organ = target.getlimb(/obj/item/organ/limb/l_arm)
			if("r_leg")
				new_organ = target.getlimb(/obj/item/organ/limb/r_leg)
			if("l_leg")
				new_organ = target.getlimb(/obj/item/organ/limb/l_leg)
			if("chest")
				new_organ = target.getlimb(/obj/item/organ/limb/chest)
			if("groin")
				new_organ = target.getlimb(/obj/item/organ/limb/chest)
			if("head")
				new_organ = target.getlimb(/obj/item/organ/limb/head)
			if("eyes")
				new_organ = target.getlimb(/obj/item/organ/limb/head)
			if("mouth")
				new_organ = target.getlimb(/obj/item/organ/limb/head)
			else
				user << "<span class='warning'>You cannot perform this operation on this body part!</span>" //Explain to the surgeon what went wrong - RR
				return 0

		return new_organ

	else
		return 0


