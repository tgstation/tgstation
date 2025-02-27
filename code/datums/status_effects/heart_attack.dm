///Stage one of the heart attack, begins effects when the timer ticks down to it.
#define ATTACK_STAGE_ONE 170
///Stage two of the heart attack.
#define ATTACK_STAGE_TWO 130
///Stage three of the heart attack.
#define ATTACK_STAGE_THREE 90
///Stage four of the heart attack.
#define ATTACK_STAGE_FOUR 45
///Stage five of the heart attack.
#define ATTACK_STAGE_FIVE 10
///When will a heart attack be visible to others on examine?
#define HEART_ATTACK_VISIBILITY 35

/datum/status_effect/heart_attack
	id = "heart_attack"
	status_type = STATUS_EFFECT_UNIQUE
	remove_on_fullheal = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/heart_attack
	///A timer that ticks down until the heart fully stops
	var/time_until_attack = 2 MINUTES
	///Does the victim hear their own heartbeat?
	var/sound = FALSE

/datum/status_effect/heart_attack/on_apply()
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(end_attack))
	return TRUE

/datum/status_effect/heart_attack/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)

/datum/status_effect/heart_attack/tick()
	if(time_until_attack > 2)
		if(SPT_PROB(1, tick_interval))
			to_chat(owner, span_warning("You feel [pick("discomfort", "pressure", "a burning sensation", "pain")] in your chest."))
		if(SPT_PROB(1, tick_interval))
			to_chat(owner, span_warning("You feel dizzy."))
			owner.adjust_confusion(6 SECONDS)
		if(SPT_PROB(1.5, tick_interval))
			to_chat(owner, span_warning("You feel [pick("full", "nauseated", "sweaty", "weak", "tired", "short of breath", "uneasy")]."))
	if(time_until_attack > 4)
		if(!sound)
			owner.playsound_local(owner, 'sound/effects/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			sound = TRUE
		if(SPT_PROB(1.5, tick_interval))
			to_chat(owner, span_danger("You feel a sharp pain in your chest!"))
			if(prob(25))
				to_chat(owner, "blah")
				//owner.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 95)
			owner.emote("cough")
			owner.Paralyze(40)
			owner.losebreath += 4
		if(SPT_PROB(1.5, tick_interval))
			to_chat(owner, span_danger("You feel very weak and dizzy..."))
			owner.adjust_confusion(8 SECONDS)
			owner.adjustStaminaLoss(40, FALSE)
			owner.emote("cough")
	if(time_until_attack > 7)
		owner.stop_sound_channel(CHANNEL_HEARTBEAT)
		owner.playsound_local(owner, 'sound/effects/singlebeat.ogg', 100, FALSE, use_reverb = FALSE)
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_danger("[owner] clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!"), \
				span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
		owner.adjustStaminaLoss(60, FALSE)
		//owner.set_heartattack(TRUE)
		owner.reagents.add_reagent(/datum/reagent/medicine/c2/penthrite, 3) // To give the victim a final chance to shock their heart before losing consciousness
		return FALSE

/datum/status_effect/heart_attack/get_examine_text()
//	if(time_until_attack <= HEART_ATTACK_VISIBILITY) //magic number kill this
//		return span_warning("[owner.p_they] looks to be doubling over, clutching [owner.p_their] chest in pain!")

///End the heart attack.
/datum/status_effect/heart_attack/proc/end_attack(datum/source, obj/item/organ)
	SIGNAL_HANDLER
	owner.remove_status_effect(src)

///Status effect/icon for heart attack
/atom/movable/screen/alert/status_effect/heart_attack
	name = "Heart Attack!"
	desc = "Your chest surges in pain! You're suffering a heart attack!"
	icon_state = "???"

#undef HEART_ATTACK_VISIBILITY
