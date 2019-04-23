/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp."
	restraint_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "blinks rapidly."

/datum/emote/living/carbon/dab
	key = "dab"
	key_third_person = "dabs"
	restraint_check = TRUE
	message = "hits a nasty dab!"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/human)

/datum/emote/living/carbon/dab/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/C = user
	var/monky = FALSE
	if(ismonkey(C))
		var/safety = alert(C, "Doing this may be harmful to monkey health.", "Dab?", "Nah", "HIT IT!")
		if(safety =="HIT IT!")
			monky = TRUE
	. = ..()
	if(monky)
		C.visible_message("<span class='warning'>[C] hits a fat monkey dab, causing them to violently tear apart!</span>", "<span class='danger'>Your monkey dab is so deep and hard that the sheer force rips your entire body apart!</span>")
		C.gib()
		return
	if(iscatperson(C)) //epic
		var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
		if(ears)
			C.visible_message("<span class='warning'>[C] hit the dab so hard their ears flew off!</span>", "<span class='danger'>You feel a pop from the top of your head, and suddenly you can't hear anything!</span>")
			ears.Remove(C)
			return
	if(prob(50)) //50% chance of funtime effects
		return
	if(ishuman(C))
		var/selected_part
		switch(rand(1, 5))
			if(1)
				selected_part = "SEIZURE_TIME"
			if(2)
				selected_part = BODY_ZONE_L_LEG
			if(3)
				selected_part = BODY_ZONE_R_LEG
			if(4)
				selected_part = BODY_ZONE_R_ARM
			if(5)
				selected_part = BODY_ZONE_L_ARM
		if(selected_part == "SEIZURE_TIME")
			C.visible_message("<span class='warning'>[C] starts seizing and convulsing!</span>", "<span class='danger'>As you hit the dab, your whole body begins spasming!</span>")
			var/datum/brain_trauma/T
			if(prob(80))
				T = BRAIN_TRAUMA_SEVERE
			else
				T = BRAIN_TRAUMA_SPECIAL
			C.Paralyze(60)
			C.gain_trauma_type(T)
			return
		if(selected_part == BODY_ZONE_L_LEG || selected_part == BODY_ZONE_R_LEG)
			var/obj/item/bodypart/bp = C.get_bodypart(selected_part)
			if(bp)
				C.visible_message("<span class='warning'>[C] dabbed so hard they broke their leg! Ouch!</span>", "<span class='danger'>You feel a pop and a massive pain in your leg as you hit the bottom of that sick dab!</span>")
				bp.receive_damage(200)
				playsound(C, "desceration", 50, TRUE)
			return
		if(selected_part == BODY_ZONE_R_ARM || selected_part == BODY_ZONE_L_ARM)
			var/obj/item/bodypart/bp = C.get_bodypart(selected_part)
			if(bp)
				C.visible_message("<span class='warning'>[C] dabs aggressively, causing an arm to pop off with a sickening squelch!</span>", "<span class='danger'>You feel your arm seperate from your body as you hit the bottom of that sick dab!</span>")
				bp.dismember()
				playsound(C, "desceration", 50, TRUE)
			return
			

	

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('sound/misc/clap1.ogg',
							'sound/misc/clap2.ogg',
							'sound/misc/clap3.ogg',
							'sound/misc/clap4.ogg')

/datum/emote/living/carbon/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans!"
	message_mime = "appears to moan!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/screech
	key = "screech"
	key_third_person = "screeches"
	message = "screeches."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	restraint_check = TRUE

/datum/emote/living/carbon/tail
	key = "tail"
	message = "waves their tail."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."
