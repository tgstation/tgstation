#define DEFAULT_MAP_SIZE 15

/datum/computer_file/program/secureye
	filename = "secureye"
	filedesc = "SecurEye"
	downloader_category = PROGRAM_CATEGORY_SECURITY
	ui_header = "borg_mon.gif"
	program_open_overlay = "generic"
	extended_desc = "This program allows access to standard security camera networks."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	download_access = list(ACCESS_SECURITY)
	can_run_on_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	size = 5
	tgui_id = "NtosSecurEye"
	program_icon = "eye"
	always_update_ui = TRUE

	///Boolean on whether or not the app will make noise when flipping around the channels.
	var/spying = FALSE

	var/list/network = list(CAMERANET_NETWORK_SS13)
	///List of weakrefs of all users watching the program.
	var/list/concurrent_users = list()

	/// Weakref to the active camera
	var/datum/weakref/camera_ref
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf

	// Stuff needed to render the map
	var/atom/movable/screen/map_view/camera/cam_screen

	///Internal tracker used to find a specific person and keep them on cameras, only used if this is a 'spying' console.
	var/datum/trackable/internal_tracker

///Syndicate subtype that has no access restrictions and is available on Syndinet
/datum/computer_file/program/secureye/syndicate
	filename = "syndeye"
	filedesc = "SyndEye"
	extended_desc = "This program allows for illegal access to security camera networks."
	download_access = list()
	can_run_on_flags = PROGRAM_ALL
	program_flags = PROGRAM_ON_SYNDINET_STORE | PROGRAM_UNIQUE_COPY

	network = list(
		CAMERANET_NETWORK_SS13,
		CAMERANET_NETWORK_MINE,
		CAMERANET_NETWORK_RD,
		CAMERANET_NETWORK_LABOR,
		CAMERANET_NETWORK_ORDNANCE,
		CAMERANET_NETWORK_MINISAT,
	)
	spying = TRUE

///Human AI subtype that has access to most networks on the station and can't be copied.
/datum/computer_file/program/secureye/human_ai
	filename = "Overseer"
	filedesc = "OverSeer"
	run_access = list(ACCESS_MINISAT)
	can_run_on_flags = PROGRAM_PDA
	program_flags = PROGRAM_UNIQUE_COPY
	network = list(
		CAMERANET_NETWORK_SS13,
		CAMERANET_NETWORK_MINE,
		CAMERANET_NETWORK_RD,
		CAMERANET_NETWORK_LABOR,
		CAMERANET_NETWORK_ORDNANCE,
		CAMERANET_NETWORK_MINISAT,
	)
	spying = TRUE

/datum/computer_file/program/secureye/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	var/map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += LOWER_TEXT(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.generate_view(map_name)

/datum/computer_file/program/secureye/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(internal_tracker)
	last_camera_turf = null
	return ..()

/datum/computer_file/program/secureye/kill_program(mob/user)
	if(user)
		ui_close(user)
	return ..()

/datum/computer_file/program/secureye/ui_interact(mob/user, datum/tgui/ui)
	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Ghosts shouldn't count towards concurrent users, which produces
	// an audible terminal_on click.
	if(is_living)
		concurrent_users += user_ref
	// Register map objects
	cam_screen.display_to(user, ui.window)

/datum/computer_file/program/secureye/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/datum/computer_file/program/secureye/ui_data()
	var/list/data = list()
	data["activeCamera"] = null
	var/obj/machinery/camera/active_camera = camera_ref?.resolve()
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			ref = REF(active_camera),
			status = active_camera.camera_enabled,
		)
	return data

/datum/computer_file/program/secureye/ui_static_data(mob/user)
	var/list/data = list()
	data["network"] = network
	data["mapRef"] = cam_screen.assigned_map
	data["can_spy"] = !!spying
	data["cameras"] = SScameras.get_available_cameras_data(network)
	return data

/datum/computer_file/program/secureye/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("switch_camera")
			var/obj/machinery/camera/active_camera = camera_ref?.resolve()
			if(!spying && active_camera)
				active_camera.on_stop_watching(src)

			if(!spying)
				playsound(computer, SFX_TERMINAL_TYPE, 25, FALSE)

			var/obj/machinery/camera/selected_camera = locate(params["camera"]) in SScameras.cameras
			if(selected_camera)
				camera_ref = WEAKREF(selected_camera)
			else
				camera_ref = null
				return TRUE
			if(!spying)
				selected_camera.on_start_watching(src)
			if(internal_tracker)
				internal_tracker.reset_tracking()

			update_active_camera_screen()
			return TRUE

		if("start_tracking")
			if(!internal_tracker)
				internal_tracker = new(src)
				RegisterSignal(internal_tracker, COMSIG_TRACKABLE_TRACKING_TARGET, PROC_REF(on_track_target))
			internal_tracker.track_input(usr)
			return TRUE

/datum/computer_file/program/secureye/proc/on_track_target(datum/trackable/source, mob/living/target)
	SIGNAL_HANDLER
	var/target_turf = get_turf(target)
	var/datum/camerachunk/target_camerachunk = SScameras.get_turf_camera_chunk(target_turf)
	if(!target_camerachunk)
		CRASH("[src] was able to track [target] through /datum/trackable, but was not on a visible turf to cameras.")
	for(var/obj/machinery/camera/cameras as anything in target_camerachunk.cameras[target.z])
		// We need to find a particular camera that can see this turf
		if(!(target_turf in cameras.can_see()))
			continue
		var/new_camera = WEAKREF(cameras)
		if(camera_ref == new_camera)
			return
		camera_ref = new_camera
		update_active_camera_screen()
		return

/datum/computer_file/program/secureye/ui_close(mob/user)
	. = ..()
	//don't track anyone while we're shutting off.
	if(internal_tracker)
		internal_tracker.reset_tracking()
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	cam_screen.hide_from(user)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		var/obj/machinery/camera/active_camera = camera_ref?.resolve()
		if(!spying && active_camera)
			active_camera.on_stop_watching(src)
		camera_ref = null
		last_camera_turf = null
		if(!spying)
			playsound(computer, 'sound/machines/terminal/terminal_off.ogg', 25, FALSE)

/datum/computer_file/program/secureye/proc/update_active_camera_screen()
	var/obj/machinery/camera/active_camera = camera_ref?.resolve()
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

#undef DEFAULT_MAP_SIZE
