/datum/surgery/revival
	name = "Revival"
	desc = "An experimental surgical procedure which involves reconstruction and reactivation of the patient's brain even long after death. \
		The body must still be able to sustain life."
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living)
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_MORBID_CURIOSITY
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/revive,
		/datum/surgery_step/close,
	)

/datum/surgery/revival/mechanic
	name = "Full System Reboot"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/revive,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/revival/can_start(mob/user, mob/living/target)
	if(!..())
		return FALSE
	if(target.stat != DEAD)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_SUICIDED) || HAS_TRAIT(target, TRAIT_HUSK) || HAS_TRAIT(target, TRAIT_DEFIB_BLACKLISTED))
		return FALSE
	if(!is_valid_target(target))
		return FALSE
	return TRUE

/// Extra checks which can be overridden
/datum/surgery/revival/proc/is_valid_target(mob/living/patient)
	if (iscarbon(patient))
		return FALSE
	if (!(patient.mob_biotypes & (MOB_ORGANIC|MOB_HUMANOID)))
		return FALSE
	return TRUE

/datum/surgery/revival/mechanic/is_valid_target(mob/living/patient)
	if (iscarbon(patient))
		return FALSE
	if (!(patient.mob_biotypes & (MOB_ROBOTIC|MOB_HUMANOID)))
		return FALSE
	return TRUE

/datum/surgery_step/revive
	name = "shock brain (defibrillator)"
	implements = list(
		/obj/item/shockpaddles = 100,
		/obj/item/melee/touch_attack/shock = 100,
		/obj/item/melee/baton/security = 75,
		/obj/item/gun/energy = 60)
	repeatable = TRUE
	time = 5 SECONDS
	success_sound = 'sound/effects/magic/lightningbolt.ogg'
	failure_sound = 'sound/effects/magic/lightningbolt.ogg'

/datum/surgery_step/revive/tool_check(mob/user, obj/item/tool)
	. = TRUE
	if(istype(tool, /obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = tool
		if((paddles.req_defib && !paddles.defib.powered) || !HAS_TRAIT(paddles, TRAIT_WIELDED) || paddles.cooldown || paddles.busy)
			to_chat(user, span_warning("You need to wield both paddles, and [paddles.defib] must be powered!"))
			return FALSE
	if(istype(tool, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/baton = tool
		if(!baton.active)
			to_chat(user, span_warning("[baton] needs to be active!"))
			return FALSE
	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/egun = tool
		if(egun.chambered && istype(egun.chambered, /obj/item/ammo_casing/energy/electrode))
			return TRUE
		else
			to_chat(user, span_warning("You need an electrode for this!"))
			return FALSE

/datum/surgery_step/revive/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You prepare to give [target]'s brain the spark of life with [tool]."),
		span_notice("[user] prepares to shock [target]'s brain with [tool]."),
		span_notice("[user] prepares to shock [target]'s brain with [tool]."),
	)
	target.notify_revival("Someone is trying to zap your brain.", source = target)

/datum/surgery_step/revive/play_preop_sound(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/shockpaddles))
		playsound(tool, 'sound/machines/defib/defib_charge.ogg', 75, 0)
	else
		..()

/datum/surgery_step/revive/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(
		user,
		target,
		span_notice("You successfully shock [target]'s brain with [tool]..."),
		span_notice("[user] send a powerful shock to [target]'s brain with [tool]..."),
		span_notice("[user] send a powerful shock to [target]'s brain with [tool]..."),
	)
	target.grab_ghost()
	target.adjustOxyLoss(-50)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.set_heartattack(FALSE)
	if(target.revive())
		on_revived(user, target)
		return TRUE

	target.visible_message(span_warning("...[target.p_they()] convulse[target.p_s()], then lie[target.p_s()] still."))
	return FALSE

/// Called when you have been successfully raised from the dead
/datum/surgery_step/revive/proc/on_revived(mob/surgeon, mob/living/patient)
	patient.visible_message(span_notice("...[patient] wakes up, alive and aware!"))
	patient.emote("gasp")
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID) && ishuman(surgeon)) // Contrary to their typical hatred of resurrection, it wouldn't be very thematic if morbid people didn't love playing god
		var/mob/living/carbon/human/morbid_weirdo = surgeon
		morbid_weirdo.add_mood_event("morbid_revival_success", /datum/mood_event/morbid_revival_success)

/datum/surgery_step/revive/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You shock [target]'s brain with [tool], but [target.p_they()] doesn't react."),
		span_notice("[user] send a powerful shock to [target]'s brain with [tool], but [target.p_they()] doesn't react."),
		span_notice("[user] send a powerful shock to [target]'s brain with [tool], but [target.p_they()] doesn't react."),
	)
	return FALSE

/// Additional revival effects if the target has a brain
/datum/surgery/revival/carbon
	possible_locs = list(BODY_ZONE_HEAD)
	target_mobtypes = list(/mob/living/carbon)
	surgery_flags = parent_type::surgery_flags | SURGERY_REQUIRE_LIMB

/datum/surgery/revival/carbon/is_valid_target(mob/living/carbon/patient)
	var/obj/item/organ/brain/target_brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	return !isnull(target_brain)

/datum/surgery_step/revive/carbon

/datum/surgery_step/revive/carbon/on_revived(mob/surgeon, mob/living/patient)
	. = ..()
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 199) // MAD SCIENCE

/datum/surgery_step/revive/carbon/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 180)
