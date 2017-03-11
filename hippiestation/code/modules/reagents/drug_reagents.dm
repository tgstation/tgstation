/datum/reagent/drug/fartium
	name = "Fartium"
	id = "fartium"
	description = "A chemical compound that promotes concentrated production of gas in your groin area."
	color = "#8A4B08" // rgb: 138, 75, 8
	reagent_state = LIQUID
	overdose_threshold = 30
	addiction_threshold = 50

/datum/reagent/drug/fartium/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/butt/B = locate() in H.internal_organs
		if(prob(7))
			if(B)
				H.emote("fart")
			else
				to_chat(H, "<span class='danger'>Your stomach rumbles as pressure builds up inside of you.</span>")
				H.adjustToxLoss(1*REM)
	..()
	return

/datum/reagent/drug/fartium/overdose_process(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/butt/B = locate() in H.internal_organs
		if(prob(9))
			if(B)
				H.emote("fart")
			else
				to_chat(H, "<span class='danger'>Your stomach hurts a bit as pressure builds up inside of you.</span>")
				H.adjustToxLoss(2*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage1(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/butt/B = locate() in H.internal_organs
		if(prob(11))
			if(B)
				H.emote("fart")
			else
				to_chat(H, "<span class='danger'>Your stomach hurts as pressure builds up inside of you.</span>")
				H.adjustToxLoss(3*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage2(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/butt/B = locate() in H.internal_organs
		if(prob(13))
			if(B)
				H.emote("fart")
			else
				to_chat(H, "<span class='danger'>Your stomach hurts a lot as pressure builds up inside of you.</span>")
				H.adjustToxLoss(4*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage3(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/butt/B = locate() in H.internal_organs
		if(prob(15))
			if(B)
				if(prob(2) && !B.loose) H.emote("superfart")
				else H.emote("fart")
			else
				to_chat(H, "<span class='danger'>Your stomach hurts too much as pressure builds up inside of you.</span>")
				H.adjustToxLoss(5*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage4(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/butt/B = locate() in H.internal_organs
		if(prob(15))
			if(B)
				if(prob(5) && !B.loose) H.emote("superfart")
				else H.emote("fart")
			else
				to_chat(H, "<span class='danger'>Your stomach hurts too much as pressure builds up inside of you.</span>")
				H.adjustToxLoss(6*REM)
	..()