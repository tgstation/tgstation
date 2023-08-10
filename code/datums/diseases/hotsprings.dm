/datum/disease/cursedhotsprings
	name = "The Misconfigured Nanites"
	max_stages = 9 ///Nanites multiply slowly. It gives time to make rezadone(or time to say goodbye)
	spread_text = "Does not spread"
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	disease_flags = CURABLE|CAN_CARRY
	cure_text = "Rezadone to cure. Ammoniated Mercury to temporarily stabilize. Works until stage 5."
	cure_chance = 100
	cures = list(/datum/reagent/medicine/rezadone)
	agent = "Bad nanite programming."
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated the subject will transform into a random creature."
	severity = DISEASE_SEVERITY_POSITIVE ///Changed on stage 5
	bypasses_immunity = TRUE ///It's not your immunity winning. It's rezadone.
	stage_prob = 1

/datum/disease/cursedhotsprings/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1,2,3,4) ///Initially good
			if(DT_PROB(5, delta_time))
				var/mob/living/carbon/human/H = affected_mob
				if(H.age > 20)
					H.age -= 1
					to_chat(H, span_notice("You feel energized and younger!"))

			if(affected_mob.reagents.has_reagent(/datum/reagent/medicine/ammoniated_mercury)) //Yep. No going back once the stage is greater than 4
				if(stage > 1)
					stage -= 1

			if(DT_PROB(25, delta_time))
				if(affected_mob.getToxLoss())
					affected_mob.adjustToxLoss(-(stage))


			if(DT_PROB(25, delta_time))
				var/list/parts = affected_mob.get_damaged_bodyparts(1,1)
				for(var/obj/item/bodypart/L in parts)
					if(L.heal_damage(0.25*stage, 0.25*stage, BODYTYPE_ORGANIC))
						affected_mob.update_damage_overlays()
				to_chat(affected_mob, span_notice("Your flesh mends by itself."))

		if(5) ///Then deadly
			if(severity == DISEASE_SEVERITY_POSITIVE)
				severity = DISEASE_SEVERITY_BIOHAZARD

			affected_mob.adjust_nutrition(-2)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_danger("Your skin feels itchy."))

		if(6)
			affected_mob.adjust_nutrition(-5)
			if(DT_PROB(3, delta_time))
				to_chat(affected_mob, span_danger("You feel strange."))
			if(DT_PROB(3, delta_time))
				to_chat(affected_mob, span_danger("You feel not with your skin."))
			if(DT_PROB(3, delta_time))
				affected_mob.emote("cough")

		if(7)
			affected_mob.adjust_nutrition(-10)
			affected_mob.adjust_bodytemperature(5 * delta_time)
			if(DT_PROB(4, delta_time))
				to_chat(affected_mob, span_danger("Your skin burns."))
				affected_mob.take_bodypart_damage(0, 5, updating_health = FALSE)
			if(DT_PROB(6, delta_time))
				to_chat(affected_mob, span_danger("Your legs suddenly refuse to follow your orders, for a moment."))
				affected_mob.adjustStaminaLoss(70, FALSE)

		if(8)
			affected_mob.adjust_nutrition(-25)
			affected_mob.adjust_bodytemperature(15 * delta_time)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_danger("Your skin peels off and falls!"))
				affected_mob.take_bodypart_damage(10, 0, updating_health = FALSE)
				affected_mob.emote("scream")
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_danger("The world spins around you. You feel dizzy, almost ready to faint."))
				if(DT_PROB(1, delta_time))
					affected_mob.emote("spin") /// You spin me right round baby, right round
				affected_mob.set_dizzy_if_lower(10 SECONDS)
				affected_mob.adjust_hallucinations(10 SECONDS)
				affected_mob.set_eye_blur_if_lower(5 SECONDS)
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("The sudden pain in your stomache forces you to vomit."))
				affected_mob.vomit(20, TRUE, distance = 3)
			if(DT_PROB(50, delta_time))
				if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !isspaceturf(affected_mob.loc) && isturf(affected_mob.loc))
					step(affected_mob, pick(GLOB.cardinals))
					to_chat(affected_mob, span_danger("Your legs move on their own!"))

		if(9)
			var/mob/living/transformed_mob = affected_mob.wabbajack(pick(WABBAJACK_HUMAN, WABBAJACK_ANIMAL), change_flags = RACE_SWAP)
			if(!transformed_mob)
				// Wabbajack failed, maybe the mob had godmode or something.
				if(!QDELETED(affected_mob))
					to_chat(affected_mob, span_notice("You suddenly feel better."))
					cure()

