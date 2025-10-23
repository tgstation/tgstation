/datum/surgery_operation/basic/tend_wounds
	name = "tend wounds"
	desc = "Perform superficial wound care on a patient's bruises and burns."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 0.65,
		TOOL_WIRECUTTER = 0.60,
		/obj/item/pen = 0.55,
	)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_biotype = MOB_ORGANIC|MOB_HUMANOID

	var/list/cached_healing_options

/datum/surgery_operation/basic/tend_wounds/get_radial_options(mob/living/patient, mob/living/surgeon, obj/item/tool)
	var/list/options = list()
	if(!LAZYACCESS(cached_healing_options, BRUTE))
		var/datum/radial_menu_choice/brute_healing = new()
		option.image = image(/obj/item/storage/medkit/brute)
		option.name = "tend bruises"
		option.info = "Heal a patient's superficial bruises and cuts."
		LAZYSET(cached_organ_manipulation_options, BRUTE, option)

	if(!LAZYACCESS(cached_healing_options, BURN))
		var/datum/radial_menu_choice/burn_healing = new()
		option.image = image(/obj/item/storage/medkit/burn)
		option.name = "tend burns"
		option.info = "Heal a patient's superficial burns."
		LAZYSET(cached_healing_options, BURN, option)

	if(!LAZYACCESS(cached_healing_options, ARMOR_ALL))
		var/datum/radial_menu_choice/all_healing = new()
		option.image = image(/obj/item/storage/medkit/advanced)
		option.name = "tend all wounds"
		option.info = "Heal a patient's superficial bruises, cuts, and burns."
		LAZYSET(cached_healing_options, ARMOR_ALL, option)

	options[LAZYACCESS(cached_healing_options, BRUTE)] = list("action" = "heal", "brute_heal" = 5, "brute_multiplier" = 0.07)
	options[LAZYACCESS(cached_healing_options, BURN)] = list("action" = "heal", "burn_heal" = 5, "burn_multiplier" = 0.07)
	options[LAZYACCESS(cached_healing_options, ARMOR_ALL)] = list("action" = "heal", "brute_heal" = 5, "burn_heal" = 5, "brute_multiplier" = 0.07, "burn_multiplier" = 0.07)
	return options

/datum/surgery_operation/basic/tend_wounds/can_loop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	if(!.)
		return FALSE
	if(operation_args["brute_heal"] > 0 && patient.getBruteLoss() <= 0)
		return FALSE
	if(operation_args["burn_heal"] > 0 && patient.getBurnLoss() <= 0)
		return FALSE
	return TRUE

/datum/surgery_operation/basic/tend_wounds/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/woundtype
	var/heal_brute = operation_args["brute_heal"] > 0
	var/heal_burn = operation_args["burn_heal"] > 0
	if(heal_brute && heal_burn)
		woundtype = "wounds"
	else if(heal_brute)
		woundtype = "bruises"
	else //why are you trying to 0,0...?
		woundtype = "burns"
	display_results(
		user,
		target,
		span_notice("You attempt to patch some of [target]'s [woundtype]."),
		span_notice("[user] attempts to patch some of [target]'s [woundtype]."),
		span_notice("[user] attempts to patch some of [target]'s [woundtype]."),
	)
	display_pain(target, "Your [woundtype] sting like hell!")

/// Returns a string letting the surgeon know roughly how much longer the surgery is estimated to take at the going rate
/datum/surgery_operation/basic/tend_wounds/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	return

/datum/surgery_operation/basic/tend_wounds/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/user_msg = "You succeed in fixing some of [patient]'s wounds" //no period, add initial space to "addons"
	var/target_msg = "[user] fixes some of [patient]'s wounds" //see above

	var/brute_healed = operation_args["brute_heal"]
	var/burn_healed = operation_args["burn_heal"]

	var/dead_multiplier = patient.stat == DEAD ? 0.2 : 1.0
	var/accessibility_modifier = 1.0
	if(!get_location_accessible(patient, BODY_ZONE_CHEST))
		accessibility_modifier = 0.55
		user_msg += " as best as you can while [target.p_they()] [target.p_have()] clothing on"
		target_msg += " as best as [user.p_they()] can while [target.p_they()] [target.p_have()] clothing on"

	var/brute_multiplier = operation_args["brute_multiplier"] * dead_multiplier * accessibility_modifier
	var/burn_multiplier = operation_args["burn_multiplier"] * dead_multiplier * accessibility_modifier

	brute_healed += round(patient.getBruteLoss() * brute_multiplier, DAMAGE_PRECISION)
	burn_healed += round(patient.getFireLoss() * burn_multiplier, DAMAGE_PRECISION)

	patient.heal_bodypart_damage(brute_healed, burn_healed)

	user_msg += get_progress(user, target, brute_healed, burn_healed)

	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && patient.stat != DEAD) //Morbid folk don't care about tending the dead as much as tending the living
		user.add_mood_event("morbid_tend_wounds", /datum/mood_event/morbid_tend_wounds)

	display_results(
		user,
		target,
		span_notice("[user_msg]."),
		span_notice("[target_msg]."),
		span_notice("[target_msg]."),
	)

/datum/surgery_operation/basic/tend_wounds/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args, total_penalty_modifier)
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

	brute_dealt += round(target.getBruteLoss() * brute_multiplier, 0.1)
	burn_dealt += round(target.getFireLoss() * burn_multiplier, 0.1)

	target.take_bodypart_damage(brute_dealt, burn_dealt, wound_bonus = CANT_WOUND)
