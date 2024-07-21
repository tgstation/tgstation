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


/datum/status_effect/bloody_heal
	id = "bloody_heal"
	alert_type = null
	tick_interval = 1 SECONDS
	show_duration = TRUE

/datum/status_effect/bloody_heal/on_creation(mob/living/new_owner, duration = 5 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/bloody_heal/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_CANT_STAMCRIT, "bloody")

/datum/status_effect/bloody_heal/tick(seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.AdjustAllImmobility(-20 * seconds_per_tick)
	human_owner.stamina.adjust(20, TRUE)
	human_owner.adjustBruteLoss(-35)
	human_owner.adjustFireLoss(-20, FALSE)
	human_owner.adjustOxyLoss(-20)
	human_owner.adjustToxLoss(-20)
	human_owner.adjustCloneLoss(-20)
	human_owner.blood_volume = BLOOD_VOLUME_NORMAL

	for(var/i in human_owner.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.on_xadone(4 * REM * seconds_per_tick) // plasmamen use plasma to reform their bones or whatever

/datum/status_effect/bloody_heal/on_remove()
	REMOVE_TRAIT(owner, TRAIT_CANT_STAMCRIT, "bloody")
	. = ..()
