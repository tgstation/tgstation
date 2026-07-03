// Used with pausable_bodycam, skips camera chunk addition on init, activates and updates when receiving a signal (observed from monitor)
/obj/machinery/camera/bodycam
	network = list(CAMERANET_NETWORK_SS13)
	internal_light = FALSE
	start_active = TRUE
	view_range = 3
	var/datum/component/pausable_bodycam/bodycam_component

/obj/machinery/camera/bodycam/Initialize(mapload)
	. = ..()
	SScameras.remove_camera_from_chunk(src)
	if(myarea)
		LAZYREMOVE(myarea.cameras, src)

/obj/machinery/camera/bodycam/on_start_watching(datum/source)
	bodycam_component?.on_watch_start(source)

/obj/machinery/camera/bodycam/on_stop_watching(datum/no_longer_watching)
	bodycam_component?.on_watch_stop(no_longer_watching)

/atom/movable/screen/alert/bodycam_viewed
	name = "Нательная камера активна"
	desc = "Через вашу камеру кто-то смотрит..."
	use_user_hud_icon = TRUE
	overlay_state = "recording"
