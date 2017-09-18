/datum/disease/heart_failure
	form = "Condition"
	name = "Myocardial Infarction"
	max_stages = 5
	stage_prob = 2
	cure_text = "Heart replacement surgery to cure. Defibrillation (or as a last resort, uncontrolled electric shocking) may also be effective after the onset of cardiac arrest. Corazone can also mitigate cardiac arrest."
	agent = "Shitty Heart"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will die!"
	severity = "Dangerous!"
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/heart)
	var/sound = FALSE

/datum/disease/heart_failure/stage_act()
	..()
	var/obj/item/organ/heart/O = affected_mob.getorgan(/obj/item/organ/heart)
	var/mob/living/carbon/human/H = affected_mob
	if(O && H.can_heartattack())
		switch(stage)
			if(1 to 2)
				if(prob(2))
					to_chat(affected_mob, "<span class='warning'>You feel [pick("discomfort", "pressure", "a burning sensation", "pain")] in your chest.</span>")
				if(prob(2))
					to_chat(affected_mob, "<span class='warning'>You feel dizzy.</span>")
					affected_mob.confused += 6
				if(prob(3))
					to_chat(affected_mob, "<span class='warning'>You feel [pick("full", "nauseous", "sweaty", "weak", "tired", "short on breath", "uneasy")].</span>")
			if(3 to 4)
				if(!sound)
					affected_mob.playsound_local(affected_mob, 'sound/health/slowbeat.ogg',40,0, channel = CHANNEL_HEARTBEAT)
					sound = TRUE
				if(prob(3))
					to_chat(affected_mob, "<span class='danger'>You feel a sharp pain in your chest!</span>")
					if(prob(25))
						affected_mob.vomit(95)
					affected_mob.emote("cough")
					affected_mob.Knockdown(40)
					affected_mob.losebreath += 4
				if(prob(3))
					to_chat(affected_mob, "<span class='danger'>You feel very weak and dizzy...</span>")
					affected_mob.confused += 8
					affected_mob.adjustStaminaLoss(40)
					affected_mob.emote("cough")
			if(5)
				H.stop_sound_channel(CHANNEL_HEARTBEAT)
				affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, 0)
				if(affected_mob.stat == CONSCIOUS)
					affected_mob.visible_message("<span class='userdanger'>[affected_mob] clutches at [affected_mob.p_their()] chest as if [affected_mob.p_their()] heart is stopping!</span>")
				affected_mob.adjustStaminaLoss(60)
				cure()
				addtimer(CALLBACK(H, /mob/living/carbon/human.proc/set_heartattack, TRUE), 100)
	else
		cure()