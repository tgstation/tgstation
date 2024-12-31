/obj/effect/spawner/message_in_a_bottle
	name = "message in a bottle"
	desc = "Sending out an SOS"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "message_bottle"
	var/probability = 100

/obj/effect/spawner/message_in_a_bottle/Initialize(mapload)
	. = ..()
	if(!prob(probability))
		return INITIALIZE_HINT_QDEL
	if(!SSpersistence.initialized)
		RegisterSignal(SSpersistence, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_persistence_init))
	else
		SSpersistence.load_message_bottle(loc)
		return INITIALIZE_HINT_QDEL

/obj/effect/spawner/message_in_a_bottle/proc/on_persistence_init(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSpersistence, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	SSpersistence.load_message_bottle(loc)
	qdel(src)

/obj/effect/spawner/message_in_a_bottle/low_prob
	probability = 1.5
