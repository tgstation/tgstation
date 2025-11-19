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

	///The only person who can hear us is the one who activated us. Once activated a voice, only they can activate more.
	var/mob/living/hears_us
	/// Are we grabbing a spirit?
	var/using = FALSE
	///The mob that inhabits us, once posessed.
	var/list/mob/living/basic/tie/possessed_souls = list()

/obj/item/clothing/neck/tie/disco/Destroy()
	QDEL_LIST(possessed_souls)
	return ..()

/obj/item/clothing/neck/tie/disco/examine(mob/user)
	. = ..()
	if(!length(possessed_souls))
		. += span_notice("It may be given sentience by [EXAMINE_HINT("using it in hand")].")

/obj/item/clothing/neck/tie/disco/attack_self(mob/living/user, modifiers)
	if(using || (hears_us && (user != hears_us)))
		return ..()

	using = TRUE
	to_chat(user, span_notice("You plumb the depths of your Inland Empire. Whispers seem to emaninate from [src], as though it had somehow come to life; could it be?"))

	var/list/candidates = SSpolling.poll_ghost_candidates(
		question = "Do you want to play as the spirit of [span_danger("[user.real_name]'s")] [span_notice("horrific necktie")]?",
		check_jobban = ROLE_PAI,
		poll_time = 20 SECONDS,
		alert_pic = user,
		jump_target = user,
		ignore_category = POLL_IGNORE_HORRIFIC_NECKTIE,
	)
	if(!length(candidates))
		to_chat(user, span_warning("The whispers coming from [src] fade and are silent again... Was it all your imagination? Maybe you can try again later."))
		using = FALSE
		return
	hears_us = user
	while(!QDELETED(src) && length(candidates))
		var/mob/speaking_tie = candidates[1]
		var/mob/living/basic/tie/new_soul = new(src)
		new_soul.PossessByPlayer(speaking_tie.ckey)
		RegisterSignal(new_soul, COMSIG_LIVING_SEND_SPEECH, PROC_REF(on_speech_sent))
		RegisterSignal(new_soul, COMSIG_QDELETING, PROC_REF(on_deleting))
		possessed_souls += new_soul
		speaking_tie -= candidates[1]
	using = FALSE

///Called when a voice in the tie speaks, we use this to remove all listeners except the voices and creator.
/obj/item/clothing/neck/tie/disco/proc/on_speech_sent(atom/source, list/listeners)
	SIGNAL_HANDLER
	listeners.Cut()
	listeners += possessed_souls
	listeners += hears_us

///Called when one of our ghosts die (like from logging out/ghosting).
/obj/item/clothing/neck/tie/disco/proc/on_deleting(datum/source, force)
	SIGNAL_HANDLER
	possessed_souls -= source

///The mob that inhabits the tie when posessed.
/mob/living/basic/tie
	name = "horrific necktie"
	gender = NEUTER
	mob_biotypes = MOB_SPIRIT
	faction = list()
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0

/mob/living/basic/tie/Initialize(mapload)
	. = ..()
	GRANT_ACTION(/datum/action/innate/change_name)

/mob/living/basic/tie/Login()
	. = ..()
	to_chat(src, span_notice("You are the horrific necktie of the person who summoned you, \
		the only person who is able to hear you. Like a voice in their head, you are their reasoning, \
		their second-in-command. Take good care of them."))

/mob/living/basic/tie/Logout()
	. = ..()
	qdel(src)
