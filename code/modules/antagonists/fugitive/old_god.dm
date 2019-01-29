
/mob/camera/yalp_elor
	name = "Yalp Elor"
	real_name = "Yalp Elor"
	desc = "An old, dying god. It's power has been severely sapped ever since it has lost it's standing in the world."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "yalp_elor"
	invisibility = INVISIBILITY_OBSERVER
	call_life = TRUE
	var/lastWarning = 0
	var/given_acolytes = FALSE //so the life deletes yalp when it runs out of cultists
	var/list/the_faithful = list() //list of the other fugitives

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
				to_chat(src, "<span class='warning'>The Chapel is hallowed ground under a much, MUCH more powerful deity, and can't be accessed!</span>")
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
	to_chat(src, "<span class='cultitalic'><b>Yalp Elor:</b> \"[capitalize(message)]\"</span>")
	for(var/mob/living/L in the_faithful)
		to_chat(src, "<span class='cultitalic'><b>Yalp Elor:</b> \"[capitalize(message)]\"</span>")
//to_chat(minds.current, "<span class='cultitalic'><b>You feel words from Yalp Elor sink into your mind:</b> \"[capitalize(message)]\"</span>")
//use this for the transmit
/mob/camera/yalp_elor/Life()
	..()
	if(!the_faithful.len && !given_acolytes)
		return
	given_acolytes = TRUE
	var/safe = FALSE
	for(var/datum/mind/minds in the_faithful)
		if(minds.current && minds.current.stat != DEAD)
			safe = TRUE
	if(!safe)
		to_chat(src, "<span class='userdanger'>All of your followers are dead. That means you cease to exist.</span>")
		qdel(src)
