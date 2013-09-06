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

	var/can_reenter_corpse = 1
	var/mob/current_host = null
	var/old_mind = null
	//var/cantalk = 1	//unused right now, intended for a mute verb

/mob/living/voices/New(mob/host, mob/body, title=null)
	if (!host)
		return			//voices need hosts
	loc = host
	current_host = host

	 //if there is a body transfer relevant stuff here, if not we're done
	if (!body)
		..()
	attack_log = body.attack_log	//preserve attack log
	gender = body.gender
	for(var/mob/living/voices/V in body.contents) //transfer voices as well (e.g. ling absorbing a ling gains his victims)
		V.transfer(host)
	old_mind = body.mind
	if (body.mind)				//take the name from the body's mind if there is one
		name = body.mind.name
	else
		name = body.name
	if (title)
		name = "[title] of [name]"
	real_name = name
	..()

/mob/proc/becomevoice(mob/host, title=null)
	var/mob/living/voices/newvoice = new(host, src,  title)
	if(key)
		newvoice.key = key
	return newvoice

/mob/living/voices/proc/transfer(mob/newhost)
	if (newhost && !istype(newhost, /mob/living/voices) ) //don't allow voices to have voices
		current_host = newhost
		loc = current_host
		if (client)
			client.eye = current_host
		return 1
	else
		return 0

/mob/living/voices/Del()
	ghostize(can_reenter_corpse, src.old_mind)
	src.current_host << "<span class='notice'>\The [src.real_name] fades away.</span>" // tell the host he ghosted
	..()

/mob/living/voices/ghost()	//a way for a voice to become a ghost
	set category = "OOC"
	set name = "Ghost"
	set desc = "Enter the land of the dead."

	del(src)
	return

/mob/living/voices/add_memory()
	set hidden = 1
	src << "\red Your mind is no longer your own!"
	return

/mob/living/voices/can_use_hands()	return 0
/mob/living/voices/is_active()		return 0

/proc/create_voice(host, mob/body, name) // use for admin buttons to set a new name
	if (body.mind)
		body.mind.name = name
	else
		body.name = name
	var/mob/living/voices/nv = body.becomevoice(host, null)
	nv.can_reenter_corpse = 0
	if (istype(body, /mob/dead/observer))
		body.Logout()
	return 1