/datum/surgery/advanced/bioware
	name = "Enhancement surgery"
	/// What status effect is gained when the surgery is successful?
	/// Used to check against other bioware types to prevent stacking.
	var/status_effect_gained = /datum/status_effect/bioware

/datum/surgery/advanced/bioware/can_start(mob/user, mob/living/carbon/human/target)
	if(!..())
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.has_status_effect(status_effect_gained))
		return FALSE
	return TRUE

/datum/surgery_step/apply_bioware
	accept_hand = TRUE
	time = 12.5 SECONDS
	surgery_effects_mood = TRUE

/datum/surgery_step/apply_bioware/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/advanced/bioware/surgery, default_display_results)
	. = ..()
	if(!.)
		return
	if(!istype(surgery))
		return

	target.apply_status_effect(surgery.status_effect_gained)
	if(target.ckey)
		SSblackbox.record_feedback("tally", "bioware", 1, surgery.type)
