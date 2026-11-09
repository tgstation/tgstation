// Any procs that work with blood consumption go here.
// There are quite a few of them, and some of them are lengthy.

/mob/living/basic/blood_worm/proc/consume_blood(blood_amount, synth_content = 0, should_heal = TRUE)
	if (blood_amount <= 0)
		return

	synth_content = clamp(synth_content, 0, 1)

	var/was_synth_capped = consumed_synth_blood >= maximum_synth_blood
	var/was_ready_to_mature = get_consumed_blood() >= cocoon_action?.total_blood_required

	var/added_normal_blood = blood_amount * (1 - synth_content)
	var/added_synth_blood = blood_amount * synth_content * synth_blood_efficiency
	var/added_total_blood = added_normal_blood + added_synth_blood

	consumed_synth_blood = min(consumed_synth_blood + added_synth_blood, maximum_synth_blood)
	consumed_normal_blood += added_normal_blood

	if (!was_synth_capped && consumed_synth_blood >= maximum_synth_blood)
		balloon_alert_self("synthetic cap reached!")

	if (!was_ready_to_mature && get_consumed_blood() >= cocoon_action?.total_blood_required)
		balloon_alert_self("ready to mature!")

	if (should_heal)
		// Synthetic blood works just fine for healing.
		adjust_worm_health(blood_amount * BLOOD_WORM_BLOOD_TO_HEALTH)

	// This is intentionally passing the synth blood amount without any regard for the synth blood growth cap.
	SEND_SIGNAL(src, COMSIG_BLOOD_WORM_CONSUMED_BLOOD, added_normal_blood, added_synth_blood, added_total_blood)

/mob/living/basic/blood_worm/proc/reset_consumed_blood()
	consumed_normal_blood = 0
	consumed_synth_blood = 0

/mob/living/basic/blood_worm/proc/get_consumed_blood()
	return consumed_normal_blood + consumed_synth_blood
