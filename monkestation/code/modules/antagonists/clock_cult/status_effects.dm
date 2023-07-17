/datum/status_effect/interdiction
	id = "interdicted"
	duration = 2.5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1
	alert_type = /atom/movable/screen/alert/status_effect/interdiction
	/// If we kicked the owner out of running mode
	var/running_toggled = FALSE

/datum/status_effect/interdiction/tick()
	if(owner.m_intent != MOVE_INTENT_WALK)
		owner.set_move_intent(MOVE_INTENT_WALK)
		owner.adjust_confusion_up_to(1 SECONDS, 1 SECONDS)
		running_toggled = TRUE
		to_chat(owner, span_warning("You know you shouldn't be running here."))

	owner.add_movespeed_modifier(/datum/movespeed_modifier/clock_interdiction)

/datum/status_effect/interdiction/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/clock_interdiction)

	if(running_toggled && owner.m_intent == MOVE_INTENT_WALK)
		owner.set_move_intent(MOVE_INTENT_RUN)

/atom/movable/screen/alert/status_effect/interdiction
	name = "Interdicted"
	desc = "I don't think I am meant to go this way."
	icon = 'monkestation/icons/hud/screen_alert.dmi'
	icon_state = "belligerent"

/datum/movespeed_modifier/clock_interdiction
	multiplicative_slowdown = 1.5
