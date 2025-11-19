/obj/item/clothing/neck/tie/disco
	name = "horrific necktie"
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "eldritch_tie"
	post_init_icon_state = null
	desc = "The necktie is adorned with a garish pattern. It's disturbingly vivid. Somehow you feel as if it would be wrong to ever take it off. It's your friend now. You will betray it if you change it for some boring scarf."
	clip_on = TRUE
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

	///The mob that inhabits us, once posessed.
	var/mob/living/basic/tie/possessed

/obj/item/clothing/neck/tie/disco/Destroy()
	QDEL_NULL(possessed)
	return ..()

/obj/item/clothing/neck/tie/disco/examine(mob/user)
	. = ..()
	if(isnull(possessed))
		. += span_notice("It may be given sentience by [EXAMINE_HINT("using it in hand")].")

/obj/item/clothing/neck/tie/disco/attack_self(mob/living/user, modifiers)
	if(!isnull(possessed))
		return ..()

	to_chat(user, span_notice("You plumb the depths of your Inland Empire. Whispers seem to emaninate from [src], as though it had somehow come to life; could it be?"))

	var/mob/speaking_tie = SSpolling.poll_ghosts_for_target(
		question = "Do you want to play as the spirit of [span_danger("[user.real_name]'s")] [span_notice("horrific necktie")]?",
		check_jobban = ROLE_PAI,
		poll_time = 20 SECONDS,
		checked_target = user,
		ignore_category = POLL_IGNORE_HORRIFIC_NECKTIE,
		alert_pic = user,
		role_name_text = "horrific necktie",
	)
	if(!QDELETED(src) && speaking_tie)
		possessed = new(src, user)
		possessed.PossessByPlayer(speaking_tie.ckey)
		return
	to_chat(user, span_warning("The whispers coming from [src] fade and are silent again... Was it all your imagination? Maybe you can try again later."))

///The mob that inhabits the tie when posessed.
/mob/living/basic/tie
	name = "horrific necktie"
	gender = NEUTER
	mob_biotypes = MOB_SPIRIT
	faction = list()

	///The only person who can hear us is the one who activated us, set by the tie item.
	var/mob/living/hears_us
	///Innate ability for the tie to change its name constantly, in case they want to play several voices at once.
	var/datum/action/innate/change_name/name_change

/mob/living/basic/tie/Initialize(mapload, mob/living/hears_us)
	. = ..()
	src.hears_us = hears_us
	name_change = new(src)
	name_change.Grant(src)
	RegisterSignal(src, COMSIG_LIVING_SEND_SPEECH, PROC_REF(on_speech_sent))

/mob/living/basic/tie/Destroy(force)
	hears_us = null
	QDEL_NULL(name_change)
	return ..()

/mob/living/basic/tie/Login()
	. = ..()
	to_chat(src, span_notice("You are the horrific necktie of [hears_us.real_name], \
		the only person who is able to hear you. Like a voice in their head, you are their reasoning, \
		their second-in-command. Take good care of [hears_us.real_name]."))

///Called when we speak, we use this to remove all listeners except ourselves and our creator.
/mob/living/basic/tie/proc/on_speech_sent(atom/source, list/listeners)
	SIGNAL_HANDLER

	listeners.Cut()
	listeners += src
	listeners += hears_us

/datum/action/innate/change_name
	name = "Change Name"
	button_icon_state = "ghost"

/datum/action/innate/change_name/Activate()
	var/new_name = tgui_input_text(usr, "Enter a new name.", "Renaming", initial(owner.name))
	if(!new_name)
		return FALSE

	owner.fully_replace_character_name(owner.name, new_name)
	return TRUE
