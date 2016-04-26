
//todo
/datum/artifact_effect/dnaswitch
	effecttype = "dnaswitch"
	effect_type = 5
	var/severity

/datum/artifact_effect/dnaswitch/New()
	..()
	if(effect == EFFECT_AURA)
		severity = rand(5,30)
	else
		severity = rand(25,95)

/datum/artifact_effect/dnaswitch/DoEffectTouch(var/mob/toucher)
	var/weakness = GetAnomalySusceptibility(toucher)
	if(ishuman(toucher) && prob(weakness * 100))
		to_chat(toucher, pick("<span class='good'>You feel a little different.</span>",\
		"<span class='good'>You feel very strange.</span>",\
		"<span class='good'>Your stomach churns.</span>",\
		"<span class='good'>Your skin feels loose.</span>",\
		"<span class='good'>You feel a stabbing pain in your head.</span>",\
		"<span class='good'>You feel a tingling sensation in your chest.</span>",\
		"<span class='good'>Your entire body vibrates.</span>"))
		if(prob(75))
			scramble(1, toucher, weakness * severity)
		else
			scramble(0, toucher, weakness * severity)
	return 1

/datum/artifact_effect/dnaswitch/DoEffectAura()
	if(holder)
		for(var/mob/living/carbon/human/H in range(src.effectrange,holder))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(30))
					to_chat(H, pick("<span class='good'>You feel a little different.</span>",\
					"<span class='good'>You feel very strange.</span>",\
					"<span class='good'>Your stomach churns.</span>",\
					"<span class='good'>Your skin feels loose.</span>",\
					"<span class='good'>You feel a stabbing pain in your head.</span>",\
					"<span class='good'>You feel a tingling sensation in your chest.</span>",\
					"<span class='good'>Your entire body vibrates.</span>"))
				if(prob(50))
					scramble(1, H, weakness * severity)
				else
					scramble(0, H, weakness * severity)

/datum/artifact_effect/dnaswitch/DoEffectPulse()
	if(holder)
		for(var/mob/living/carbon/human/H in range(200, holder))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(75))
					to_chat(H, pick("<span class='good'>You feel a little different.</span>",\
					"<span class='good'>You feel very strange.</span>",\
					"<span class='good'>Your stomach churns.</span>",\
					"<span class='good'>Your skin feels loose.</span>",\
					"<span class='good'>You feel a stabbing pain in your head.</span>",\
					"<span class='good'>You feel a tingling sensation in your chest.</span>",\
					"<span class='good'>Your entire body vibrates.</span>"))
				if(prob(25))
					if(prob(75))
						scramble(1, H, weakness * severity)
					else
						scramble(0, H, weakness * severity)
