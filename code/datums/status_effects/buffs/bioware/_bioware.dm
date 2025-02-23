/**
 * ## Bioware status effect
 *
 * Simple holder status effects that grants the owner mob basic buffs
 */
/datum/status_effect/bioware
	id = "bioware"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK

/datum/status_effect/bioware/on_apply()
	if(!ishuman(owner))
		return FALSE

	bioware_gained()
	return TRUE

/datum/status_effect/bioware/on_remove()
	bioware_lost()

/// Called when applying to the mob.
/datum/status_effect/bioware/proc/bioware_gained()
	return

/// Called when removing from the mob.
/datum/status_effect/bioware/proc/bioware_lost()
	return
