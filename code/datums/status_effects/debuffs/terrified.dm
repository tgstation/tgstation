#define DARKNESS_TERROR_AMOUNT 10 //Amount of terror passively generated (or removed) on every tick based on lighting.
#define PANIC_ATTACK_TERROR_AMOUNT 35 //How much terror a random panic attack will give the victim
#define HUG_TERROR_AMOUNT 60 //Amount of terror actively removed (or generated) upon being hugged.

#define DARKNESS_TERROR_CAP 400 //The soft cap on how much passively generated terror you can have. Takes 30 seconds to reach without the victim being actively terrorized.

#define TERROR_FEAR_THRESHOLD 140 //The terror_buildup threshold for minor fear effects to occur.
#define TERROR_PANIC_THRESHOLD 300 //The terror_buildup threshold for the more serious effects. Takes about 20 seconds of darkness buildup to reach
#define TERROR_HEART_ATTACK_THRESHOLD 600 //If you actively terrorize someone already at the darkness threshold, you can cause a heart attack and knock them out.

/datum/status_effect/terrified
	id = "terrified"

	remove_on_fullheal = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/terrified
	///A value that represents how much "terror" the victim has built up. Higher amounts cause more averse effects.
	var/terror_buildup = 100

/datum/status_effect/terrified/on_apply()
	RegisterSignal(owner, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(comfort_owner))
	owner.add_fov_trait(type, FOV_270_DEGREES) //Terror induced tunnel vision
	owner.emote("scream")
	to_chat(owner, span_alert("The darkness closes in around you, shadows dance around the corners of your vision... Did something just move behind you?"))
	return TRUE

/datum/status_effect/terrified/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_HELPED)
	owner.remove_fov_trait(type, FOV_270_DEGREES)
	owner.set_blurriness(0)

/datum/status_effect/terrified/tick(delta_time, times_fired)
	. = ..()

	check_surrounding_light()

	if(terror_buildup <= 0) //If we've completely calmed down, we remove the status effect.
		qdel(src)

	if(terror_buildup >= TERROR_FEAR_THRESHOLD) //The onset, minor effects of terror buildup
		owner.apply_status_effect(/datum/status_effect/dizziness, 5 SECONDS * delta_time)
		owner.adjust_stutter(5 SECONDS * delta_time)

	if(terror_buildup >= TERROR_PANIC_THRESHOLD) //If you reach this amount of buildup in an engagement, it's time to start looking for a way out.
		owner.playsound_local(get_turf(owner), 'sound/health/slowbeat.ogg', 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		owner.set_blurriness(2)
		if(prob(10)) //We have a little panic attack. Consider it GENTLE ENCOURAGEMENT to start running away.
			freak_out(PANIC_ATTACK_TERROR_AMOUNT)
			to_chat(owner, span_alert("Your heart lurches in your chest. You can't take much more of this!"))
	else
		owner.set_blurriness(0)

	if(terror_buildup >= TERROR_HEART_ATTACK_THRESHOLD) //You should only be able to reach this by actively terrorizing someone
		owner.visible_message(span_warning("[owner] clutches [owner.p_their(TRUE)] chest for a moment, then collapses to the floor.") ,span_alert("The shadows begin to creep up from the corners of your vision, and then there is nothing..."), span_hear("You hear something heavy collide with the ground."))
		owner.ForceContractDisease(/datum/disease/heart_failure)
		owner.Unconscious(20 SECONDS)
		qdel(src) //Victim passes out from fear, calming them down and permenantly damaging their heart.

/datum/status_effect/terrified/get_examine_text()
	. = ..()

	if(terror_buildup >= DARKNESS_TERROR_CAP) //If we're approaching a heart attack
		return span_boldwarning("[owner.p_they(TRUE)] [owner.p_are()] siezing up, about to collapse in fear!")

	if(terror_buildup >= TERROR_PANIC_THRESHOLD)
		return span_boldwarning("[owner] is visibly trembling and twitching. It looks like [owner.p_theyre(TRUE)] freaking out!")

	if(terror_buildup >= TERROR_FEAR_THRESHOLD)
		return span_warning("[owner] looks very worried about something. [owner.p_are()] [owner.p_they(TRUE)] alright?")

	return span_notice("[owner] looks rather anxious. [owner.p_they(TRUE)] could probably use a hug...")

/// If we get a hug from a friend, we calm down! If we get a hug from a nightmare, we FREAK OUT.
/datum/status_effect/terrified/proc/comfort_owner(datum/source, mob/living/hugger)
	SIGNAL_HANDLER

	if(is_species(hugger, /datum/species/shadow/nightmare)) //hey wait a minute, that's not a comforting, friendly hug!
		addtimer(CALLBACK(src, PROC_REF(freak_out), HUG_TERROR_AMOUNT))
		owner.visible_message(span_warning("[owner] recoils in fear as [hugger] waves [hugger.p_their(TRUE)] arms at them!"), span_boldwarning("The shadows lash out at you, and you drop to the ground in fear!"), span_hear("You hear someone shriek in fear. How embarassing!"))
		return COMPONENT_BLOCK_MISC_HELP

	terror_buildup -= HUG_TERROR_AMOUNT //maybe later I'll integrate some of the hug-related traits into this somehow
	owner.visible_message(span_warning("[owner] seems to relax as [hugger] gives [owner.p_them(TRUE)] a comforting hug."), span_nicegreen("You feel yourself calm down as [hugger] gives you a reassuring hug."), span_hear("You hear shuffling and a sigh of relief."))
	return

/**
 * Checks the surroundings of our victim and modifies terror buildup based on the amount of light nearby
 *
 * Checks the surrounded tiles for light amount. If the user has more light nearby, their terror is reduced.
 * Otherwise, their terror buildup will increase until it reaches DARKNESS_TERROR_CAP
 */

/datum/status_effect/terrified/proc/check_surrounding_light()
	var/lit_tiles = 0
	var/unlit_tiles = 0

	for(var/turf/open/turf_to_check in view(2, owner))
		var/light_amount = turf_to_check.get_lumcount()
		if(light_amount > 0.2)
			lit_tiles++
		else
			unlit_tiles++

	if(lit_tiles < unlit_tiles && terror_buildup < DARKNESS_TERROR_CAP)
		terror_buildup += DARKNESS_TERROR_AMOUNT
	else
		terror_buildup -= DARKNESS_TERROR_AMOUNT

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
	owner.emote("scream")

/// The status effect popup for the terror status effect
/atom/movable/screen/alert/status_effect/terrified
	name = "Terrified!"
	desc = "You feel a supernatural darkness settle in around you, overwhelming you with panic!"
	icon_state = "terrified"

#undef DARKNESS_TERROR_AMOUNT
#undef PANIC_ATTACK_TERROR_AMOUNT
#undef HUG_TERROR_AMOUNT
#undef DARKNESS_TERROR_CAP
#undef TERROR_FEAR_THRESHOLD
#undef TERROR_PANIC_THRESHOLD
#undef TERROR_HEART_ATTACK_THRESHOLD
