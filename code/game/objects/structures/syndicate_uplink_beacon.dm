/// Device that traitors can craft in order to be sent a new, undisguised uplink
/obj/structure/syndicate_uplink_beacon
	name = "suspicious beacon"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster"
	desc = "This ramshackle device seems capable of recieving and sending signals for some odd purpose."
	/// Frequency given to traitor at start of round that the beacon is listening for their code word on
	var/traitor_frequency
	/// Traitor's code that they speak into the radio
	var/uplink_code
	/// weakref to person who is going to use the beacon to get a replacement uplink
	var/datum/weak_reference/owner

/obj/structure/syndicate_uplink_beacon/proc/probe_traitor(mob/living/user)
	owner = WEAKREF(user)
	uplink_code = user.replacement_code
	traitor_frequency = user.traitor_frequency

	RegisterSignal(SSdcs, COMSIG_, PROC_REF(teleport_uplink))

/obj/structure/syndicate_uplink_beacon/proc/teleport_uplink()
	var/mob/living/resolved_owner = owner.resolve()
	if(!resolved_owner)
		return

	new /obj/item/uplink/replacement (src, resolved_owner, 0, )

