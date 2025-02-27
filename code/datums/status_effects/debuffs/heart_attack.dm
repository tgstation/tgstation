///Stage one of the heart attack, begins effects when the timer ticks down to it.
#define ATTACK_STAGE_ONE 110
///Stage two of the heart attack.
#define ATTACK_STAGE_TWO 90
///Stage three of the heart attack.
#define ATTACK_STAGE_THREE 60
///Stage four of the heart attack.
#define ATTACK_STAGE_FOUR 30
///When will a heart attack be visible to others on examine?
#define HEART_ATTACK_VISIBILITY 60
///If we reduce heart damage enough, it will recover on its own.
#define ATTACK_CURE_THRESHOLD 200

/datum/status_effect/heart_attack
	id = "heart_attack"
	status_type = STATUS_EFFECT_UNIQUE
	remove_on_fullheal = TRUE
	alert_type = null
	///A timer that ticks down until the heart fully stops
	var/time_until_stoppage = 120
	///Does the victim hear their own heartbeat?
	var/sound = FALSE

/datum/status_effect/heart_attack/on_apply()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner) || !human_owner.can_heartattack())
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(end_attack))
	return TRUE

/datum/status_effect/heart_attack/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)

/datum/status_effect/heart_attack/tick()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner) || !human_owner.can_heartattack())
		qdel(src) //No heart? No effects.

	if(time_until_stoppage <= ATTACK_STAGE_ONE && time_until_stoppage > ATTACK_STAGE_TWO) //Minor, untelegraphed problems. Stage three is where real symptoms hit.
		if(prob(5))
			owner.playsound_local(owner, 'sound/effects/singlebeat.ogg', 25, FALSE, use_reverb = FALSE)
			owner.adjustStaminaLoss(20, FALSE)

	if(time_until_stoppage <= ATTACK_STAGE_TWO && time_until_stoppage > ATTACK_STAGE_THREE)
		owner.playsound_local(owner, 'sound/effects/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		if(prob(10))
			owner.emote("cough")
			owner.adjustStaminaLoss(10)

	if(time_until_stoppage <= ATTACK_STAGE_THREE && time_until_stoppage > ATTACK_STAGE_FOUR) //At this point, we start with chat messages and make it clear that something is very wrong.
		if(prob(10))
			to_chat(owner, span_danger("You feel a sharp pain in your chest!"))
			if(prob(25))
				human_owner.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 95)
			owner.emote("cough")
		if(prob(5))
			to_chat(owner, span_danger("You feel very weak and dizzy..."))
			owner.adjust_confusion_up_to(6 SECONDS, 10 SECONDS)
			owner.adjustStaminaLoss(40)
			owner.emote("cough")

	if(time_until_stoppage <= ATTACK_STAGE_FOUR)
		owner.stop_sound_channel(CHANNEL_HEARTBEAT)
		sound = FALSE
		owner.playsound_local(owner, 'sound/effects/singlebeat.ogg', 100, FALSE, use_reverb = FALSE)

		if(prob(10))
			to_chat(owner, span_userdanger("It feels like you're shutting down..."))
			owner.adjust_dizzy_up_to(2 SECONDS, 20 SECONDS)
			owner.adjust_eye_blur_up_to(1.5 SECONDS, 6 SECONDS)

		if(prob(5))
			owner.emote("cough")
			if(prob(5))
				to_chat(owner, span_userdanger("You cough. Everything goes dark. You're going to die soon."))
				owner.adjust_temp_blindness(10 SECONDS) //Are you panicking yet? You should be panicking by now.
			else
				to_chat(owner, span_userdanger("As you cough, your chest surges in pain and darkness closes in around your sight."))
				owner.adjust_temp_blindness(2 SECONDS)
				owner.adjust_eye_blur(4 SECONDS)
			owner.losebreath += 8
			owner.adjustStaminaLoss(20)
			owner.Paralyze(30)

	if(time_until_stoppage <= 0)
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_danger("[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!"), \
			span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
		owner.adjustStaminaLoss(60)
		owner.adjust_eye_blur(20 SECONDS)
		human_owner.set_heartattack(TRUE)
		owner.reagents.add_reagent(/datum/reagent/medicine/c2/penthrite/heart_attack, 2) // To give the victim a final chance to shock their heart before losing consciousness
		qdel(src)
		return FALSE

	time_until_stoppage--

/datum/status_effect/heart_attack/get_examine_text()
	if(time_until_stoppage <= HEART_ATTACK_VISIBILITY)
		return span_warning("[owner.p_they()] looks to be doubling over, clutching [owner.p_their()] chest in pain!")

///End the heart attack.
/datum/status_effect/heart_attack/proc/end_attack(datum/source, obj/item/organ)
	SIGNAL_HANDLER
	if(istype(organ, /obj/item/organ/heart))
		qdel(src)

#undef HEART_ATTACK_VISIBILITY
#undef ATTACK_STAGE_ONE
#undef ATTACK_STAGE_TWO
#undef ATTACK_STAGE_THREE
#undef ATTACK_STAGE_FOUR
#undef ATTACK_CURE_THRESHOLD
