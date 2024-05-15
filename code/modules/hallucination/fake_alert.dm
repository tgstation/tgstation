/// Fake alert hallucination. Causes a fake alert to be thrown to the hallucinator.
/datum/hallucination/fake_alert
	abstract_hallucination_parent = /datum/hallucination/fake_alert
	random_hallucination_weight = 1

	var/del_timer_id
	/// The duration of the alert being thrown.
	var/duration
	/// The category of the fake alert
	var/alert_category
	/// The type of the fake alert. Can be a list, if you want it to draw from multiple types (randomly).
	var/alert_type
	/// Optional, the severity of the alert.
	var/optional_severity

/datum/hallucination/fake_alert/New(mob/living/hallucinator, duration = 15 SECONDS)
	src.duration = duration
	return ..()

/datum/hallucination/fake_alert/Destroy()
	if(del_timer_id)
		deltimer(del_timer_id)
	if(!QDELETED(hallucinator))
		hallucinator.clear_alert(alert_category, clear_override = TRUE)
	return ..()

/datum/hallucination/fake_alert/start()
	var/picked_type = islist(alert_type) ? pick(alert_type) : alert_type

	feedback_details += "Alert type: [alert_category], Actual type: [alert_type]"

	hallucinator.throw_alert(
		category = alert_category,
		type = picked_type,
		severity = optional_severity,
		override = TRUE,
	)

	del_timer_id = QDEL_IN_STOPPABLE(src, duration)
	return TRUE

/datum/hallucination/fake_alert/need_oxygen
	alert_category = ALERT_NOT_ENOUGH_OXYGEN
	alert_type = /atom/movable/screen/alert/not_enough_oxy

/datum/hallucination/fake_alert/need_plasma
	alert_category = ALERT_NOT_ENOUGH_PLASMA
	alert_type = /atom/movable/screen/alert/not_enough_plas

/datum/hallucination/fake_alert/need_co2
	alert_category = ALERT_NOT_ENOUGH_CO2
	alert_type = /atom/movable/screen/alert/not_enough_co2

/datum/hallucination/fake_alert/bad_oxygen
	alert_category = ALERT_TOO_MUCH_OXYGEN
	alert_type = /atom/movable/screen/alert/too_much_oxy

/datum/hallucination/fake_alert/bad_plasma
	alert_category = ALERT_TOO_MUCH_PLASMA
	alert_type = /atom/movable/screen/alert/too_much_plas

/datum/hallucination/fake_alert/bad_co2
	alert_category = ALERT_TOO_MUCH_CO2
	alert_type = /atom/movable/screen/alert/too_much_co2

/datum/hallucination/fake_alert/gravity
	alert_category = ALERT_GRAVITY
	alert_type = /atom/movable/screen/alert/weightless

/datum/hallucination/fake_alert/fire
	alert_category = ALERT_FIRE
	alert_type = /atom/movable/screen/alert/fire

/datum/hallucination/fake_alert/hot
	alert_category = ALERT_TEMPERATURE
	alert_type = /atom/movable/screen/alert/hot
	optional_severity = 3

/datum/hallucination/fake_alert/cold
	alert_category = ALERT_TEMPERATURE
	alert_type = /atom/movable/screen/alert/cold
	optional_severity = 3

/datum/hallucination/fake_alert/pressure
	alert_category = ALERT_PRESSURE
	alert_type = list(/atom/movable/screen/alert/highpressure, /atom/movable/screen/alert/lowpressure)
	optional_severity = 2

/datum/hallucination/fake_alert/law
	alert_category = ALERT_NEW_LAW
	alert_type = /atom/movable/screen/alert/newlaw

/datum/hallucination/fake_alert/locked
	alert_category = ALERT_LOCKED
	alert_type = /atom/movable/screen/alert/locked

/datum/hallucination/fake_alert/hacked
	alert_category = ALERT_HACKED
	alert_type = /atom/movable/screen/alert/hacked

/datum/hallucination/fake_alert/need_charge
	alert_category = ALERT_CHARGE
	alert_type = /atom/movable/screen/alert/emptycell
