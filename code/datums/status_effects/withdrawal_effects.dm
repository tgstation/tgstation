/datum/status_effect/withdrawal
	id = "drug_withdrawal"
	duration = -1
	///the appropriate moodlet applied by this type of withdrawal.
	var/moodlet_type = /datum/mood_event/withdrawal_medium
	///this var stores how many ticks we have been in withdrawal.
	var/withdrawal_ticks = 0

/datum/status_effect/withdrawal/tick()
	withdrawal_ticks++
	if(!owner.mind)
		qdel(src)
		return
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, moodlet_type)

/datum/status_effect/withdrawal/stimulant
	id = "stim_withdrawl"

//stims make you fast, so withdrawal makes you slow
/datum/status_effect/withdrawal/stimulant/on_apply()
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/stimulant_withdrawal)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/stimulant_withdrawal)

/datum/status_effect/withdrawal/stimulant/on_remove()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/stimulant_withdrawal)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/stimulant_withdrawal)
	return ..()

//If drowsiness was not a shit mechanic, we could add it to this effect.
/datum/status_effect/withdrawal/stimulant/tick()
	. = ..()
	if(withdrawal_ticks > 10 && prob(5))
		to_chat(owner, "<span class='warning'>[pick("You feel dead inside.", "You feel lethargic.", "You really need a little pick me up.")]</span>")
	if(withdrawal_ticks > 15 && prob(5))
		owner.emote("yawn")

/datum/status_effect/withdrawal/opioid
	id = "opioid_withdrawl"

/datum/status_effect/withdrawal/opioid/tick()
	. = ..()
	if(withdrawal_ticks > 10)
		owner.adjust_bodytemperature(-6 * TEMPERATURE_DAMAGE_COEFFICIENT, owner.get_body_temp_normal() - 30)
		if(prob(5))
			to_chat(owner, "<span class='warning'>[pick("You feel cold.", "You shiver.", "You feel droplets of sweat pour from your body.", "You need some pain relief!", "Your stomach turns.")]</span>")
	if(iscarbon(owner))
		var/mob/living/carbon/owner_carbon = owner
		if(withdrawal_ticks > 30 && owner_carbon.disgust < 10 && prob(2))
			owner_carbon.adjust_disgust(60)

/datum/status_effect/withdrawal/alcohol
	id = "alcohol_withdrawl"

/datum/status_effect/withdrawal/alcohol/tick()
	. = ..()
	if(withdrawal_ticks > 30)
		owner.Jitter(10)
		if(prob(4))
			to_chat(owner, "<span class='warning'>[pick("You could really go for a drink right now.", "You wonder if the bar is still open.", "You feel anxious.")]</span>")

	if(withdrawal_ticks > 60)
		owner.adjust_bodytemperature(6 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, owner.get_body_temp_normal() + 40)
		owner.Jitter(20)
		if(prob(3))
			to_chat(owner, "<span class='warning'>[pick("You feel hot.", "You feel like you're burning.", "You feel droplets of sweat pour from your body.")]</span>")

	if(withdrawal_ticks > 90)
		owner.Jitter(30)
		if(prob(25))
			owner.hallucination += 5

	if(withdrawal_ticks > 180)
		owner.Jitter(50)
		owner.adjust_bodytemperature(12 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, owner.get_body_temp_normal() + 80)
		//if(prob(5))
			//owner.add_status_effect(STATUS_EFFECT_STROKE) ANTLION

/datum/status_effect/withdrawal/hallucinogen
	id = "hallucinogen_withdrawl"

/datum/status_effect/withdrawal/hallucinogen/on_apply()


/datum/status_effect/withdrawal/hallucinogen/tick()
	. = ..()
	if(withdrawal_ticks > 15 && prob(5))
		to_chat(owner, "<span class='warning'>[pick("You feel strange.", "You feel trapped in the corporate matrix.", "You wonder what the machine elves are up to.")]</span>")

///For maintenance drugs proper and other dirty drugs.
/datum/status_effect/withdrawal/maint
	id = "maintenance_withdrawl"


