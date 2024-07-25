/datum/symptom/heart_failure
	name = "Myocardial Infarction"
	desc = "If left untreated the subject will die!"
	restricted = TRUE
	max_multiplier = 5
	var/sound = FALSE

/datum/symptom/heart_failure/activate(mob/living/carbon/affected_mob)
	. = ..()
	if(ismouse(affected_mob))
		affected_mob.death()
		return FALSE

	if(!affected_mob.can_heartattack())
		affected_mob.death()
		return FALSE

	switch(round(multiplier))
		if(1 to 2)
			if(prob(1))
				to_chat(affected_mob, span_warning("You feel [pick("discomfort", "pressure", "a burning sensation", "pain")] in your chest."))
			if(prob(1))
				to_chat(affected_mob, span_warning("You feel dizzy."))
				affected_mob.adjust_confusion(6 SECONDS)
			if(prob(1.5))
				to_chat(affected_mob, span_warning("You feel [pick("full", "nauseated", "sweaty", "weak", "tired", "short of breath", "uneasy")]."))
		if(3 to 4)
			if(!sound)
				affected_mob.playsound_local(affected_mob, 'sound/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				sound = TRUE
			if(prob(1.5))
				to_chat(affected_mob, span_danger("You feel a sharp pain in your chest!"))
				if(prob(25))
					affected_mob.vomit(95)
				affected_mob.emote("cough")
				affected_mob.Paralyze(40)
				affected_mob.losebreath += 4
			if(prob(1.5))
				to_chat(affected_mob, span_danger("You feel very weak and dizzy..."))
				affected_mob.adjust_confusion(8 SECONDS)
				affected_mob.stamina.adjust(-40, FALSE)
				affected_mob.emote("cough")
		if(5)
			affected_mob.stop_sound_channel(CHANNEL_HEARTBEAT)
			affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, FALSE, use_reverb = FALSE)
			if(affected_mob.stat == CONSCIOUS)
				affected_mob.visible_message(span_danger("[affected_mob] clutches at [affected_mob.p_their()] chest as if [affected_mob.p_their()] heart is stopping!"), \
					span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
			affected_mob.stamina.adjust(-60, FALSE)
			affected_mob.set_heartattack(TRUE)
			affected_mob.reagents.add_reagent(/datum/reagent/medicine/c2/penthrite, 3) // To give the victim a final chance to shock their heart before losing consciousness
			return FALSE

/datum/symptom/catapult_sneeze
	name = "Sneezing?"
	desc = "The virus causes irritation of the nasal cavity, making the host sneeze occasionally. Sneezes from this symptom will spread the virus in a 4 meter cone in front of the host."
	restricted = TRUE
	stage = 4
	max_multiplier = 10
	badness = EFFECT_DANGER_HARMFUL
	COOLDOWN_DECLARE(launch_cooldown)

/datum/symptom/catapult_sneeze/activate(mob/living/mob)
	mob.emote("sneeze")

	if(prob(5 * multiplier) && COOLDOWN_FINISHED(src, launch_cooldown))
		to_chat(mob, span_userdanger("You are launched violently backwards by an all-mighty sneeze!"))
		var/launch_distance = round(multiplier)
		var/turf/target = get_ranged_target_turf(mob, turn(mob.dir, 180), launch_distance)
		mob.throw_at(target, launch_distance, rand(3,9)) //with the wounds update, sneezing at 7 speed was causing peoples bones to spontaneously explode, turning cartoonish sneezing into a nightmarishly lethal GBS 2.0 outbreak
		COOLDOWN_START(src, launch_cooldown, 10 SECONDS)

	if(ishuman(mob))
		var/mob/living/carbon/human/host = mob
		if (prob(50) && isturf(mob.loc))
			if(istype(host.wear_mask, /obj/item/clothing/mask/cigarette))
				var/obj/item/clothing/mask/cigarette/I = host.get_item_by_slot(ITEM_SLOT_MASK)
				if(prob(20))
					var/turf/Q = get_turf(mob)
					var/turf/endLocation
					var/spitForce = pick(0,1,2,3)
					endLocation = get_ranged_target_turf(Q, mob.dir, spitForce)
					to_chat(mob, "<span class ='warning'>You sneezed \the [host.wear_mask] out of your mouth!</span>")
					host.dropItemToGround(I)
					I.throw_at(endLocation,spitForce,1)

/datum/symptom/fungal_tb
	name = "Fungal tuberculosis"
	desc = "Rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	restricted = TRUE
	max_multiplier = 5
	stage = 4

/datum/symptom/fungal_tb/activate(mob/living/affected_mob)
	if(prob(10))
		multiplier++
	switch(multiplier)
		if(2)
			if(prob(1))
				affected_mob.emote("cough")
				to_chat(affected_mob, span_danger("Your chest hurts."))
			if(prob(1))
				to_chat(affected_mob, span_danger("Your stomach violently rumbles!"))
			if(prob(2.5))
				to_chat(affected_mob, span_danger("You feel a cold sweat form."))
		if(4)
			if(prob(1))
				to_chat(affected_mob, span_userdanger("You see four of everything!"))
				affected_mob.set_dizzy_if_lower(10 SECONDS)
			if(prob(1))
				to_chat(affected_mob, span_danger("You feel a sharp pain from your lower chest!"))
				affected_mob.adjustOxyLoss(5, FALSE)
				affected_mob.emote("gasp")
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel air escape from your lungs painfully."))
				affected_mob.adjustOxyLoss(25, FALSE)
				affected_mob.emote("gasp")
		if(5)
			if(prob(1))
				to_chat(affected_mob, span_userdanger("[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]"))
				affected_mob.stamina.adjust(-70, FALSE)
			if(prob(5))
				affected_mob.stamina.adjust(-100, FALSE)
				affected_mob.visible_message(span_warning("[affected_mob] faints!"), span_userdanger("You surrender yourself and feel at peace..."))
				affected_mob.AdjustSleeping(100)
			if(prob(1))
				to_chat(affected_mob, span_userdanger("You feel your mind relax and your thoughts drift!"))
				affected_mob.adjust_confusion_up_to(8 SECONDS, 100 SECONDS)
			if(prob(5))
				if(ishuman(affected_mob))
					var/mob/living/carbon/human/human = affected_mob
					human.vomit(20)
			if(prob(1.5))
				to_chat(affected_mob, span_warning("<i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i>"))
				affected_mob.overeatduration = max(affected_mob.overeatduration - (200 SECONDS), 0)
				affected_mob.adjust_nutrition(-100)
			if(prob(7.5))
				to_chat(affected_mob, span_danger("[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit...", "You feel like taking off some clothes...")]"))
				affected_mob.adjust_bodytemperature(40)
