/datum/action/cooldown/mob_cooldown/blood_worm/worm_head

	name = "Worm head"
	desc = "Extend or retract worm head on your host"

	button_icon_state = "worm_head"

	cooldown_time = 5 SECONDS

/datum/action/cooldown/mob_cooldown/blood_worm/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

	// if (worm.host?.is_mouth_covered())
	// 	if (feedback)
	// 		owner.balloon_alert(owner, "mouth is covered!")
	// 	return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/proc/extend_head(host)
	// todo: its must be possible to grant head via the action button
	owner.grant_bloodworm_head(host)

/datum/action/cooldown/mob_cooldown/blood_worm/proc/retract_head(host)

	owner.remove_bloodworm_head(host)
