#define COOLDOWN_TIME 10

/obj/machinery/door/airlock
	doorClose = 'sound/machines/airlock.ogg'
	doorDeni = 'hippiestation/sound/machine/denied.ogg'
	var/request_cooldown = 0 //To prevent spamming requests for the AI to open

/obj/machinery/door/airlock/clown
	doorClose = 'sound/items/bikehorn.ogg'

/obj/machinery/door/airlock/AltClick(mob/living/user)
	if(isobserver(user))
		to_chat(user, "<span class='danger'>Psst, you can't interact with the world, ghosts!</span>")
		return

	if (!user.canUseTopic(src))
		to_chat(user, "<span class='info'>You can't do this right now!</span>")
		return

	if(stat & (NOPOWER|BROKEN) || emagged)
		to_chat(user, "<span class='info'>The door isn't working!</span>")
		return

	if(request_cooldown > world.time)
		to_chat(user, "<span class='info'>The airlock's spam filter is blocking your request. Please wait at least 10 seconds between requests.</span>")
		return

	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(!AI.client)
			continue
		to_chat(AI, "<span class='info'><a href='?src=[REF(AI)];track=[html_encode(user.name)]'><span class='name'>[user.name] ([user.GetJob()])</span></a> is requesting you to open [src]<a href='?src=[REF(AI)];remotedoor=[REF(src)]'>(Open)</a></span>")
	request_cooldown = world.time + (COOLDOWN_TIME * 10)
	to_chat(user, "<span class='info'>Request sent.</span>")
