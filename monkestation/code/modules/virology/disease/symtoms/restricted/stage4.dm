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
