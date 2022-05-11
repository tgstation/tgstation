

GLOBAL_LIST_INIT(hallucination_list, generate_hallucination_weighted_list())

/proc/generate_hallucination_weighted_list()
	var/list/list = list(
		/datum/hallucination/chat = 100,
		/datum/hallucination/message = 60,
		/datum/hallucination/fake_sound/normal/random = 50,
		/datum/hallucination/random_battle = 20,
		/datum/hallucination/fake_health_doll = 12,
		/datum/hallucination/random_fake_alert = 12,
		/datum/hallucination/bolts = 7,
		/datum/hallucination/fake_flood = 7,
		/datum/hallucination/random_nearby_fake_item = 7,
		/datum/hallucination/stray_bullet = 7,
		/datum/hallucination/hazard/anomaly = 5,
		/datum/hallucination/hazard/chasm = 5,
		/datum/hallucination/hazard/lava = 5,
		/datum/hallucination/body/husk = 4,
		/datum/hallucination/screwy_hud/crit = 4,
		/datum/hallucination/screwy_hud/dead = 4,
		/datum/hallucination/screwy_hud/healthy = 4,
		/datum/hallucination/fire = 3,
		/datum/hallucination/body/husk/sideways = 2,
		/datum/hallucination/station_message/meteors = 2,
		/datum/hallucination/station_message/supermatter_delam = 2,
		/datum/hallucination/body/alien = 1,
		/datum/hallucination/death = 1,
		/datum/hallucination/fake_item/baton = 1,
		/datum/hallucination/fake_item/c4 = 1,
		/datum/hallucination/fake_item/emag = 1,
		/datum/hallucination/fake_item/esword = 1,
		/datum/hallucination/fake_item/flashbang = 1,
		/datum/hallucination/fake_item/revolver = 1,
		/datum/hallucination/fake_sound/weird/creepy = 1,
		/datum/hallucination/fake_sound/weird/game_over = 1,
		/datum/hallucination/fake_sound/weird/hallelujah = 1,
		/datum/hallucination/fake_sound/weird/highlander = 1,
		/datum/hallucination/fake_sound/weird/hyperspace = 1,
		/datum/hallucination/fake_sound/weird/laugher = 1,
		/datum/hallucination/fake_sound/weird/phone = 1,
		/datum/hallucination/fake_sound/weird/tesloose = 1,
		/datum/hallucination/oh_yeah = 1,
		/datum/hallucination/shock = 1,
		/datum/hallucination/station_message/blob_alert = 1,
		/datum/hallucination/station_message/malf_ai = 1,
		/datum/hallucination/station_message/shuttle_dock = 1,
	)

	return list

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
