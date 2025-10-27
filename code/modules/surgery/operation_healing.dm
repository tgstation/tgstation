/// Allow brute healing operation
#define BRUTE_SURGERY (1<<0)
/// Allow burn healing operation
#define BURN_SURGERY (1<<1)
/// Allow combo healing operation
#define COMBO_SURGERY (1<<2)

/datum/surgery_operation/basic/tend_wounds
	name = "tend wounds"
	desc = "Perform superficial wound care on a patient's bruises and burns."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 1.5,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/pen = 1.8,
	)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_biotype = MOB_ORGANIC|MOB_HUMANOID
	replaced_by = /datum/surgery_operation/basic/tend_wounds/upgraded
	/// Radial slice datums for every healing option we can provide
	VAR_PRIVATE/list/cached_healing_options
	/// Bitflag of which healing types this operation can perform
	var/can_heal = BRUTE_SURGERY | BURN_SURGERY
	/// Flat amount of healing done per operation
	var/healing_amount = 5
	/// The amount of damage healed scales based on how much damage the patient has times this multiplier
	var/healing_multiplier = 0.07

/datum/surgery_operation/basic/tend_wounds/show_as_next_step(mob/living/potential_patient, body_zone)
	return ..() && is_available(potential_patient)

/datum/surgery_operation/basic/tend_wounds/is_available(mob/living/patient, mob/living/surgeon, obj/item/tool)
	// We allow tend wounds with even just cut skin
	if(!has_any_surgery_state(patient, SURGERY_SKIN_OPEN|SURGERY_SKIN_CUT))
		return FALSE
	// Nothing to treat
	if(patient.getBruteLoss() <= 0 && patient.getFireLoss() <= 0)
		return FALSE
	return TRUE

/datum/surgery_operation/basic/tend_wounds/get_radial_options(mob/living/patient, mob/living/surgeon, obj/item/tool)
	var/list/options = list()

	if(can_heal & COMBO_SURGERY)
		var/datum/radial_menu_choice/all_healing = LAZYACCESS(cached_healing_options, "[COMBO_SURGERY]")
		if(!all_healing)
			all_healing = new()
			all_healing.image = image(/obj/item/storage/medkit/advanced)
			all_healing.name = "tend bruises and burns"
			all_healing.info = "Heal a patient's superficial bruises, cuts, and burns."
			LAZYSET(cached_healing_options, "[COMBO_SURGERY]", all_healing)

		options[all_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"brute_heal" = healing_amount,
			"burn_heal" = healing_amount,
			"brute_multiplier" = healing_multiplier,
			"burn_multiplier" = healing_multiplier,
		)

	if((can_heal & BRUTE_SURGERY) && patient.getBruteLoss() > 0)
		var/datum/radial_menu_choice/brute_healing = LAZYACCESS(cached_healing_options, "[BRUTE_SURGERY]")
		if(!brute_healing)
			brute_healing = new()
			brute_healing.image = image(/obj/item/storage/medkit/brute)
			brute_healing.name = "tend bruises"
			brute_healing.info = "Heal a patient's superficial bruises and cuts."
			LAZYSET(cached_healing_options, "[BRUTE_SURGERY]", brute_healing)

		options[brute_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"brute_heal" = healing_amount,
			"brute_multiplier" = healing_multiplier,
		)

	if((can_heal & BURN_SURGERY) && patient.getFireLoss() > 0)
		var/datum/radial_menu_choice/burn_healing = LAZYACCESS(cached_healing_options, "[BURN_SURGERY]")
		if(burn_healing)
			burn_healing = new()
			burn_healing.image = image(/obj/item/storage/medkit/fire)
			burn_healing.name = "tend burns"
			burn_healing.info = "Heal a patient's superficial burns."
			LAZYSET(cached_healing_options, "[BURN_SURGERY]", burn_healing)

		options[burn_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"burn_heal" = healing_amount,
			"burn_multiplier" = healing_multiplier,
		)

	return options

/datum/surgery_operation/basic/tend_wounds/can_loop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	if(!.)
		return FALSE
	if(operation_args["brute_heal"] > 0 && patient.getBruteLoss() <= 0)
		return FALSE
	if(operation_args["burn_heal"] > 0 && patient.getFireLoss() <= 0)
		return FALSE
	return TRUE

/datum/surgery_operation/basic/tend_wounds/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/woundtype
	var/brute_heal = operation_args["brute_heal"] > 0
	var/burn_heal = operation_args["burn_heal"] > 0
	if(brute_heal && burn_heal)
		woundtype = "wounds"
	else if(brute_heal)
		woundtype = "bruises"
	else //why are you trying to 0,0...?
		woundtype = "burns"
	display_results(
		surgeon,
		patient,
		span_notice("You attempt to patch some of [patient]'s [woundtype]."),
		span_notice("[surgeon] attempts to patch some of [patient]'s [woundtype]."),
		span_notice("[surgeon] attempts to patch some of [patient]'s [woundtype]."),
	)
	display_pain(patient, "Your [woundtype] sting like hell!")

#define CONDITIONAL_DAMAGE_MESSAGE(brute, burn, combo_msg, brute_msg, burn_msg) "[(brute > 0 && burn > 0) ? combo_msg : (brute > 0 ? brute_msg : burn_msg)]"

/// Returns a string letting the surgeon know roughly how much longer the surgery is estimated to take at the going rate
/datum/surgery_operation/basic/tend_wounds/proc/get_progress(mob/living/surgeon, mob/living/patient, brute_healed, burn_healed)
	var/estimated_remaining_steps = 0
	if(brute_healed > 0)
		estimated_remaining_steps = max(0, (patient.getBruteLoss() / brute_healed))
	if(burn_healed > 0)
		estimated_remaining_steps = max(estimated_remaining_steps, (patient.getFireLoss() / burn_healed)) // whichever is higher between brute or burn steps

	var/progress_text

	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		if(brute_healed > 0 && patient.getBruteLoss() > 0)
			progress_text += ". Remaining brute: <font color='#ff3333'>[patient.getBruteLoss()]</font>"
		if(burn_healed > 0 && patient.getFireLoss() > 0)
			progress_text += ". Remaining burn: <font color='#ff9933'>[patient.getFireLoss()]</font>"
		return progress_text

	switch(estimated_remaining_steps)
		if(-INFINITY to 1)
			return
		if(1 to 3)
			progress_text += ", finishing up the last few [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "signs of damage", "scrapes", "burn marks")]"
		if(3 to 6)
			progress_text += ", counting down the last few [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "patches of trauma", "bruises", "blisters")] left to treat"
		if(6 to 9)
			progress_text += ", continuing to plug away at [patient.p_their()] extensive [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "injuries", "rupturing", "roasting")]"
		if(9 to 12)
			progress_text += ", steadying yourself for the long surgery ahead"
		if(12 to 15)
			progress_text += ", though [patient.p_they()] still look[patient.p_s()] more like [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "smooshed baby food", "ground beef", "burnt steak")] than a person"
		if(15 to INFINITY)
			progress_text += ", though you feel like you're barely making a dent in treating [patient.p_their()] [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "broken", "pulped", "charred")] body"

	return progress_text

#undef CONDITIONAL_DAMAGE_MESSAGE

/datum/surgery_operation/basic/tend_wounds/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/user_msg = "You succeed in fixing some of [patient]'s wounds" //no period, add initial space to "addons"
	var/target_msg = "[surgeon] fixes some of [patient]'s wounds" //see above

	var/brute_healed = operation_args["brute_heal"]
	var/burn_healed = operation_args["burn_heal"]

	var/dead_multiplier = patient.stat == DEAD ? 0.2 : 1.0
	var/accessibility_modifier = 1.0
	if(!patient.is_location_accessible(BODY_ZONE_CHEST))
		accessibility_modifier = 0.55
		user_msg += " as best as you can while [patient.p_they()] [patient.p_have()] clothing on"
		target_msg += " as best as [surgeon.p_they()] can while [patient.p_they()] [patient.p_have()] clothing on"

	var/brute_multiplier = operation_args["brute_multiplier"] * dead_multiplier * accessibility_modifier
	var/burn_multiplier = operation_args["burn_multiplier"] * dead_multiplier * accessibility_modifier

	brute_healed += round(patient.getBruteLoss() * brute_multiplier, DAMAGE_PRECISION)
	burn_healed += round(patient.getFireLoss() * burn_multiplier, DAMAGE_PRECISION)

	patient.heal_bodypart_damage(brute_healed, burn_healed)

	user_msg += get_progress(surgeon, patient, brute_healed, burn_healed)

	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID) && patient.stat != DEAD) //Morbid folk don't care about tending the dead as much as tending the living
		surgeon.add_mood_event("morbid_tend_wounds", /datum/mood_event/morbid_tend_wounds)

	display_results(
		surgeon,
		patient,
		span_notice("[user_msg]."),
		span_notice("[target_msg]."),
		span_notice("[target_msg]."),
	)

/datum/surgery_operation/basic/tend_wounds/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("You screwed up!"),
		span_warning("[surgeon] screws up!"),
		span_notice("[surgeon] fixes some of [patient]'s wounds."),
		target_detailed = TRUE,
	)
	var/brute_dealt = operation_args["brute_heal"] * 0.8
	var/burn_dealt = operation_args["burn_heal"] * 0.8
	var/brute_multiplier = operation_args["brute_multiplier"] * 0.5
	var/burn_multiplier = operation_args["burn_multiplier"] * 0.5

	brute_dealt += round(patient.getBruteLoss() * brute_multiplier, 0.1)
	burn_dealt += round(patient.getFireLoss() * burn_multiplier, 0.1)

	patient.take_bodypart_damage(brute_dealt, burn_dealt, wound_bonus = CANT_WOUND)

/datum/surgery_operation/basic/tend_wounds/upgraded
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/master
	healing_multiplier = 0.1

/datum/surgery_operation/basic/tend_wounds/master
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/master
	healing_multiplier = 0.2

/datum/surgery_operation/basic/tend_wounds/combo
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded
	can_heal = COMBO_SURGERY
	healing_amount = 3
	time = 1 SECONDS

/datum/surgery_operation/basic/tend_wounds/combo/upgraded
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/master
	healing_multiplier = 0.1

/datum/surgery_operation/basic/tend_wounds/combo/master
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	healing_amount = 1
	healing_multiplier = 0.4
