#define RAISE_FIRE_COUNT 3
#define RAISE_FIRE_TIME 3

/datum/hallucination/fire
	var/active = TRUE
	var/stage = 0
	var/image/fire_overlay

	var/next_action = 0
	var/times_to_lower_stamina
	var/fire_clearing = FALSE
	var/increasing_stages = TRUE
	var/time_spent = 0

/datum/hallucination/fire/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()

/datum/hallucination/fire/start()
	hallucinator.set_fire_stacks(max(hallucinator.fire_stacks, 0.1)) //Placebo flammability
	fire_overlay = image('icons/mob/onfire.dmi', hallucinator, "human_burning", ABOVE_MOB_LAYER)
	hallucinator.client?.images |= fire_overlay
	to_chat(hallucinator, span_userdanger("You're set on fire!"))
	hallucinator.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire, override = TRUE)
	times_to_lower_stamina = rand(5, 10)
	addtimer(CALLBACK(src, .proc/start_expanding), 2 SECONDS)
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

/datum/hallucination/fire/process(delta_time)
	if(QDELETED(src))
		return

	if(hallucinator.fire_stacks <= 0)
		clear_fire()

	time_spent += delta_time

	if(fire_clearing)
		next_action -= delta_time
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
		next_action -= delta_time
		if(next_action < 0)
			hallucinator.adjustStaminaLoss(15)
			next_action += 2
			times_to_lower_stamina -= 1

	else
		clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
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
