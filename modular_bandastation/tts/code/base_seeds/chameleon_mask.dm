/obj/item/clothing/mask/chameleon/equipped(mob/living/user, slot)
	. = ..()
	if(!istype(user))
		return
	if(slot_flags & slot)
		RegisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS, PROC_REF(mimic_voice))
	else
		UnregisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS)

/obj/item/clothing/mask/chameleon/dropped(mob/living/user)
	. = ..()
	if(!istype(user))
		return
	UnregisterSignal(user, COMSIG_TTS_COMPONENT_PRE_CAST_TTS)

/obj/item/clothing/mask/chameleon/proc/mimic_voice(mob/living/user, list/tts_args)
	SIGNAL_HANDLER
	if(tts_args[TTS_PRIORITY] >= TTS_PRIORITY_MASK)
		return
	if(!ishuman(user) || !(TRAIT_VOICE_MATCHES_ID in clothing_traits))
		return
	var/mob/living/carbon/human/mimicer = user
	if(!mimicer.wear_id)
		return
	var/obj/item/card/id/idcard = mimicer.wear_id.GetID()
	if(!istype(idcard))
		return
	var/datum/tts_seed/new_mimic_tts = GLOB.human_to_tts[idcard.registered_name]
	if(!new_mimic_tts)
		return
	tts_args[TTS_CAST_SEED] = new_mimic_tts
	tts_args[TTS_PRIORITY] = TTS_PRIORITY_MASK
