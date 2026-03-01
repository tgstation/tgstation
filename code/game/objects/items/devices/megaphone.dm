/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "megaphone"
	inhand_icon_state = "megaphone"
	lefthand_file = 'icons/mob/inhands/items/megaphone_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/megaphone_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/spamcheck = 0
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/megaphone/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is uttering [user.p_their()] last words into \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	spamcheck = 0//so they dont have to worry about recharging
	user.say("AAAAAAAAAAAARGHHHHH", forced="megaphone suicide")//he must have died while coding this
	return OXYLOSS

/obj/item/megaphone/equipped(mob/equipper, slot)
	. = ..()
	if ((slot & ITEM_SLOT_HANDS))
		RegisterSignal(equipper, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		RegisterSignal(equipper, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(add_tts_filter))

/obj/item/megaphone/dropped(mob/dropper)
	. = ..()
	UnregisterSignal(dropper, list(COMSIG_MOB_SAY, COMSIG_LIVING_TREAT_MESSAGE))

/obj/item/megaphone/proc/handle_speech(mob/living/user, list/speech_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT(user, TRAIT_SIGN_LANG) || user.get_active_held_item() != src)
		return
	if(spamcheck > world.time)
		to_chat(user, span_warning("\The [src] needs to recharge!"))
	else
		playsound(loc, 'sound/items/megaphone.ogg', 100, FALSE, TRUE)
		speech_args[SPEECH_SPANS] |= voicespan

/obj/item/megaphone/proc/add_tts_filter(mob/living/carbon/user, list/message_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT(user, TRAIT_SIGN_LANG) || user.get_active_held_item() != src)
		return
	if(spamcheck > world.time)
		return
	spamcheck = world.time + 5 SECONDS
	if(obj_flags & EMAGGED)
		///somewhat compressed and ear-grating, crusty and noisy with a bit of echo.
		message_args[TREAT_TTS_FILTER_ARG] += "acrusher=samples=9:level_out=7,aecho=delays=100:decays=0.4,aemphasis=type=emi,crystalizer=i=6,acontrast=60,rubberband=pitch=0.9"
	else
		///A sharper and louder sound with a bit of echo
		message_args[TREAT_TTS_FILTER_ARG] += "acrusher=samples=2:level_out=6,aecho=delays=90:decays=0.3,aemphasis=type=cd,acontrast=30,crystalizer=i=5"

/obj/item/megaphone/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "voice synthesizer overloaded")
	obj_flags |= EMAGGED
	voicespan = list(SPAN_REALLYBIG, "userdanger")
	return TRUE

/obj/item/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"
	inhand_icon_state = "megaphone-sec"

/obj/item/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"
	inhand_icon_state = "megaphone-command"

/obj/item/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"
	inhand_icon_state = "megaphone-cargo"

/obj/item/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	inhand_icon_state = "megaphone-clown"
	voicespan = list(SPAN_CLOWN)
