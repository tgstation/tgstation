/// Amount of terror passively generated (or removed) on every tick based on lighting.
#define DARKNESS_TERROR_AMOUNT 10
/// How much terror a random panic attack will give the victim.
#define PANIC_ATTACK_TERROR_AMOUNT 35
/// Amount of terror actively removed (or generated) upon being hugged.
#define HUG_TERROR_AMOUNT 60
/// Amount of terror caused by subsequent casting of the Terrify spell.
#define STACK_TERROR_AMOUNT 135

/// The soft cap on how much passively generated terror you can have. Takes about 30 seconds to reach without the victim being actively terrorized.
#define DARKNESS_TERROR_CAP 400

/// The terror_buildup threshold for minor fear effects to occur.
#define TERROR_FEAR_THRESHOLD 140
/// The terror_buildup threshold for the more serious effects. Takes about 20 seconds of darkness buildup to reach.
#define TERROR_PANIC_THRESHOLD 300
/// Terror buildup will cause a heart attack and knock them out, removing the status effect.
#define TERROR_HEART_ATTACK_THRESHOLD 600

/datum/status_effect/terrified
	id = "terrified"
	status_type = STATUS_EFFECT_REFRESH
	remove_on_fullheal = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/terrified
	///A value that represents how much "terror" the victim has built up. Higher amounts cause more averse effects.
	var/terror_buildup = 100

/datum/status_effect/terrified/refresh(effect, ...) //Don't call parent, just add to the current amount
	freak_out(STACK_TERROR_AMOUNT)

/datum/status_effect/terrified/on_apply()
	RegisterSignal(owner, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(comfort_owner))
	owner.emote("scream")
	to_chat(owner, span_alert("The darkness closes in around you, shadows dance around the corners of your vision... It feels like something is watching you!"))
	return TRUE

/datum/status_effect/terrified/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_HELPED)
	owner.remove_fov_trait(id, FOV_270_DEGREES)

/datum/status_effect/terrified/tick(delta_time, times_fired)
	if(check_surrounding_darkness())
		if(terror_buildup < DARKNESS_TERROR_CAP)
			terror_buildup += DARKNESS_TERROR_AMOUNT
	else
		terror_buildup -= DARKNESS_TERROR_AMOUNT

	if(terror_buildup <= 0) //If we've completely calmed down, we remove the status effect.
		qdel(src)
		return

	if(terror_buildup >= TERROR_FEAR_THRESHOLD) //The onset, minor effects of terror buildup
		owner.adjust_dizzy_up_to(10 SECONDS * delta_time, 10 SECONDS)
		owner.adjust_stutter_up_to(10 SECONDS * delta_time, 10 SECONDS)
		owner.adjust_jitter_up_to(10 SECONDS * delta_time, 10 SECONDS)

	if(terror_buildup >= TERROR_PANIC_THRESHOLD) //If you reach this amount of buildup in an engagement, it's time to start looking for a way out.
		owner.playsound_local(get_turf(owner), 'sound/health/slowbeat.ogg', 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		owner.add_fov_trait(id, FOV_270_DEGREES) //Terror induced tunnel vision
		owner.adjust_eye_blur_up_to(10 SECONDS * delta_time, 10 SECONDS)
		if(prob(5)) //We have a little panic attack. Consider it GENTLE ENCOURAGEMENT to start running away.
			freak_out(PANIC_ATTACK_TERROR_AMOUNT)
			owner.visible_message(
				span_warning("[owner] drops to the floor for a moment, clutching their chest."),
				span_alert("Your heart lurches in your chest. You can't take much more of this!"),
				span_hear("You hear a grunt."),
			)
	else
		owner.remove_fov_trait(id, FOV_270_DEGREES)

	if(terror_buildup >= TERROR_HEART_ATTACK_THRESHOLD) //You should only be able to reach this by actively terrorizing someone
		owner.visible_message(
			span_warning("[owner] clutches [owner.p_their()] chest for a moment, then collapses to the floor."),
			span_alert("The shadows begin to creep up from the corners of your vision, and then there is nothing..."),
			span_hear("You hear something heavy collide with the ground."),
		)
		var/datum/disease/heart_failure/heart_attack = new(src)
		heart_attack.stage_prob = 2 //Advances twice as fast
		owner.ForceContractDisease(heart_attack)
		owner.Unconscious(20 SECONDS)
		qdel(src) //Victim passes out from fear, calming them down and permenantly damaging their heart.

/datum/status_effect/terrified/get_examine_text()
	if(terror_buildup > DARKNESS_TERROR_CAP) //If we're approaching a heart attack
		return span_boldwarning("[owner.p_they(TRUE)] [owner.p_are()] seizing up, about to collapse in fear!")

	if(terror_buildup >= TERROR_PANIC_THRESHOLD)
		return span_boldwarning("[owner] is visibly trembling and twitching. It looks like [owner.p_theyre()] freaking out!")

	if(terror_buildup >= TERROR_FEAR_THRESHOLD)
		return span_warning("[owner] looks very worried about something. [owner.p_are(TRUE)] [owner.p_they()] alright?")

	return span_notice("[owner] looks rather anxious. [owner.p_they(TRUE)] could probably use a hug...")

/// If we get a hug from a friend, we calm down! If we get a hug from a nightmare, we FREAK OUT.
/datum/status_effect/terrified/proc/comfort_owner(datum/source, mob/living/hugger)
	SIGNAL_HANDLER

	if(isnightmare(hugger)) //hey wait a minute, that's not a comforting, friendly hug!
		if(check_surrounding_darkness())
			addtimer(CALLBACK(src, PROC_REF(freak_out), HUG_TERROR_AMOUNT))
			owner.visible_message(
				span_warning("[owner] recoils in fear as [hugger] waves [hugger.p_their()] arms and shrieks at [owner.p_them()]!"),
				span_boldwarning("The shadows lash out at you, and you drop to the ground in fear!"),
				span_hear("You hear someone shriek in fear. How embarassing!"),
				)
			return COMPONENT_BLOCK_MISC_HELP

	terror_buildup -= HUG_TERROR_AMOUNT
	owner.visible_message(
		span_notice("[owner] seems to relax as [hugger] gives [owner.p_them()] a comforting hug."),
		span_nicegreen("You feel yourself calm down as [hugger] gives you a reassuring hug."),
		span_hear("You hear shuffling and a sigh of relief."),
	)

/**
 * Checks the surroundings of our victim and returns TRUE if the user is surrounded by enough darkness
 *
 * Checks the surrounded tiles for light amount. If the user has more light nearby, return true.
 * Otherwise, return false
 */

/datum/status_effect/terrified/proc/check_surrounding_darkness()
	var/lit_tiles = 0
	var/unlit_tiles = 0

	for(var/turf/open/turf_to_check in range(1, owner.loc))
		var/light_amount = turf_to_check.get_lumcount()
		if(light_amount > 0.2)
			lit_tiles++
		else
			unlit_tiles++

	return lit_tiles < unlit_tiles

/**
 * Adds to the victim's terror buildup, makes them scream, and knocks them over for a moment.
 *
 * Makes the victm scream and adds the passed amount to their buildup.
 * Knocks over the victim for a brief moment.
 *
 * * amount - how much terror buildup this freakout will cause
 */

/datum/status_effect/terrified/proc/freak_out(amount)
	terror_buildup += amount
	owner.Knockdown(0.5 SECONDS)
	if(prob(50))
		owner.emote("scream")

/// The status effect popup for the terror status effect
/atom/movable/screen/alert/status_effect/terrified
	name = "Terrified!"
	desc = "You feel a supernatural darkness settle in around you, overwhelming you with panic! Get into the light!"
	icon_state = "terrified"

#undef DARKNESS_TERROR_AMOUNT
#undef PANIC_ATTACK_TERROR_AMOUNT
#undef HUG_TERROR_AMOUNT
#undef STACK_TERROR_AMOUNT
#undef DARKNESS_TERROR_CAP
#undef TERROR_FEAR_THRESHOLD
#undef TERROR_PANIC_THRESHOLD
#undef TERROR_HEART_ATTACK_THRESHOLD
