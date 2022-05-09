

GLOBAL_LIST_INIT(hallucination_list, list(
	/datum/hallucination/chat = 100,
	/datum/hallucination/message = 60,
	/datum/hallucination/sounds = 50,
	/datum/hallucination/battle = 20,
	/datum/hallucination/dangerflash = 15,
	/datum/hallucination/hudscrew = 12,
	/datum/hallucination/fake_health_doll = 12,
	/datum/hallucination/fake_alert = 12,
	/datum/hallucination/weird_sounds = 8,
	/datum/hallucination/stationmessage = 7,
	/datum/hallucination/fake_flood = 7,
	/datum/hallucination/stray_bullet = 7,
	/datum/hallucination/bolts = 7,
	/datum/hallucination/items_other = 7,
	/datum/hallucination/husks = 7,
	/datum/hallucination/items = 4,
	/datum/hallucination/fire = 3,
	/datum/hallucination/self_delusion = 2,
	/datum/hallucination/delusion = 2,
	/datum/hallucination/shock = 1,
	/datum/hallucination/death = 1,
	/datum/hallucination/oh_yeah = 1,
))


/datum/status_effect/hallucination
	id = "hallucination"
	alert_type = /atom/movable/screen/alert/status_effect/high
	// We start by ticking every 2 seconds until any hallucination triggers.
	tick_interval = 2 SECONDS
	// Whenever a hallucination triggers, our tick interval expands to some time in the below range.
	/// The lower range of when the next hallucination will trigger after one occurs.
	var/lower_tick_interval = 10 SECONDS
	/// The upper range of when the next hallucination will trigger after one occurs.
	var/upper_tick_interval = 60 SECONDS

/datum/status_effect/hallucination/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/hallucination/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/remove_hallucinations)
	return TRUE

/datum/status_effect/hallucination/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)

/datum/status_effect/hallucination/proc/remove_hallucinations(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/hallucination/tick(delta_time, times_fired)
	var/datum/hallucination/picked_hallucination = pick_weight(GLOB.hallucination_list)
	owner.cause_hallucination(picked_hallucination, "[id] status effect")

	tick_interval = world.time + rand(lower_tick_interval, upper_tick_interval)
