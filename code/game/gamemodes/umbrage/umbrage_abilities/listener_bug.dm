//Spawns a parasite in the host's brain cavity that listens to everything they say and relays it across the Mindlink.
/datum/action/innate/umbrage/listener_bug
	name = "Listener Bug"
	id = "listener_bug"
	desc = "Spawns a tiny parasite in the host's brain cavity that relays everything they say over the Mindlink."
	button_icon_state = "umbrage_listening_bug"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 10
	lucidity_cost = 1
	blacklisted = 0

/datum/action/innate/umbrage/listener_bug/IsAvailable()
	if(!owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/umbrage/listener_bug/Activate()
	owner.visible_message("<span class='warning'>A writhing violet bug suddenly grows out of [owner]'s hand!</span>", "<span class='velvet bold'>bnki iejz ejpk xaejc</span>\n\
	<span class='notice'>You prepare the spawn. Use it on a human from range, and it will enter their mind.</span>")
	playsound(owner, 'sound/effects/blobattack.ogg', 25, 1)
	var/obj/item/weapon/umbral_spawn/S = new
	owner.put_in_hands(S)
	S.linked_ability = src
	active = 1
	return TRUE

/datum/action/innate/umbrage/listener_bug/Deactivate()
	owner.visible_message("<span class='warning'>[owner]'s bug withers and dies!</span>", "<span class='velvet bold'>bnki xaejc ejpk iejz</span><br>\
	<span class='notice'>You reabsorb the spawn.</span>")
	for(var/obj/item/weapon/umbral_spawn/S in owner)
		qdel(S)
	active = 0
	return TRUE
