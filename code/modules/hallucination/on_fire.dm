#define RAISE_FIRE_COUNT 3
#define RAISE_FIRE_TIME 3

/datum/hallucination/fire
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// Are we currently burning our mob?
	var/active = TRUE
	/// What stare of fire are we in?
	var/stage = 0

	/// What icon file to use for our hallucinator
	var/fire_icon = 'icons/mob/effects/onfire.dmi'
	/// What icon state to use for our hallucinator
	var/fire_icon_state = "human_big_fire"
	/// Our fire overlay we generate
	var/image/fire_overlay

	/// When should we do our next action of the hallucination?
	var/next_action = 0
	/// How may times do we apply stamina damage to our mob?
	var/times_to_lower_stamina
	/// Are we currently fake-clearing our hallucinated fire?
	var/fire_clearing = FALSE
	/// Are the stages going up or down?
	var/increasing_stages = TRUE
	/// How long have we spent on fire?
	var/time_spent = 0

	var/fake_firestacks = 0

/datum/hallucination/fire/proc/make_overlay()
	var/mutable_appearance/real_overlay = hallucinator.get_fire_overlay(fake_firestacks)
	if(!real_overlay)
		return null
	if(real_overlay.icon_state == fire_overlay?.icon_state)
		return fire_overlay

	var/image/new_overlay = image(real_overlay.icon, hallucinator, real_overlay.icon_state, real_overlay.layer)
	new_overlay.appearance_flags = real_overlay.appearance_flags
	return new_overlay

/datum/hallucination/fire/start()
	fake_firestacks = rand(5, 15)
	fire_overlay = make_overlay()
	if(!fire_overlay)
		return FALSE

	hallucinator.client?.images |= fire_overlay
	to_chat(hallucinator, span_userdanger("You're set on fire!"))
	var/atom/movable/screen/alert/fire/fake/alert = hallucinator.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire/fake, override = TRUE)
	alert.hallucination_weakref = WEAKREF(src)
	times_to_lower_stamina = rand(5, 10)
	addtimer(CALLBACK(src, PROC_REF(start_expanding)), 2 SECONDS)
	return TRUE

/datum/hallucination/fire/Destroy()
	hallucinator.clear_alert(ALERT_FIRE, clear_override = TRUE)
	hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
	if(fire_overlay)
		hallucinator.client?.images -= fire_overlay
		fire_overlay = null

	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/hallucination/fire/proc/start_expanding()
	if(QDELETED(src))
		return

	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/fire/process(seconds_per_tick)
	if(QDELETED(src))
		return

	fake_firestacks -= (0.25 * seconds_per_tick)
	if(fake_firestacks <= 0)
		clear_fire()
	else
		var/new_overlay = make_overlay()
		if(new_overlay && new_overlay != fire_overlay)
			hallucinator.client?.images -= fire_overlay
			fire_overlay = new_overlay
			hallucinator.client?.images |= fire_overlay

	time_spent += seconds_per_tick

	if(fire_clearing)
		next_action -= seconds_per_tick
		if(next_action < 0)
			stage -= 1
			update_temp()
			next_action += 3

	else if(increasing_stages)
		var/new_stage = min(round(time_spent / RAISE_FIRE_TIME), RAISE_FIRE_COUNT)
		if(stage != new_stage)
			stage = new_stage
			update_temp()

			if(stage == RAISE_FIRE_COUNT)
				increasing_stages = FALSE

	else if(times_to_lower_stamina)
		next_action -= seconds_per_tick
		if(next_action < 0)
			hallucinator.adjustStaminaLoss(15)
			next_action += 2
			times_to_lower_stamina -= 1

	else
		clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
		if(!active)
			qdel(src)
	else
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
		hallucinator.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(!active)
		return

	active = FALSE
	hallucinator.clear_alert(ALERT_FIRE, clear_override = TRUE)
	hallucinator.client?.images -= fire_overlay
	fire_overlay = null
	fire_clearing = TRUE
	next_action = 0

#undef RAISE_FIRE_COUNT
#undef RAISE_FIRE_TIME

/// This alert is thrown when hallucinating fire
/atom/movable/screen/alert/fire/fake
	/// We need to track the original hallucination so we can pass it to the status effect
	var/datum/weakref/hallucination_weakref

/atom/movable/screen/alert/fire/fake/handle_stop_drop_roll(mob/living/roller)
	return !!roller.apply_status_effect(/datum/status_effect/stop_drop_roll/hallucinating, hallucination_weakref)
