#define DAMAGE_ROUNDING 0.1
#define FAIL_DAMAGE_MULTIPLIER 0.8
#define FINAL_STEP_HEAL_MULTIPLIER 0.55

//Almost copypaste of tend wounds, with some changes
/datum/surgery/robot_healing
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/pry_off_plating,
		/datum/surgery_step/cut_wires,
		/datum/surgery_step/robot_heal,
		/datum/surgery_step/mechanic_close,
	)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	replaced_by = /datum/surgery
	requires_bodypart_type = BODYTYPE_ROBOTIC
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB

	/// The step to use in the 4th surgery step.
	var/healing_step_type
	/// If true, doesn't send the surgery preop message. Set during surgery.
	var/surgery_preop_message_sent = FALSE

/datum/surgery/robot_healing/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(
			/datum/surgery_step/mechanic_open,
			/datum/surgery_step/pry_off_plating,
			/datum/surgery_step/cut_wires,
			healing_step_type,
			/datum/surgery_step/mechanic_close,
		)

/datum/surgery_step/robot_heal
	name = "repair body (crowbar/wirecutters)"
	implements = list(TOOL_CROWBAR = 100, TOOL_WIRECUTTER = 100)
	repeatable = TRUE
	time = 25

	/// If this surgery is healing brute damage. Set during operation steps.
	var/heals_brute = FALSE
	/// If this surgery is healing burn damage. Set during operation steps.
	var/heals_burn = FALSE
	/// How much healing the sugery gives.
	var/brute_heal_amount = 0
	/// How much healing the sugery gives.
	var/burn_heal_amount = 0
	/// Heals an extra point of damage per X missing damage of type (burn damage for burn healing, brute for brute). Smaller number = more healing!
	var/missing_health_bonus = 0

/datum/surgery_step/robot_heal/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_CROWBAR && implement_type == TOOL_WIRECUTTER)
		return FALSE
	return TRUE

/datum/surgery_step/robot_heal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/woundtype
	if(implement_type == TOOL_CROWBAR)
		heals_brute = TRUE
		heals_burn = FALSE
		woundtype = "dents"
		return

	if(implement_type == TOOL_WIRECUTTER)
		heals_brute = FALSE
		heals_burn = TRUE
		woundtype = "wiring"
		return

	if(!istype(surgery, /datum/surgery/robot_healing))
		return

	var/datum/surgery/robot_healing/the_surgery = surgery
	if(the_surgery.surgery_preop_message_sent)
		return

	display_results(
		user,
		target,
		span_notice("You attempt to fix some of [target]'s [woundtype]."),
		span_notice("[user] attempts to fix some of [target]'s [woundtype]."),
		span_notice("[user] attempts to fix some of [target]'s [woundtype]."),
	)

/datum/surgery_step/robot_heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while((heals_brute && target.getBruteLoss() && tool) || (heals_burn && target.getFireLoss() && tool))
			if(!..())
				break

/datum/surgery_step/robot_heal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/self_message = "You succeed in fixing some of [target]'s damage" //no period, add initial space to "addons"
	var/other_message = "[user] fixes some of [target]'s damage" //see above
	var/healed_brute = 0

	if(heals_brute)
		healed_brute = brute_heal_amount
		tool.use_tool(target, user, 0, volume = 50, amount=1)

	var/healed_burn = 0
	if(heals_burn)
		healed_burn = burn_heal_amount
		tool.use_tool(target, user, 0, volume = 50, amount=1)

	if(missing_health_bonus)
		if(target.stat != DEAD)
			healed_brute += round((target.getBruteLoss() / missing_health_bonus), DAMAGE_ROUNDING)
			healed_burn += round((target.getFireLoss() / missing_health_bonus), DAMAGE_ROUNDING)

		else //less healing bonus for the dead since they're expected to have lots of damage to begin with (to make TW into defib not TOO simple)
			healed_brute += round((target.getBruteLoss() / (missing_health_bonus * 5)), DAMAGE_ROUNDING)
			healed_burn += round((target.getFireLoss() / (missing_health_bonus * 5)), DAMAGE_ROUNDING)

	if(!get_location_accessible(target, target_zone))
		healed_brute *= FINAL_STEP_HEAL_MULTIPLIER
		healed_burn *= FINAL_STEP_HEAL_MULTIPLIER
		self_message += " as best as you can while they have clothing on"
		other_message += " as best as they can while [target] has clothing on"

	target.heal_bodypart_damage(healed_brute, healed_burn, 0, BODYTYPE_ROBOTIC)

	self_message += get_progress(user, target, healed_brute, healed_burn)

	display_results(user, target, span_notice("[self_message]."), "[other_message].", "[other_message].")

	if(istype(surgery, /datum/surgery/robot_healing))
		var/datum/surgery/robot_healing/the_surgery = surgery
		the_surgery.surgery_preop_message_sent = TRUE

	return TRUE

/datum/surgery_step/robot_heal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You screwed up!"),
		span_warning("[user] screws up!"),
		span_notice("[user] fixes some of [target]'s damage."),
		TRUE,
	)

	var/brute_damage = 0
	if(heals_brute)
		brute_damage = brute_heal_amount * FAIL_DAMAGE_MULTIPLIER

	var/burn_damage = 0
	if(heals_burn)
		burn_damage = burn_heal_amount * FAIL_DAMAGE_MULTIPLIER

	if(missing_health_bonus)
		brute_damage += round((target.getBruteLoss() / (missing_health_bonus * 2)), DAMAGE_ROUNDING)
		burn_damage += round((target.getFireLoss() / (missing_health_bonus * 2)), DAMAGE_ROUNDING)

	target.take_bodypart_damage(brute_damage, burn_damage)
	return FALSE

/***************************TYPES***************************/
/datum/surgery/robot_healing/basic
	name = "Repair robotic limbs (Basic)"
	desc = "A surgical procedure that provides repairs and maintenance to robotic limbs. Is slightly more efficient when the patient is severely damaged."
	healing_step_type = /datum/surgery_step/robot_heal/basic
	replaced_by = /datum/surgery/robot_healing/upgraded

/datum/surgery/robot_healing/upgraded
	name = "Repair robotic limbs (Adv.)"
	desc = "A surgical procedure that provides highly effective repairs and maintenance to robotic limbs. Is somewhat more efficient when the patient is severely damaged."
	healing_step_type = /datum/surgery_step/robot_heal/upgraded
	replaced_by = /datum/surgery/robot_healing/experimental
	requires_tech = TRUE

/datum/surgery/robot_healing/experimental
	name = "Repair robotic limbs (Exp.)"
	desc = "A surgical procedure that quickly provides highly effective repairs and maintenance to robotic limbs. Is moderately more efficient when the patient is severely damaged."
	healing_step_type = /datum/surgery_step/robot_heal/experimental
	replaced_by = null
	requires_tech = TRUE

/***************************STEPS***************************/

/datum/surgery_step/robot_heal/basic
	brute_heal_amount = 10
	burn_heal_amount = 10
	missing_health_bonus = 15
	time = 2.5 SECONDS

/datum/surgery_step/robot_heal/upgraded
	brute_heal_amount = 12
	burn_heal_amount = 12
	missing_health_bonus = 11
	time = 2.3 SECONDS

/datum/surgery_step/robot_heal/experimental
	brute_heal_amount = 14
	burn_heal_amount = 14
	missing_health_bonus = 8
	time = 2 SECONDS

// Mostly a copypaste of standard tend wounds get_progress(). In order to abstract this, I'd have to rework the hierarchy of surgery upstream, so I'll just do this. Pain.
/**
 * Args:
 * * mob/user: The user performing this surgery.
 * * mob/living/carbon/target: The target of the surgery.
 * * brute_healed: The amount of brute we just healed.
 * * burn_healed: The amount of burn we just healed.
 *
 * Returns:
 * * A string containing either an estimation of how much longer the surgery will take, or exact numbers of the remaining damages, depending on if a health analyzer
 * is held or not.
 */
/datum/surgery_step/robot_heal/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
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
				progress_text = ", continuing to plug away at [target.p_their()] extensive damages"
			if(9 to 12)
				progress_text = ", steadying yourself for the long surgery ahead"
			if(12 to 15)
				progress_text = ", though [target.p_they()] still look[target.p_s()] heavily battered"
			if(15 to INFINITY)
				progress_text = ", though you feel like you're barely making a dent in treating [target.p_their()] broken body"

	return progress_text

#undef DAMAGE_ROUNDING
#undef FAIL_DAMAGE_MULTIPLIER
#undef FINAL_STEP_HEAL_MULTIPLIER
