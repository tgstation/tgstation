#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = COLOR_SOFT_RED
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_SIGHT

	var/list/network = list(CAMERANET_NETWORK_SS13)
	var/obj/machinery/camera/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/atom/movable/screen/map_view/camera/cam_screen

/obj/machinery/computer/security/Initialize(mapload)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	var/map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += LOWER_TEXT(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.generate_view(map_name)

/obj/machinery/computer/security/Destroy()
	QDEL_NULL(cam_screen)
	return ..()

/obj/machinery/computer/security/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	for(var/i in network)
		network -= i
		network += "[port.shuttle_id]_[i]"

/obj/machinery/computer/security/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!user.client) //prevents errors by trying to pass clients that don't exist.
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal/terminal_on.ogg', 25, FALSE)
			use_energy(active_power_usage)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()
		// Register map objects
		cam_screen.display_to(user, ui.window)

/obj/machinery/computer/security/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			ref = REF(active_camera),
			status = active_camera.camera_enabled,
		)
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["network"] = network
	data["mapRef"] = cam_screen.assigned_map
	data["cameras"] = SScameras.get_available_cameras_data(network)
	return data

/obj/machinery/computer/security/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		active_camera?.on_stop_watching(src)
		var/obj/machinery/camera/selected_camera = locate(params["camera"]) in SScameras.cameras
		active_camera = selected_camera

		if(isnull(active_camera))
			return TRUE

		active_camera.on_start_watching(src)
		update_active_camera_screen()

		return TRUE

/obj/machinery/computer/security/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		cam_screen.show_camera_static()
		return

	var/list/visible_turfs = list()

	// Get the camera's turf to correctly gather what's visible from its turf, in case it's located in a moving object (borgs / mechs)
	var/new_cam_turf = get_turf(active_camera)

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	if(last_camera_turf == new_cam_turf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = new_cam_turf

	//Here we gather what's visible from the camera's POV based on its view_range and xray modifier if present
	var/list/visible_things = active_camera.isXRay(ignore_malf_upgrades = TRUE) ? range(active_camera.view_range, new_cam_turf) : view(active_camera.view_range, new_cam_turf)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	//Get coordinates for a rectangle area that contains the turfs we see so we can then clear away the static in the resulting rectangle area
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.show_camera(visible_turfs, size_x, size_y)

/obj/machinery/computer/security/ui_close(mob/user)
	. = ..()
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	cam_screen?.hide_from(user)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera?.on_stop_watching(src)
		active_camera = null
		last_camera_turf = null
		playsound(src, 'sound/machines/terminal/terminal_off.ogg', 25, FALSE)

/atom/movable/screen/map_view/camera
	/// All the plane masters that need to be applied.
	var/atom/movable/screen/background/cam_background

/atom/movable/screen/map_view/camera/Destroy()
	QDEL_NULL(cam_background)
	return ..()

/atom/movable/screen/map_view/camera/generate_view(map_key)
	. = ..()
	cam_background = new
	cam_background.del_on_map_removal = FALSE
	cam_background.assigned_map = assigned_map

/atom/movable/screen/map_view/camera/display_to_client(client/show_to)
	show_to.register_map_obj(cam_background)
	. = ..()

/atom/movable/screen/map_view/camera/proc/show_camera(list/visible_turfs, size_x, size_y)
	vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/atom/movable/screen/map_view/camera/proc/show_camera_static()
	vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// SECURITY MONITORS
/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	pass_flags = PASSTABLE

/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = "Used to access the various cameras on the outpost."
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list(CAMERANET_NETWORK_MINE, CAMERANET_NETWORK_AUXBASE)
	circuit = /obj/item/circuitboard/computer/mining

/obj/machinery/computer/security/research
	name = "research camera console"
	desc = "Used to access the various cameras in science."
	network = list(CAMERANET_NETWORK_RD)
	circuit = /obj/item/circuitboard/computer/research

/obj/machinery/computer/security/hos
	name = "\improper Head of Security's camera console"
	desc = "A custom security console with added access to the labor camp network."
	network = list(CAMERANET_NETWORK_SS13, CAMERANET_NETWORK_LABOR)
	circuit = null

/obj/machinery/computer/security/labor
	name = "labor camp monitoring"
	desc = "Used to access the various cameras on the labor camp."
	network = list(CAMERANET_NETWORK_LABOR)
	circuit = null

/obj/machinery/computer/security/qm
	name = "\improper Quartermaster's camera console"
	desc = "A console with access to the mining, auxiliary base and vault camera networks."
	network = list(CAMERANET_NETWORK_MINE, CAMERANET_NETWORK_AUXBASE, CAMERANET_NETWORK_VAULT)
	circuit = null

#undef DEFAULT_MAP_SIZE
