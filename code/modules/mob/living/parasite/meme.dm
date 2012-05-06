// === MEMETIC ANOMALY ===
// =======================

/**
This life form is a form of parasite that can gain a certain level of control
over its host. Its player will share vision and hearing with the host, and it'll
be able to influence the host through various commands.
**/


// === PARASITE ===
// ================

// a list of all the parasites in the mob
mob/living/carbon/var/list/parasites = list()

mob/living/parasite
	var
		mob/living/carbon/host // the host that this parasite occupies

	Login()
		..()

		// make the client see through the host instead
		client.eye = host
		client.perspective = EYE_PERSPECTIVE

mob/living/parasite/proc/enter_host(mob/living/carbon/host)
	// by default, parasites can't share a body with other life forms
	if(host.parasites.len > 0)
		return 0

	src.host = host

	if(client) client.eye = host

	return 1

mob/living/parasite/proc/exit_host()
	src.host.parasites.Remove(src)
	src.host = null

	return 1


// === MEME ===
// ============

// Memes use points for many actions
mob/living/parasite/meme/var/meme_points = 100

mob/living/parasite/meme/Life()
	..()
	// recover meme points slowly
	meme_points += 1

// When a meme speaks, it speaks through its host
mob/living/parasite/meme/say(message as text)
	world << "Trying to speak"
	if(!host)
		usr << "\red You can't speak without host!"
		return

	world << "[host] should now say [message]"

	host.say(message)
	usr = host
	return host.say(message)

mob/living/parasite/meme/whisper(message as text)
	if(!host)
		usr << "\red You can't speak without host!"
		return


	return host.whisper(message)

mob/living/parasite/meme/me_verb(message as text)
	set name = "Me"
	if(!host)
		usr << "\red You can't emote without host!"
		return

	return host.me_verb(message)

// A meme understands everything their host understands
mob/living/parasite/meme/say_understands(mob/other)
	if(!host) return 0

	return host.say_understands(other)


// TEST CODE
client/verb/become_meme(target as mob in world)
	var/mob/living/parasite/meme/M = new
	M.enter_host(target)
	src.mob = M
// END TEST CODE