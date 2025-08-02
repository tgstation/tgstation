///Special type of camera installed into silicons (drones included) that gives an alert when someone is watching them through cameras.
/obj/machinery/camera/silicon
	network = list(CAMERANET_NETWORK_SS13)
	internal_light = FALSE
	start_active = TRUE
	///Reference to the host (drone, silicon) that we're a host of.
	var/mob/living/living_host
	///Lazylist of sources watching the camera through consoles.
	var/list/sources_watching

/obj/machinery/camera/silicon/Initialize(mapload)
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL
	living_host = loc

/obj/machinery/camera/silicon/Destroy()
	if(!isnull(living_host))
		if(living_host.has_alert(ALERT_SILICON_RECORDING))
			living_host.clear_alert(ALERT_SILICON_RECORDING)
		living_host = null
	sources_watching = null
	return ..()

/obj/machinery/camera/silicon/on_start_watching(datum/source)
	LAZYADD(sources_watching, source)
	living_host.throw_alert(ALERT_SILICON_RECORDING, /atom/movable/screen/alert/being_recorded)

/obj/machinery/camera/silicon/on_stop_watching(datum/no_longer_watching)
	LAZYREMOVE(sources_watching, no_longer_watching)
	if(!LAZYLEN(sources_watching) && living_host.has_alert(ALERT_SILICON_RECORDING))
		living_host.clear_alert(ALERT_SILICON_RECORDING)

///The alert given to silicons being watched.
/atom/movable/screen/alert/being_recorded
	icon_state = "recording"
	name = "Recorded"
	desc = "Someone is currently watching your internal camera through a camera console."
