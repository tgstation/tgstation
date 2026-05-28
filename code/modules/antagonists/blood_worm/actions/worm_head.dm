/datum/action/cooldown/mob_cooldown/blood_worm/worm_head

	name = "Worm head"
	desc = "Extend or retract worm head on your host"

	button_icon_state = "worm_head"

	cooldown_time = 5 SECONDS

	cooldown_time = 0 SECONDS

	unset_after_click = FALSE

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/Activate(atom/target) // logic on click
	var/mob/living/basic/blood_worm/worm = src.target
	var/mob/living/carbon/human/host = worm.host

	// if (worm.host?.is_mouth_covered())
	// 	if (feedback)
	// 		owner.balloon_alert(owner, "mouth is covered!")
	// 	return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/extend_head(host)
	// todo: its must be possible to grant head via the action button
	host:grant_bloodworm_head(host)

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/retract_head(host)

	host:remove_bloodworm_head(host)
