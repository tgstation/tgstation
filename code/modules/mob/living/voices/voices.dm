/mob/living/voices
	name = "voice"
	desc = "The voice of a deceased person."	//should not be needed
	layer = 4
	density = 0
	canmove = 0
	blinded = 0
	anchored = 1
	see_in_dark = 0
	mind = null

	var/fluff_title = "voice"			//what do you call these things in your specific context (e.g. for changelings: memory)
	var/current_host = null
	var/old_mind = null

/mob/living/voices/New(mob/body, mob/host, title)
	if (title)
		fluff_title = title
	stat = 0
	attack_log = body.attack_log	//preserve attack log
	gender = body.gender
	loc = host						//new voices go into the host
	if (!mind)
		name = body.name
	old_mind = body.mind
	name = body.mind.name
	real_name = name
	current_host = host

/mob/proc/becomevoice(mob/host, title)
	var/mob/living/voices/NP = new(src, host, title)
	if(key)
		NP.key = key
	return NP

/mob/living/voices/ghost()	//a way for a voice to become a ghost
	set category = "OOC"
	set name = "Ghost"
	set desc = "Enter the land of the dead."

	ghostize(1, src.old_mind)			//they can re-enter their original body
	src.current_host << "<span class='notice'>The [src.fluff_title] of [src.real_name] fades away.</span>" // tell the host he ghosted
	del(src)
	return

/mob/living/voices/add_memory()
	set hidden = 1
	src << "\red Your mind is no longer your own!"
	return

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0