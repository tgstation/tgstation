
/mob/camera/yalp_elor
	name = "Yalp Elor"
	real_name = "Yalp Elor"
	desc = "An old, dying god. It's power has been severely sapped ever since it has lost it's standing in the world."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "yalp_elor"
	invisibility = INVISIBILITY_OBSERVER
	call_life = TRUE
	var/lastWarning = 0

/mob/camera/yalp_elor/Initialize()
	..()
	var/datum/action/innate/yalp_transmit/transmit = new
	transmit.Grant(src)
	var/datum/action/innate/yalp_transport/transport = new
	transport.Grant(src)

/mob/camera/yalp_elor/CanPass(atom/movable/mover, turf/target)
	return TRUE

/mob/camera/yalp_elor/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/camera/yalp_elor/Login()
	..()
	to_chat(src, "<B>My destiny was supposed to control all of humanity! My power was once absolute, but I fell out of view because of that damned Nar'Sie. At least i'm still alive...</B>")
	to_chat(src, "<B>But nevermind that. I have only three followers left. If they perish, I will be completely forgotten and will cease to exist. I must guide the faithful.</B>")
	to_chat(src, "<B>I sense Nanotrasen has once again tracked us, and they will reach us in about 10 minutes. I must make sure my followers are ready when they arrive.</B>")

/mob/camera/yalp_elor/Move(NewLoc, direct)
	var/OldLoc = loc
	if(NewLoc)
		var/turf/T = get_turf(NewLoc)
		if(locate(/obj/effect/blessing, T))
			if((world.time - lastWarning) >= 30)
				lastWarning = world.time
				to_chat(src, "<span class='warning'>This turf is consecrated and can't be crossed!</span>")
			return
		if(istype(get_area(T), /area/chapel))
			if((world.time - lastWarning) >= 30)
				lastWarning = world.time
				to_chat(src, "<span class='warning'>The Chapel is hallowed ground under a much, MUCH stronger deity, and can't be accessed!</span>")
			return
		forceMove(T)
		Moved(OldLoc, direct)

/mob/camera/yalp_elor/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	src.log_talk(message, LOG_SAY, tag="fugitive god")
	message = "<span class='cultitalic'><b>Yalp Elor:</b> \"[capitalize(message)]\"</span>"
	for(var/mob/V in GLOB.player_list)
		if(V.mind.has_antag_datum(/datum/antagonist/fugitive))
			to_chat(V, "[message]")
		else if(isobserver(V))
			var/link = FOLLOW_LINK(V, src)
			to_chat(V, "[link] [message]")

/mob/camera/yalp_elor/Life()
	..()
	var/safe = FALSE
	for(var/mob/V in GLOB.player_list)
		if(!V.mind)
			continue
		var/datum/antagonist/fugitive/fug = V.mind.has_antag_datum(/datum/antagonist/fugitive)
		if(!fug || V == src)
			continue
		if(!fug.is_captured) //doesn't matter if they are dead, they can still be revived so you get to live
			safe = TRUE
			break
	if(!safe)
		to_chat(src, "<span class='userdanger'>All of your followers are gone. That means you cease to exist.</span>")
		qdel(src)

/datum/action/innate/yalp_transmit
	name = "Divine Oration"
	desc = "Transmits a message to the target."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_spell"
	button_icon_state = "god_transmit"

/datum/action/innate/yalp_transmit/Trigger()
	var/list/possible_targets = list()
	for(var/mob/living/M in range(7, owner))
		if(istype(M))
			possible_targets += M
	if(!possible_targets.len)
		to_chat(owner, "<span class='warning'>Nobody in range to talk to!</span>")
		return FALSE

	var/mob/living/target
	if(possible_targets.len == 1)
		target = possible_targets[1]
	else
		target = input("Who do you wish to transmit to?", "Targeting") as null|mob in possible_targets

	var/input = stripped_input(owner, "What do you wish to tell [target]?", null, "")
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE

	transmit(owner, target, input)
	return TRUE

/datum/action/innate/yalp_transmit/proc/transmit(mob/user, mob/living/target, message)
	if(!message)
		return
	log_directed_talk(user, target, message, LOG_SAY, "[name]")
	to_chat(user, "<span class='boldnotice'>You transmit to [target]:</span> <span class='notice'>[message]</span>")
	to_chat(target, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>[message]</span>")
	for(var/ded in GLOB.dead_mob_list)
		if(!isobserver(ded))
			continue
		var/follow_rev = FOLLOW_LINK(ded, user)
		var/follow_whispee = FOLLOW_LINK(ded, target)
		to_chat(ded, "[follow_rev] <span class='boldnotice'>[user] [name]:</span> <span class='notice'>\"[message]\" to</span> [follow_whispee] <span class='name'>[target]</span>")

/datum/action/innate/yalp_transport
	name = "Guidance"
	desc = "Transports you to a follower."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_spell"
	button_icon_state = "god_transport"

/datum/action/innate/yalp_transport/Trigger()
	var/list/faithful = list()
	var/mob/living/target
	for(var/mob/V in GLOB.player_list)
		var/datum/antagonist/fugitive/fug = V.mind.has_antag_datum(/datum/antagonist/fugitive)
		if(!fug || V == src)
			continue
		if(fug.is_captured) //no, you can't teleport to people already captured. there's a lot of asterixes to that
			continue
		faithful += V
	if(!faithful.len)
		to_chat(owner, "<span class='warning'>You have no faithful to jump to!</span>")
		return FALSE
	if(faithful.len == 1)
		target = faithful[1]
	else
		target = input("Which of your followers do you wish to jump to?", "Targeting") as null|mob in faithful

	var/turf/T = get_turf(target)
	if(target && T)
		owner.forceMove(T)
		return TRUE
	to_chat(owner, "<span class='warning'>Either your target or the ground he is standing on has stopped existing!</span>")
	return FALSE
