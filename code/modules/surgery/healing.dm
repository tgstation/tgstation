/datum/surgery/healing
	target_mobtypes = list(/mob/living)
	requires_bodypart_type = NONE
	replaced_by = /datum/surgery
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/heal,
		/datum/surgery_step/close,
	)

	var/healing_step_type
	var/antispam = FALSE

/datum/surgery/healing/can_start(mob/user, mob/living/patient)
	. = ..()
	if(!.)
		return .
	if(!(patient.mob_biotypes & (MOB_ORGANIC|MOB_HUMANOID)))
		return FALSE
	return .

/datum/surgery/healing/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(
			/datum/surgery_step/incise/nobleed,
			healing_step_type, //hehe cheeky
			/datum/surgery_step/close,
		)

/datum/surgery_step/heal
	name = "repair body (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCREWDRIVER = 65,
		TOOL_WIRECUTTER = 60,
		/obj/item/pen = 55)
	repeatable = TRUE
	time = 25
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	var/brutehealing = 0
	var/burnhealing = 0
	var/brute_multiplier = 0 //multiplies the damage that the patient has. if 0 the patient wont get any additional healing from the damage he has.
	var/burn_multiplier = 0

/// Returns a string letting the surgeon know roughly how much longer the surgery is estimated to take at the going rate
/datum/surgery_step/heal/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	return

/datum/surgery_step/heal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/woundtype
	if(brutehealing && burnhealing)
		woundtype = "wounds"
	else if(brutehealing)
		woundtype = "bruises"
	else //why are you trying to 0,0...?
		woundtype = "burns"
	if(istype(surgery,/datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		if(!the_surgery.antispam)
			display_results(
				user,
				target,
				span_notice("You attempt to patch some of [target]'s [woundtype]."),
				span_notice("[user] attempts to patch some of [target]'s [woundtype]."),
				span_notice("[user] attempts to patch some of [target]'s [woundtype]."),
			)
		display_pain(target, "Your [woundtype] sting like hell!")

/datum/surgery_step/heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(!..())
		return
	while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()))
		if(!..())
			break

/datum/surgery_step/heal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/user_msg = "You succeed in fixing some of [target]'s wounds" //no period, add initial space to "addons"
	var/target_msg = "[user] fixes some of [target]'s wounds" //see above
	var/brute_healed = brutehealing
	var/burn_healed = burnhealing
	var/dead_patient = FALSE
	if(target.stat == DEAD) //dead patients get way less additional heal from the damage they have.
		brute_healed += round((target.getBruteLoss() * (brute_multiplier * 0.2)),0.1)
		burn_healed += round((target.getFireLoss() * (burn_multiplier * 0.2)),0.1)
		dead_patient = TRUE
	else
		brute_healed += round((target.getBruteLoss() * brute_multiplier),0.1)
		burn_healed += round((target.getFireLoss() * burn_multiplier),0.1)
		dead_patient = FALSE
	if(!get_location_accessible(target, target_zone))
		brute_healed *= 0.55
		burn_healed *= 0.55
		user_msg += " as best as you can while [target.p_they()] [target.p_have()] clothing on"
		target_msg += " as best as [user.p_they()] can while [target.p_they()] [target.p_have()] clothing on"
	target.heal_bodypart_damage(brute_healed,burn_healed)

	user_msg += get_progress(user, target, brute_healed, burn_healed)

	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && ishuman(user) && !dead_patient) //Morbid folk don't care about tending the dead as much as tending the living
		var/mob/living/carbon/human/morbid_weirdo = user
		morbid_weirdo.add_mood_event("morbid_tend_wounds", /datum/mood_event/morbid_tend_wounds)

	display_results(
		user,
		target,
		span_notice("[user_msg]."),
		span_notice("[target_msg]."),
		span_notice("[target_msg]."),
	)
	if(istype(surgery, /datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		the_surgery.antispam = TRUE
	return ..()

/datum/surgery_step/heal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You screwed up!"),
		span_warning("[user] screws up!"),
		span_notice("[user] fixes some of [target]'s wounds."),
		target_detailed = TRUE,
	)
	var/brute_dealt = brutehealing * 0.8
	var/burn_dealt = burnhealing * 0.8
	brute_dealt += round((target.getBruteLoss() * (brute_multiplier * 0.5)),0.1)
	burn_dealt += round((target.getFireLoss() * (burn_multiplier * 0.5)),0.1)
	target.take_bodypart_damage(brute_dealt, burn_dealt, wound_bonus=CANT_WOUND)
	return FALSE

/***************************BRUTE***************************/
/datum/surgery/healing/brute
	name = "Tend Wounds (Bruises)"

/datum/surgery/healing/brute/basic
	name = "Tend Wounds (Bruises, Basic)"
	replaced_by = /datum/surgery/healing/brute/upgraded
	healing_step_type = /datum/surgery_step/heal/brute/basic
	desc = "A surgical procedure that provides basic treatment for a patient's brute traumas. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/brute/upgraded
	name = "Tend Wounds (Bruises, Adv.)"
	replaced_by = /datum/surgery/healing/brute/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's brute traumas. Heals more when the patient is severely injured."

/datum/surgery/healing/brute/upgraded/femto
	name = "Tend Wounds (Bruises, Exp.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's brute traumas. Heals considerably more when the patient is severely injured."

/********************BRUTE STEPS********************/
/datum/surgery_step/heal/brute/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!brute_healed)
		return

	var/estimated_remaining_steps = target.getBruteLoss() / brute_healed
	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		progress_text = ". Remaining brute: <font color='#ff3333'>[target.getBruteLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", stitching up the last few scrapes"
			if(3 to 6)
				progress_text = ", counting down the last few bruises left to treat"
			if(6 to 9)
				progress_text = ", continuing to plug away at [target.p_their()] extensive rupturing"
			if(9 to 12)
				progress_text = ", steadying yourself for the long surgery ahead"
			if(12 to 15)
				progress_text = ", though [target.p_they()] still look[target.p_s()] more like ground beef than a person"
			if(15 to INFINITY)
				progress_text = ", though you feel like you're barely making a dent in treating [target.p_their()] pulped body"

	return progress_text

/datum/surgery_step/heal/brute/basic
	name = "tend bruises (hemostat)"
	brutehealing = 5
	brute_multiplier = 0.07

/datum/surgery_step/heal/brute/upgraded
	brutehealing = 5
	brute_multiplier = 0.1

/datum/surgery_step/heal/brute/upgraded/femto
	brutehealing = 5
	brute_multiplier = 0.2

/***************************BURN***************************/
/datum/surgery/healing/burn
	name = "Tend Wounds (Burn)"

/datum/surgery/healing/burn/basic
	name = "Tend Wounds (Burn, Basic)"
	replaced_by = /datum/surgery/healing/burn/upgraded
	healing_step_type = /datum/surgery_step/heal/burn/basic
	desc = "A surgical procedure that provides basic treatment for a patient's burns. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/burn/upgraded
	name = "Tend Wounds (Burn, Adv.)"
	replaced_by = /datum/surgery/healing/burn/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns. Heals more when the patient is severely injured."

/datum/surgery/healing/burn/upgraded/femto
	name = "Tend Wounds (Burn, Exp.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns. Heals considerably more when the patient is severely injured."

/********************BURN STEPS********************/
/datum/surgery_step/heal/burn/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!burn_healed)
		return
	var/estimated_remaining_steps = target.getFireLoss() / burn_healed
	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		progress_text = ". Remaining burn: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", finishing up the last few singe marks"
			if(3 to 6)
				progress_text = ", counting down the last few blisters left to treat"
			if(6 to 9)
				progress_text = ", continuing to plug away at [target.p_their()] thorough roasting"
			if(9 to 12)
				progress_text = ", steadying yourself for the long surgery ahead"
			if(12 to 15)
				progress_text = ", though [target.p_they()] still look[target.p_s()] more like burnt steak than a person"
			if(15 to INFINITY)
				progress_text = ", though you feel like you're barely making a dent in treating [target.p_their()] charred body"

	return progress_text

/datum/surgery_step/heal/burn/basic
	name = "tend burn wounds (hemostat)"
	burnhealing = 5
	burn_multiplier = 0.07

/datum/surgery_step/heal/burn/upgraded
	burnhealing = 5
	burn_multiplier = 0.1

/datum/surgery_step/heal/burn/upgraded/femto
	burnhealing = 5
	burn_multiplier = 0.2

/***************************COMBO***************************/
/datum/surgery/healing/combo


/datum/surgery/healing/combo
	name = "Tend Wounds (Mixture, Basic)"
	replaced_by = /datum/surgery/healing/combo/upgraded
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/combo
	desc = "A surgical procedure that provides basic treatment for a patient's burns and brute traumas. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/combo/upgraded
	name = "Tend Wounds (Mixture, Adv.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	healing_step_type = /datum/surgery_step/heal/combo/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns and brute traumas. Heals more when the patient is severely injured."


/datum/surgery/healing/combo/upgraded/femto //no real reason to type it like this except consistency, don't worry you're not missing anything
	name = "Tend Wounds (Mixture, Exp.)"
	replaced_by = null
	healing_step_type = /datum/surgery_step/heal/combo/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns and brute traumas. Heals considerably more when the patient is severely injured."

/********************COMBO STEPS********************/
/datum/surgery_step/heal/combo/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	var/estimated_remaining_steps = 0
	if(brute_healed > 0)
		estimated_remaining_steps = max(0, (target.getBruteLoss() / brute_healed))
	if(burn_healed > 0)
		estimated_remaining_steps = max(estimated_remaining_steps, (target.getFireLoss() / burn_healed)) // whichever is higher between brute or burn steps

	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		if(target.getBruteLoss())
			progress_text = ". Remaining brute: <font color='#ff3333'>[target.getBruteLoss()]</font>"
		if(target.getFireLoss())
			progress_text += ". Remaining burn: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", finishing up the last few signs of damage"
			if(3 to 6)
				progress_text = ", counting down the last few patches of trauma"
			if(6 to 9)
				progress_text = ", continuing to plug away at [target.p_their()] extensive injuries"
			if(9 to 12)
				progress_text = ", steadying yourself for the long surgery ahead"
			if(12 to 15)
				progress_text = ", though [target.p_they()] still look[target.p_s()] more like smooshed baby food than a person"
			if(15 to INFINITY)
				progress_text = ", though you feel like you're barely making a dent in treating [target.p_their()] broken body"

	return progress_text

/datum/surgery_step/heal/combo
	name = "tend physical wounds (hemostat)"
	brutehealing = 3
	burnhealing = 3
	brute_multiplier = 0.07
	burn_multiplier = 0.07
	time = 10

/datum/surgery_step/heal/combo/upgraded
	brutehealing = 3
	burnhealing = 3
	brute_multiplier = 0.1
	burn_multiplier = 0.1

/datum/surgery_step/heal/combo/upgraded/femto
	brutehealing = 1
	burnhealing = 1
	brute_multiplier = 0.4
	burn_multiplier = 0.4

/datum/surgery_step/heal/combo/upgraded/femto/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You screwed up!"),
		span_warning("[user] screws up!"),
		span_notice("[user] fixes some of [target]'s wounds."),
		target_detailed = TRUE,
	)
	target.take_bodypart_damage(5,5)
