/// Used to track the state of surgeries on a mob generically rather than a bodypart
/datum/status_effect/basic_surgery_state
	id = "surgery_state"

	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH

	var/surgery_state = NONE

/datum/status_effect/basic_surgery_state/on_creation(mob/living/new_owner, added_state = NONE, removed_state = NONE)
	. = ..()
	surgery_state = (added_state & ~removed_state)

/datum/status_effect/basic_surgery_state/on_apply()
	. = ..()
	if(owner.has_limbs)
		stack_trace("Applied a basic surgery state to [owner], which has limbs. This status effect is intended for limbless mobs.")

/datum/status_effect/basic_surgery_state/refresh(mob/living/old_owner, added_state = NONE, removed_state = NONE)
	surgery_state |= added_state
	surgery_state &= ~removed_state
	if(!surgery_state)
		qdel(src)
