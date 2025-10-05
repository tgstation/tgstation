/datum/surgery/coronary_bypass
	name = "Coronary Bypass"
	organ_to_manipulate = ORGAN_SLOT_HEART
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise_heart,
		/datum/surgery_step/coronary_bypass,
		/datum/surgery_step/close,
	)

/datum/surgery/coronary_bypass/mechanic
	name = "Engine Diagnostic"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/incise_heart/mechanic,
		/datum/surgery_step/coronary_bypass/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/coronary_bypass/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/heart/target_heart = target.get_organ_slot(ORGAN_SLOT_HEART)
	if(isnull(target_heart) || target_heart.damage < 60 || target_heart.operated)
		return FALSE
	return ..()


//an incision but with greater bleed, and a 90% base success chance
/datum/surgery_step/incise_heart
	name = "incise heart (scalpel)"
	implements = list(
		TOOL_SCALPEL = 90,
		/obj/item/melee/energy/sword = 45,
		/obj/item/knife = 45,
		/obj/item/shard = 25)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/incise_heart/mechanic
	name = "access engine internals (scalpel or crowbar)"
	implements = list(
		TOOL_SCALPEL = 95,
		TOOL_CROWBAR = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/incise_heart/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to make an incision in [target]'s heart..."),
		span_notice("[user] begins to make an incision in [target]'s heart."),
		span_notice("[user] begins to make an incision in [target]'s heart."),
	)
	display_pain(target, "You feel a horrendous pain in your heart, it's almost enough to make you pass out!")

/datum/surgery_step/incise_heart/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		if (target_human.can_bleed())
			var/blood_name = target_human.get_bloodtype()?.get_blood_name() || "Blood"
			display_results(
				user,
				target,
				span_notice("[blood_name] pools around the incision in [target_human]'s heart."),
				span_notice("[blood_name] pools around the incision in [target_human]'s heart."),
				span_notice("[blood_name] pools around the incision in [target_human]'s heart."),
			)
			var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
			target_bodypart.adjustBleedStacks(10)
			target_human.adjustBruteLoss(10)
	return ..()

/datum/surgery_step/incise_heart/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		var/blood_name = LOWER_TEXT(target_human.get_bloodtype()?.get_blood_name()) || "blood"
		display_results(
			user,
			target,
			span_warning("You screw up, cutting too deeply into the heart!"),
			span_warning("[user] screws up, causing [blood_name] to spurt out of [target_human]'s chest!"),
			span_warning("[user] screws up, causing [blood_name] to spurt out of [target_human]'s chest!"),
		)
		var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
		target_bodypart.adjustBleedStacks(10)
		target_human.adjustOrganLoss(ORGAN_SLOT_HEART, 10)
		target_human.adjustBruteLoss(10)

//grafts a coronary bypass onto the individual's heart, success chance is 90% base again
/datum/surgery_step/coronary_bypass
	name = "graft coronary bypass (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 90,
		TOOL_WIRECUTTER = 35,
		/obj/item/stack/package_wrap = 15,
		/obj/item/stack/cable_coil = 5)
	time = 9 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_step/coronary_bypass/mechanic
	name = "perform maintenance (hemostat or wrench)"
	implements = list(
		TOOL_HEMOSTAT = 90,
		TOOL_WRENCH = 90,
		TOOL_WIRECUTTER = 35,
		/obj/item/stack/package_wrap = 15,
		/obj/item/stack/cable_coil = 5)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/coronary_bypass/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to graft a bypass onto [target]'s heart..."),
		span_notice("[user] begins to graft something onto [target]'s heart!"),
		span_notice("[user] begins to graft something onto [target]'s heart!"),
	)
	display_pain(target, "The pain in your chest is unbearable! You can barely take it anymore!")

/datum/surgery_step/coronary_bypass/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	target.setOrganLoss(ORGAN_SLOT_HEART, 60)
	var/obj/item/organ/heart/target_heart = target.get_organ_slot(ORGAN_SLOT_HEART)
	if(target_heart) //slightly worrying if we lost our heart mid-operation, but that's life
		target_heart.operated = TRUE
		if(target_heart.organ_flags & ORGAN_EMP) //If our organ is failing due to an EMP, fix that
			target_heart.organ_flags &= ~ORGAN_EMP
	display_results(
		user,
		target,
		span_notice("You successfully graft a bypass onto [target]'s heart."),
		span_notice("[user] finishes grafting something onto [target]'s heart."),
		span_notice("[user] finishes grafting something onto [target]'s heart."),
	)
	display_pain(target, "The pain in your chest throbs, but your heart feels better than ever!")
	return ..()

/datum/surgery_step/coronary_bypass/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(
			user,
			target,
			span_warning("You screw up in attaching the graft, and it tears off, tearing part of the heart!"),
			span_warning("[user] screws up, causing blood to spurt out of [target_human]'s chest profusely!"),
			span_warning("[user] screws up, causing blood to spurt out of [target_human]'s chest profusely!"),
		)
		display_pain(target, "Your chest burns; you feel like you're going insane!")
		target_human.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
		var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
		target_bodypart.adjustBleedStacks(30)
	return FALSE
