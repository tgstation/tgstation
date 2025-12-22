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

	/// Are we grabbing a spirit?
	var/using = FALSE
	///The only person who can hear us is the one who activated us. Once activated a voice, only they can activate more.
	var/datum/mind/hears_us
	///The mob that inhabits us, once posessed.
	var/list/mob/living/basic/tie/possessed_souls = list()

/obj/item/clothing/neck/tie/disco/Destroy()
	hears_us = null
	QDEL_LIST(possessed_souls)
	SSpoints_of_interest.remove_point_of_interest(src)
	LAZYREMOVE(GLOB.joinable_mobs[format_text("[initial(name)]")], src)
	return ..()

/obj/item/clothing/neck/tie/disco/examine(mob/user)
	. = ..()
	if(!length(possessed_souls))
		. += span_notice("It may be given sentience by [EXAMINE_HINT("using it in hand")].")

/obj/item/clothing/neck/tie/disco/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & slot_flags))
		return
	if(user.client && (isnull(hears_us) || user == hears_us))
		SSpoints_of_interest.make_point_of_interest(src)
		LAZYADD(GLOB.joinable_mobs[format_text("[initial(name)]")], src)

/obj/item/clothing/neck/tie/disco/dropped(mob/living/user)
	if(!QDELETED(src))
		SSpoints_of_interest.remove_point_of_interest(src)
		LAZYREMOVE(GLOB.joinable_mobs[format_text("[initial(name)]")], src)
	return ..()

/obj/item/clothing/neck/tie/disco/attack_self(mob/living/user, modifiers)
	if(using || (hears_us && (user.mind != hears_us)))
		return ..()

	using = TRUE
	to_chat(user, span_notice("You plumb the depths of your Inland Empire. Whispers seem to emaninate from [src], as though it had somehow come to life; could it be?"))

	var/list/candidates = SSpolling.poll_ghost_candidates(
		question = "Do you want to play as the spirit of [span_danger("[user.real_name]'s")] [span_notice("horrific necktie")]?",
		check_jobban = ROLE_PAI,
		poll_time = 20 SECONDS,
		alert_pic = user,
		jump_target = user,
		role_name_text = "Necktie of [user.real_name]",
		ignore_category = POLL_IGNORE_HORRIFIC_NECKTIE,
	)
	if(!length(candidates))
		to_chat(user, span_warning("The whispers coming from [src] fade and are silent again... Was it all your imagination? Maybe you can try again later."))
		using = FALSE
		return
	hears_us = user.mind
	while(!QDELETED(src) && length(candidates))
		var/mob/speaking_tie = candidates[1]
		create_ghost(speaking_tie)
		candidates -= candidates[1]
	using = FALSE

//this is also called by the spawners menu via `joinable_mobs`
/obj/item/clothing/neck/tie/disco/attack_ghost(mob/hopeful_ghost)
	. = ..()
	if (!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		to_chat(hopeful_ghost, span_warning("Ghost roles have been temporarily disabled!"))
		return
	if (!SSticker.HasRoundStarted())
		to_chat(hopeful_ghost, span_warning("You cannot assume control of this until after the round has started!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	became_player_controlled(hopeful_ghost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Called by `ghost_direct_control`, lets ghosts force themselves into the tie.
/obj/item/clothing/neck/tie/disco/proc/became_player_controlled(mob/suddenly_new_tie)
	if(isnull(hears_us))
		var/mob/living/worn_by = loc
		if(!ismob(worn_by))
			return
		hears_us = worn_by.mind
	create_ghost(suddenly_new_tie)

///Called when one of our ghosts die (like from logging out/ghosting).
/obj/item/clothing/neck/tie/disco/proc/on_deleting(datum/source, force)
	SIGNAL_HANDLER
	possessed_souls -= source
	to_chat(hears_us.current, span_notice("You feel like a voice just exited your mind."))

///Creates the ghost itself and adds them to the list of possessed souls in the tie.
/obj/item/clothing/neck/tie/disco/proc/create_ghost(mob/new_ghost)
	var/mob/living/basic/tie/new_soul = new(src)
	new_soul.PossessByPlayer(new_ghost.ckey)
	RegisterSignal(new_soul, COMSIG_LIVING_SEND_SPEECH, PROC_REF(on_speech_sent))
	RegisterSignal(new_soul, COMSIG_QDELETING, PROC_REF(on_deleting))
	possessed_souls += new_soul
	to_chat(hears_us.current, span_notice("You look down at [src] and feel like there's another thought process entering your mind."))

///Called when a voice in the tie speaks, we use this to remove all listeners except the voices and creator.
/obj/item/clothing/neck/tie/disco/proc/on_speech_sent(atom/source, list/listeners)
	SIGNAL_HANDLER
	listeners.Cut()
	listeners += possessed_souls
	listeners += hears_us.current

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
