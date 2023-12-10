/datum/symptom/narcolepsy
	name = "Aurora Snorealis"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	stage = 2
	restricted = TRUE
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 5
	var/yawning = FALSE


/datum/symptom/narcolepsy/activate(mob/living/carbon/M)
	switch(round(multiplier, 1))
		if(1)
			if(prob(50))
				to_chat(M, span_warning("You feel tired."))
		if(2)
			if(prob(50))
				to_chat(M, span_warning("You feel very tired."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("You try to focus on staying awake."))

			M.adjust_drowsiness_up_to(2.5 SECONDS, 20 SECONDS)

		if(4)
			if(prob(50))
				if(yawning)
					to_chat(M, span_warning("You try and fail to suppress a yawn."))
				else
					to_chat(M, span_warning("You nod off for a moment.")) //you can't really yawn while nodding off, can you?

			M.adjust_drowsiness_up_to(5 SECONDS, 20 SECONDS)

			if(yawning)
				M.emote("yawn")
				if(M.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/V  as anything in M.diseases)
					strength += V.infectionchance
				strength = round(strength/M.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), M, virus_copylist(M.diseases))
					strength -= 30
					i++

		if(5)
			if(prob(50))
				to_chat(M, span_warning("[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]"))

			M.adjust_drowsiness_up_to(10 SECONDS, 20 SECONDS)

			if(yawning)
				M.emote("yawn")
				if(M.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/V  as anything in M.diseases)
					strength += V.infectionchance
				strength = round(strength/M.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), M, virus_copylist(M.diseases))
					strength -= 30
					i++
