///Stage two of the heart attack.
#define ATTACK_STAGE_TWO 100
///Stage three of the heart attack.
#define ATTACK_STAGE_THREE 70
///Stage four of the heart attack.
#define ATTACK_STAGE_FOUR 35
///If we reduce heart damage enough, it will recover on its own.
#define ATTACK_CURE_THRESHOLD 160
///What is the max oxyloss we're willing to deal, to prevent people from passing out early.
#define OXYLOSS_MAXIMUM 40

/datum/status_effect/heart_attack
	id = "heart_attack"
	remove_on_fullheal = TRUE
	alert_type = null
	///A timer that ticks down until the heart fully stops
	var/time_until_stoppage = 150
	///Does this show up on medhuds?
	var/visible = FALSE

/datum/status_effect/heart_attack/on_apply()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner) || !human_owner.can_heartattack())
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_removed))
	RegisterSignal(owner, COMSIG_LIVING_MINOR_SHOCK, PROC_REF(minor_shock))
	RegisterSignal(owner, COMSIG_HEARTATTACK_DEFIB, PROC_REF(defib_shock))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(electrocuted))
	return TRUE

/datum/status_effect/heart_attack/on_remove()
	UnregisterSignal(owner, list(COMSIG_CARBON_LOSE_ORGAN, COMSIG_LIVING_MINOR_SHOCK, COMSIG_HEARTATTACK_DEFIB, COMSIG_LIVING_ELECTROCUTE_ACT))

/datum/status_effect/heart_attack/tick(seconds_between_ticks)
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner) || !human_owner.can_heartattack())
		qdel(src) //No heart? No effects.
		return

	if(time_until_stoppage > ATTACK_CURE_THRESHOLD)
		owner.visible_message(span_nicegreen("[owner] relaxes [owner.p_their()] body and stops clutching at [owner.p_their()] chest!"), span_nicegreen("The pain in your chest has subsided. You're cured!"))
		qdel(src)
		return

	var/oxyloss_sum = 0 //A sum of the oxyloss we will inflict by the end of this cycle.

	if(time_until_stoppage > ATTACK_STAGE_THREE)
		if(SPT_PROB(5, seconds_between_ticks))
			owner.playsound_local(owner, 'sound/effects/singlebeat.ogg', 25, FALSE, use_reverb = FALSE)
			owner.adjustStaminaLoss(5)

	if(time_until_stoppage <= ATTACK_STAGE_TWO && time_until_stoppage > ATTACK_STAGE_THREE)	//This coughing gets replaced with worse coughing, no need to stack it.
		if(SPT_PROB(10, seconds_between_ticks))
			owner.emote("cough")
			owner.adjustStaminaLoss(10)
			oxyloss_sum += 4

	if(time_until_stoppage <= ATTACK_STAGE_THREE) //At this point, we start with chat messages and make it clear that something is very wrong.
		if(!visible)
			ADD_TRAIT(owner, TRAIT_DISEASELIKE_SEVERITY_HIGH, type)
			owner.med_hud_set_status()
			visible = TRUE //We do not reset this status until it's fully cured. Once it's been made apparent, there's no reason to hide it again until it is resolved. It will only confuse players.
		if(SPT_PROB(15, seconds_between_ticks))
			to_chat(owner, span_danger("You feel a sharp pain in your chest!"))
			if(SPT_PROB(15, seconds_between_ticks))
				human_owner.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 95)
			owner.emote("cough")
			oxyloss_sum += 1
		if(SPT_PROB(8, seconds_between_ticks))
			to_chat(owner, span_danger("You feel very weak and dizzy..."))
			owner.adjust_confusion_up_to(6 SECONDS, 10 SECONDS)
			owner.adjustStaminaLoss(20)
			owner.emote("cough")
			oxyloss_sum += 8

	if(time_until_stoppage <= ATTACK_STAGE_FOUR) //And now we compound it with even worse effects.

		if(SPT_PROB(5, seconds_between_ticks))
			to_chat(owner, span_userdanger("It feels like you're shutting down..."))
			owner.adjust_dizzy_up_to(4 SECONDS, 10 SECONDS)
			owner.adjust_eye_blur_up_to(4 SECONDS, 20 SECONDS)
			owner.adjustStaminaLoss(20)

		if(SPT_PROB(5, seconds_between_ticks))
			owner.emote("cough")
			if(SPT_PROB(5, seconds_between_ticks))
				to_chat(owner, span_userdanger("You cough. Everything goes dark. You're going to die soon."))
				owner.adjust_temp_blindness(10 SECONDS) //Are you panicking yet? You should be panicking by now.
			else
				to_chat(owner, span_userdanger("As you cough, your chest surges in pain and darkness closes in around your sight."))
				owner.adjust_temp_blindness(2 SECONDS)
				owner.adjust_eye_blur_up_to(4 SECONDS, 20 SECONDS)
			oxyloss_sum += 8
			owner.Paralyze(1 SECONDS)
		oxyloss_sum += 3

	if(owner.getOxyLoss() < OXYLOSS_MAXIMUM) //A bad enough roll on the verge of passing out might still push you over into unconciousness for a few seconds...?
		owner.adjustOxyLoss(oxyloss_sum)

	if(time_until_stoppage <= 0)
		if(owner.stat == CONSCIOUS)
			to_chat(owner, span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
		owner.adjust_eye_blur(20 SECONDS)
		human_owner.set_heartattack(TRUE)
		owner.apply_status_effect(/datum/status_effect/heart_desperation) // To give the victim a final chance to shock their heart before losing consciousness
		var/flash_type = /atom/movable/screen/fullscreen/flash
		if(owner.client?.prefs?.read_preference(/datum/preference/toggle/darkened_flash))
			flash_type = /atom/movable/screen/fullscreen/flash/black
		owner.overlay_fullscreen("flash", flash_type)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, clear_fullscreen), "flash", 1 SECONDS), 1 SECONDS)
		qdel(src)
		return FALSE

	if(time_until_stoppage <= ATTACK_STAGE_TWO)
		if(time_until_stoppage <= ATTACK_STAGE_FOUR)
			owner.playsound_local(owner, 'sound/effects/singlebeat.ogg', 100, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		else
			owner.playsound_local(owner, 'sound/effects/health/slowbeat.ogg', 25, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
	else
		owner.stop_sound_channel(CHANNEL_HEARTBEAT)

	time_until_stoppage--

/datum/status_effect/heart_attack/get_examine_text()
	if(!time_until_stoppage <= ATTACK_STAGE_THREE)
		return
	var/mob/living/carbon/human/human_owner = owner
	var/cannot_grasp = (human_owner.usable_hands <= 0 || owner.incapacitated & INCAPABLE_RESTRAINTS || HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
	return span_warning("[owner.p_they()] looks to be doubling over" + "[cannot_grasp ? " in pain!" : ", clutching [owner.p_their()] chest in pain!"]")

/datum/status_effect/heart_attack/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DISEASELIKE_SEVERITY_HIGH, type)
	owner.med_hud_set_status()
	return ..()

///End the heart attack due to heart removal.
/datum/status_effect/heart_attack/proc/on_organ_removed(datum/source, obj/item/organ)
	SIGNAL_HANDLER
	if(istype(organ, /obj/item/organ/heart))
		qdel(src)

///Slightly reduces your timer. Can cure you if you really really want.
/datum/status_effect/heart_attack/proc/minor_shock(datum/source)
	SIGNAL_HANDLER
	time_until_stoppage += 18 //Good for keeping yourself up. Won't be easy to get over the cure threshold by yourself. You're going to need security beating the crap out of you with stunbatons, but it'll work.
	if(prob(50)) //Also good for crafty solos who want to stunbaton themselves back to health. Timing will be key.
		to_chat(owner, span_nicegreen("Something about being shocked makes the pain in your chest ease up!"))

///Makes major progress towards curing the attack.
/datum/status_effect/heart_attack/proc/defib_shock(obj/item/shockpaddles/source)
	SIGNAL_HANDLER
	time_until_stoppage += 50 //Three shocks should save pretty much anyone.
	owner.visible_message(span_nicegreen("[owner] seems to be relieved of their pain as they're shocked by the [source]!"), span_nicegreen("The [source] shocks your heart awake, and you feel the pain in your chest ease up!"))

///Slightly reduces your timer, just like the minor shock signal. Slightly more relief because these use cases are generally more dangerous.
/datum/status_effect/heart_attack/proc/electrocuted(datum/source, shock_damage)
	SIGNAL_HANDLER
	time_until_stoppage += (20 + shock_damage * 1.15)
	if(prob(50))
		to_chat(owner, span_nicegreen("Something about being electrocuted makes the pain in your chest ease up!"))

///Alternative to penthrite that keeps you up for a few seconds after having a heart attack. Gives a bit of time to call for help regardless of when/where you've collapsed.
/datum/status_effect/heart_desperation
	id = "heart_desperation"
	duration = (4 SECONDS)
	alert_type = null
	/// List of traits to add/remove from our subject when we are in their system
	var/static/list/subject_traits = list(
		TRAIT_STABLEHEART,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOCRITDAMAGE,
	)

/datum/status_effect/heart_desperation/on_apply()
	owner.add_traits(subject_traits, type)
	owner.Knockdown(2 SECONDS, 2 SECONDS)
	return TRUE

/datum/status_effect/heart_desperation/tick(seconds_between_ticks)
	owner.Knockdown(2 SECONDS, 2 SECONDS)
	owner.set_silence_if_lower(2 SECONDS)

/datum/status_effect/heart_desperation/on_remove()
	owner.remove_traits(subject_traits, type)

#undef ATTACK_STAGE_TWO
#undef ATTACK_STAGE_THREE
#undef ATTACK_STAGE_FOUR
#undef ATTACK_CURE_THRESHOLD
#undef OXYLOSS_MAXIMUM
