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

/obj/structure/syndicate_uplink_beacon/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!user.mind?.has_antag_datum(/datum/antagonist/traitor))
		balloon_alert(user, "don't know how to use!")
		return
	if(!owner = null)
		balloon_alert(user, "already claimed!")
		return
	playsound(loc, "sound/machines/terminal_button0[rand(1, 8)].ogg", 40, TRUE)
	balloon_alert(user, "beginning synchronization...")
	if(!do_after(user, 3 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return
	probe_traitor(user)

/obj/structure/syndicate_uplink_beacon/proc/probe_traitor(mob/living/user)
	owner = WEAKREF(user)
	uplink_code = user.replacement_code
	traitor_frequency = user.traitor_frequency

	RegisterSignal(SSdcs, COMSIG_, PROC_REF(teleport_uplink))

/obj/structure/syndicate_uplink_beacon/proc/teleport_uplink()
	var/mob/living/resolved_owner = owner.resolve()
	if(!resolved_owner)
		return
	var/datum/uplink_handler/uplink_handler/ = owner.mind.uplink_handler

	new /obj/item/uplink/replacement (src, resolved_owner, 0, )

