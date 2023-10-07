/datum/action/cooldown/slasher/regenerate
	name = "Regenerate"
	desc = "Quickly regenerate your being, restoring most if not all lost health, repairing wounds, and removing all stuns."

	button_icon_state = "regenerate"

	cooldown_time = 75 SECONDS


/datum/action/cooldown/slasher/regenerate/Activate(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/mob_target = target
		mob_target.set_timed_status_effect(5 SECONDS, /datum/status_effect/bloody_heal) // should heal most damage over 5 seconds
