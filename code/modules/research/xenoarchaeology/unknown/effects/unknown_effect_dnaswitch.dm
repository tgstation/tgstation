
//todo
/datum/artifact_effect/dnaswitch
	effecttype = "dnaswitch"
	var/severity

/datum/artifact_effect/dnaswitch/New()
	..()
	if(effect == EFFECT_AURA)
		severity = rand(1,10)
	else
		severity = rand(5,95)

/datum/artifact_effect/dnaswitch/DoEffectTouch(var/mob/holder)
	if(ishuman(holder) && !istype(holder:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && !istype(holder:head,/obj/item/clothing/head/bio_hood/anomaly))
		holder << pick("\green You feel a little different.",\
		"\green You feel very strange.",\
		"\green Your stomach churns.",\
		"\green Your skin feels loose.",\
		"\green You feel a stabbing pain in your head.",\
		"\green You feel a tingling sensation in your chest.",\
		"\green Your entire body vibrates.")
		if(prob(75))
			scramble(1, holder, severity)
		else
			scramble(0, holder, severity)
	return 1

/datum/artifact_effect/dnaswitch/DoEffectAura()
	for(var/mob/living/carbon/human/H in range(src.effectrange,holder))
		if(istype(H:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(H:head,/obj/item/clothing/head/bio_hood/anomaly))
			continue

		if(prob(30))
			H << pick("\green You feel a little different.",\
			"\green You feel very strange.",\
			"\green Your stomach churns.",\
			"\green Your skin feels loose.",\
			"\green You feel a stabbing pain in your head.",\
			"\green You feel a tingling sensation in your chest.",\
			"\green Your entire body vibrates.")
		if(prob(25))
			scramble(1, H, severity)
		else
			scramble(0, H, severity)
	return 1

/datum/artifact_effect/dnaswitch/DoEffectPulse()
	for(var/mob/living/carbon/human/H in range(200, holder))
		if(istype(H:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(H:head,/obj/item/clothing/head/bio_hood/anomaly))
			continue

		if(prob(75))
			H << pick("\green You feel a little different.",\
			"\green You feel very strange.",\
			"\green Your stomach churns.",\
			"\green Your skin feels loose.",\
			"\green You feel a stabbing pain in your head.",\
			"\green You feel a tingling sensation in your chest.",\
			"\green Your entire body vibrates.")
		if(prob(25))
			if(prob(50))
				scramble(1, H, severity)
			else
				scramble(0, H, severity)
	return 1
