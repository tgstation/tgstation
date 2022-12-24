#define TERROR_DARKNESS_AMOUNT 10
#define TERROR_HUG_AMOUNT 60

#define TERROR_FEAR_THRESHOLD 140
#define TERROR_PANIC_THRESHOLD 300
#define TERROR_HEART_ATTACK_THRESHOLD 400

#define TERROR_DARKNESS_MAX 350

/datum/status_effect/terrified
	id = "terrified"

	remove_on_fullheal = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/terrified
	///A value that represents how much "terror" the victim has built up. Higher amounts cause more averse effects.
	var/terror_buildup = 100

/datum/status_effect/terrified/on_apply()
	RegisterSignal(owner, COMSIG_CARBON_HELPED, PROC_REF(comfort_owner))
	owner.add_fov_trait(type, FOV_270_DEGREES)
	to_chat(owner, span_alert("The darkness closes in around you, shadows dance around the corners of your vision... Did something just move behind you?"))
	return TRUE

/datum/status_effect/terrified/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_HELPED)
	owner.remove_fov_trait(type, FOV_270_DEGREES)

/datum/status_effect/terrified/tick(delta_time, times_fired)
	. = ..()

	check_surrounding_light()

	if(terror_buildup <= 0)
		qdel(src)

	if(terror_buildup >= TERROR_FEAR_THRESHOLD) //if above a certain amount, force caps a-la hulk
		priority_announce("aieee")

	if(terror_buildup >= TERROR_PANIC_THRESHOLD) //If you reach this amount of buildup in an engagement, you should probably run.
		owner.playsound_local(get_turf(owner), 'sound/health/slowbeat.ogg', 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		owner.adjust_blurriness(10)
		owner.apply_status_effect(/datum/status_effect/dizziness, 20)
		if(prob(20)) //We don't want to spam chat
			to_chat(owner, span_alert("Your heart lurches in your chest. You can't take much more of this!"))

	if(terror_buildup >= TERROR_HEART_ATTACK_THRESHOLD) //You should only be able to reach this by casting on an already maximum-terrified target
		owner.visible_message(span_warning("[owner] clutches their chest for a moment, then collapses to the floor.") ,span_alert("The shadows begin to creep up from the corners of your vision, and then there is nothing."), span_hear("You hear something heavy collide with the ground."))
		owner.ForceContractDisease(/datum/disease/heart_failure)
		owner.Unconscious(15 SECONDS)
		qdel(src)

/datum/status_effect/terrified/get_examine_text()
	. = ..()

	if(terror_buildup >= TERROR_HEART_ATTACK_THRESHOLD)
		return span_boldwarning("[owner.p_they(TRUE)] [owner.p_are()] siezing up, about to collapse in fear!")

	if(terror_buildup >= TERROR_PANIC_THRESHOLD)
		return span_boldwarning("[owner] is visibly trembling and twitching. It looks like [owner.p_theyre(TRUE)] freaking out!")

	if(terror_buildup >= TERROR_FEAR_THRESHOLD)
		return span_warning("[owner] looks very worried about something. Are [owner.p_they(TRUE)] alright?")

	return span_notice("[owner] looks rather anxious. [owner.p_they(TRUE)] could probably use a hug...")

/// If we get a hug from a friend, we calm down! If we get a hug from a nightmare, we FREAK OUT
/datum/status_effect/terrified/proc/comfort_owner(mob/living/source) //this doesnt work right now
	SIGNAL_HANDLER

	if(is_species(source, /datum/species/shadow/nightmare))
		terror_buildup += TERROR_HUG_AMOUNT
		owner.balloon_alert("get away!")
		return

	terror_buildup -= TERROR_HUG_AMOUNT
	if(prob(20))
		owner.balloon_alert_to_viewers("*phew*", "deep breaths...")

/**
 * Checks the surroundings of our victim and modifies terror buildup based on the amount of light nearby
 *
 * Checks the surrounded tiles for light amount. If the user has more light nearby, their terror is reduced.
 * Otherwise, their terror buildup will increase until it reaches TERROR_DARKNESS_MAX
 */

/datum/status_effect/terrified/proc/check_surrounding_light()
	var/lit_tiles = 0
	var/unlit_tiles = 0

	for(var/turf/turf_to_check in view(1, get_turf(owner)))
		var/light_amount = turf_to_check.get_lumcount()
		if(light_amount > 0.2)
			lit_tiles++
		else
			unlit_tiles++

	if(lit_tiles > unlit_tiles && terror_buildup < TERROR_DARKNESS_MAX)
		terror_buildup += TERROR_DARKNESS_AMOUNT
	else
		terror_buildup -= TERROR_DARKNESS_AMOUNT

/// The status effect for the terror status effect
/atom/movable/screen/alert/status_effect/terrified
	name = "Terrified!"
	desc = "You feel a supernatural darkness settle in around you, overwhelming you with panic!"
	icon_state = "terrified"

#undef TERROR_DARKNESS_AMOUNT
#undef TERROR_HUG_AMOUNT
