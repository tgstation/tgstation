/datum/action/vehicle/sealed/kick_out
	name = "Kick Out"
	desc = "Kick someone out of this vehicle."
	button_icon = 'icons/mob/actions/actions_pod.dmi'
	button_icon_state = "kickout"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/vehicle/sealed/kick_out/Trigger(trigger_flags)
	. = ..()
	if(HAS_TRAIT(owner, TRAIT_RESTRAINED))
		return
	var/list/occupants = vehicle_entered_target.occupants.Copy()
	occupants -= occupant

	if(!length(occupants))
		vehicle_entered_target.balloon_alert(owner, "nobody else!")
		return
	var/mob/living/to_kick = length(occupants) == 1 ? occupants[1] : tgui_input_list(owner, "Kick whom?", "Kick whom?", occupants)
	if(!to_kick || owner.loc != vehicle_entered_target) //kicked out before them get lost buddy
		return
	to_kick.Knockdown(1 SECONDS)
	vehicle_entered_target.mob_exit(to_kick, randomstep = TRUE)

/datum/action/vehicle/sealed/climb_out/pod
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_eject" //spriting is hard ok

/datum/action/cooldown/pod_comms_ping
	name = "Ping Comms"
	desc = "Use your comms array to make all listening devices aware of your presence. Use this to enter or exit hangar bays you have access to."
	button_icon = 'icons/mob/actions/actions_pod.dmi'
	button_icon_state = "commsping"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 6 SECONDS
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	/// our pod
	var/obj/vehicle/sealed/pod
	/// the comms array we emit from
	var/obj/item/pod_equipment/comms/comms

/datum/action/cooldown/pod_comms_ping/Activate(atom/target)
	. = ..()
	if(QDELETED(pod) || QDELETED(comms))
		qdel(src)
		return
	pod.balloon_alert_to_viewers("pinging comms!")
	playsound(pod.loc, 'sound/effects/ping_hit.ogg', vol = 50, vary = TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	for(var/obj/machinery/pod_comms_receiver/receiver in range(world.view, pod.loc))
		addtimer(CALLBACK(src, PROC_REF(after_ping), receiver), rand(0.8, 1.5) SECONDS) // no reason, i think its just cool

/datum/action/cooldown/pod_comms_ping/proc/after_ping(obj/machinery/pod_comms_receiver/receiver)
	if(QDELETED(pod) || QDELETED(comms) || QDELETED(receiver))
		return
	receiver.receive(pod, comms.accesses)

/// generic equipment action, for the really simple actions
/datum/action/vehicle/sealed/spacepod_equipment
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	var/datum/callback/callback_on_click

/datum/action/vehicle/sealed/spacepod_equipment/Trigger(trigger_flags)
	. = ..()
	callback_on_click.Invoke(owner)

