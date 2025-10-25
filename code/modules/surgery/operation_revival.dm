/datum/surgery_operation/limb/revival
	name = "shock brain"
	desc = "Use a defibrillator to shock a patient's brain back to life."
	implements = list(
		/obj/item/shockpaddles = 1,
		/obj/item/melee/touch_attack/shock = 1,
		/obj/item/melee/baton/security = 0.75,
		/obj/item/gun/energy = 0.6,
	)
	operation_flags = OPERATION_MORBID
	time = 5 SECONDS
	preop_sound = list(
		/obj/item/shockpaddles = 'sound/machines/defib/defib_charge.ogg',
		/obj/item = null,
	)
	success_sound = 'sound/machines/defib/defib_zap.ogg'

/datum/surgery_operation/limb/revival/state_check(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_ORGANS_CUT)
		return FALSE
	if(limb.surgery_bone_state < SURGERY_BONE_SAWED)
		return FALSE
	if(limb.owner.stat != DEAD)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_SUICIDED) || HAS_TRAIT(limb.owner, TRAIT_HUSK) || HAS_TRAIT(limb.owner, TRAIT_DEFIB_BLACKLISTED))
		return FALSE
	var/obj/item/organ/brain/brain = locate() in limb
	if(isnull(brain))
		return FALSE
	if(!brain_check(brain))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/revival/brain_check(obj/item/organ/brain/brain)
	return IS_ORGANIC_ORGAN(brain)

/datum/surgery_operation/limb/revival/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = tool
		if((paddles.req_defib && !paddles.defib.powered) || !HAS_TRAIT(paddles, TRAIT_WIELDED) || paddles.cooldown || paddles.busy)
			return FALSE

	if(istype(tool, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/baton = tool
		return baton.active

	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/egun = tool
		return istype(egun.chambered, /obj/item/ammo_casing/energy/electrode)

	return TRUE

/datum/surgery_operation/limb/revival/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You prepare to give [limb.owner]'s brain the spark of life with [tool]."),
		span_notice("[surgeon] prepares to give [limb.owner]'s brain the spark of life with [tool]."),
		span_notice("[surgeon] prepares to give [limb.owner]'s brain the spark of life."),
	)
	limb.owner.notify_revival("Someone is trying to zap your brain.", source = limb.owner)

/datum/surgery_operation/limb/revival/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully shock [limb.owner]'s brain with [tool]..."),
		span_notice("[surgeon] sends a powerful shock to [limb.owner]'s brain with [tool]..."),
		span_notice("[surgeon] sends a powerful shock to [limb.owner]'s brain..."),
	)
	limb.owner.grab_ghost()
	limb.owner.adjustOxyLoss(-50)
	limb.owner.set_heartattack(FALSE)
	if(!limb.owner.revive())
		on_no_revive(surgeon, limb.owner)
		return

	on_revived(surgeon, limb.owner)

/// Called when you have been successfully raised from the dead
/datum/surgery_operation/limb/revival/proc/on_revived(mob/living/surgeon, mob/living/patient)
	patient.visible_message(span_notice("...[patient] wakes up, alive and aware!"))
	patient.emote("gasp")
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID)) // Contrary to their typical hatred of resurrection, it wouldn't be very thematic if morbid people didn't love playing god
		surgeon.add_mood_event("morbid_revival_success", /datum/mood_event/morbid_revival_success)
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 180)

/// Called when revival fails
/datum/surgery_operation/limb/revival/proc/on_no_revive(mob/living/surgeon, mob/living/patient)
	patient.visible_message(span_warning("...[patient.p_they()] convulse[patient.p_s()], then lie[patient.p_s()] still."))
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 199) // MAD SCIENCE

/datum/surgery_operation/limb/revival/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("You shock [limb.owner]'s brain with [tool], but [limb.owner] don't react."),
		span_warning("[surgeon] shocks [limb.owner]'s brain with [tool], but [limb.owner] don't react."),
		span_warning("[surgeon] shocks [limb.owner]'s brain with [tool], but [limb.owner] don't react."),
	)

/datum/surgery_operation/limb/revival/mechanic
	name = "full system reboot"

/datum/surgery_operation/limb/revival/mechanic/brain_check(obj/item/organ/brain/brain)
	return IS_ROBOTIC_ORGAN(brain)
