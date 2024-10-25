/datum/action/vehicle/sealed/kick_out
	name = "Kick Out"
	desc = "Kick someone out of this vehicle."
	button_icon = 'icons/mob/actions/actions_pod.dmi'
	button_icon_state = "kickout"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/vehicle/sealed/kick_out/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(HAS_TRAIT(owner, TRAIT_RESTRAINED))
		if (feedback)
			owner.balloon_alert(owner, "restrained!")
		return FALSE
	return TRUE

/datum/action/vehicle/sealed/kick_out/Trigger(trigger_flags)
	. = ..()
	var/list/occupants = vehicle_entered_target.occupants.Copy()
	occupants -= owner

	if(!length(occupants))
		vehicle_entered_target.balloon_alert(owner, "nobody else!")
		return
	var/mob/living/to_kick = length(occupants) == 1 ? occupants[1] : tgui_input_list(owner, "Kick whom?", "Kick whom?", occupants)
	if(!to_kick || to_kick.loc != vehicle_entered_target || owner.loc != vehicle_entered_target) //kicked out before them get lost buddy
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

/datum/action/cooldown/pod_comms_ping/New(Target, original, obj/item/pod_equipment/comms_array)
	. = ..()
	if(isnull(comms_array))
		qdel(src)
		return
	comms = comms_array
	pod = comms.pod
	RegisterSignal(comms, COMSIG_QDELETING, PROC_REF(anything_deleted))
	RegisterSignal(pod, COMSIG_QDELETING, PROC_REF(anything_deleted))

/datum/action/cooldown/pod_comms_ping/Activate(atom/target)
	. = ..()
	pod.balloon_alert_to_viewers("pinging comms!")
	playsound(pod.loc, 'sound/effects/ping_hit.ogg', vol = 50, vary = TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	for(var/obj/machinery/pod_comms_receiver/receiver in range(world.view, pod.loc))
		addtimer(CALLBACK(src, PROC_REF(after_ping), receiver), rand(0.8, 1.5) SECONDS) // no reason, i think its just cool

/datum/action/cooldown/pod_comms_ping/proc/after_ping(obj/machinery/pod_comms_receiver/receiver)
	if(QDELETED(pod) || QDELETED(comms) || QDELETED(receiver))
		return
	receiver.receive(pod, comms.accesses)

/datum/action/cooldown/pod_comms_ping/Destroy()
	pod = null
	comms = null
	return ..()

/datum/action/cooldown/pod_comms_ping/proc/anything_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/action/vehicle/sealed/spacepod_equipment
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	var/obj/item/pod_equipment/equipment

/datum/action/vehicle/sealed/spacepod_equipment/New(Target, equipment)
	. = ..()
	if(isnull(equipment))
		qdel(src)
		return
	src.equipment = equipment
	RegisterSignal(equipment, COMSIG_QDELETING, PROC_REF(anything_deleted))

/datum/action/vehicle/sealed/spacepod_equipment/Destroy()
	equipment = null
	return ..()

/datum/action/vehicle/sealed/spacepod_equipment/proc/anything_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/action/vehicle/sealed/spacepod_equipment/sensor_gps
	name = "Sensor Suite GPS"
	button_icon = /obj/item/gps::icon
	button_icon_state = /obj/item/gps/engineering::icon_state

/datum/action/vehicle/sealed/spacepod_equipment/sensor_gps/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/pod_equipment/sensors/sensors = equipment
	if(sensors.pod.use_power(10)) // a noble 10 probably just used to check if the UI is opened
		sensors.gps.ui_interact(owner)
		return
	SStgui.close_uis(sensors.gps)

