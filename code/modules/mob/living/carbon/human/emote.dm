/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	restraint_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wags their tail."

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(.)
		H.startTailWag()
	else
		H.endTailWag()

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species && (("tail_lizard" in H.dna.species.mutant_bodyparts) || (H.dna.features["tail_human"] != "None")))
		return TRUE

/datum/emote/living/carbon/human/wag/select_message_type(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(("waggingtail_lizard" in H.dna.species.mutant_bodyparts) || ("waggingtail_human" in H.dna.species.mutant_bodyparts))
		. = null

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings."

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params)
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = user
		if(findtext(select_message_type(user), "open"))
			H.OpenWings()
		else
			H.CloseWings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if("wings" in H.dna.species.mutant_bodyparts)
		. = "opens " + message
	else
		. = "closes " + message

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species && (H.dna.features["wings"] != "None"))
		return TRUE

//Don't know where else to put this, it's basically an emote
/mob/living/carbon/human/proc/startTailWag()
	if(!dna || !dna.species)
		return
	if("tail_lizard" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "tail_lizard"
		dna.species.mutant_bodyparts -= "spines"
		dna.species.mutant_bodyparts |= "waggingtail_lizard"
		dna.species.mutant_bodyparts |= "waggingspines"
	if("tail_human" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "tail_human"
		dna.species.mutant_bodyparts |= "waggingtail_human"
	update_body()


/mob/living/carbon/human/proc/endTailWag()
	if(!dna || !dna.species)
		return
	if("waggingtail_lizard" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "waggingtail_lizard"
		dna.species.mutant_bodyparts -= "waggingspines"
		dna.species.mutant_bodyparts |= "tail_lizard"
		dna.species.mutant_bodyparts |= "spines"
	if("waggingtail_human" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "waggingtail_human"
		dna.species.mutant_bodyparts |= "tail_human"
	update_body()

/mob/living/carbon/human/proc/OpenWings()
	if(!dna || !dna.species)
		return
	if("wings" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "wings"
		dna.species.mutant_bodyparts |= "wingsopen"
	update_body()

/mob/living/carbon/human/proc/CloseWings()
	if(!dna || !dna.species)
		return
	if("wingsopen" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "wingsopen"
		dna.species.mutant_bodyparts |= "wings"
	update_body()

