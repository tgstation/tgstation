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
	SEND_SIGNAL(owner, COMSIG_LIVING_UPDATING_SURGERY_STATE, NONE, surgery_state, added_state)

/datum/status_effect/basic_surgery_state/on_apply()
	. = ..()
	if(owner.has_limbs)
		stack_trace("Применил базовое хирургическое состояние к [owner.declent_ru(GENITIVE)], у которого есть конечности. Этот эффект предназначен для существ без конечностей.")

/datum/status_effect/basic_surgery_state/get_examine_text()
	if(HAS_SURGERY_STATE(surgery_state, SURGERY_SKIN_OPEN))
		return "Кожа у [owner.declent_ru(GENITIVE)] открыта [HAS_SURGERY_STATE(surgery_state, SURGERY_BONE_SAWED) ? " и кости распилены и открыты" : ""]."
	// other states are not yet supported
	stack_trace("Система хирургических операций зафиксировала недопустимое состояние(я): [jointext(bitfield_to_list(surgery_state, SURGERY_STATE_READABLE), ", ")]")
	return null

/datum/status_effect/basic_surgery_state/refresh(mob/living/old_owner, added_state = NONE, removed_state = NONE)
	var/old_state = surgery_state
	surgery_state |= added_state
	surgery_state &= ~removed_state
	SEND_SIGNAL(owner, COMSIG_LIVING_UPDATING_SURGERY_STATE, old_state, surgery_state, added_state | removed_state)
	if(!surgery_state)
		qdel(src)
