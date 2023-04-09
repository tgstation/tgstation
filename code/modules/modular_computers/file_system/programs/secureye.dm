#define DEFAULT_MAP_SIZE 15

/datum/computer_file/program/secureye
	filename = "secureye"
	filedesc = "SecurEye"
	category = PROGRAM_CATEGORY_MISC
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "This program allows access to standard security camera networks."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_SECURITY)
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	size = 5
	tgui_id = "NtosSecurEye"
	program_icon = "eye"

	var/list/network = list("ss13")
	/// Weakref to the active camera
	var/datum/weakref/camera_ref
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/atom/movable/screen/map_view/cam_screen
	var/atom/movable/screen/background/cam_background

/datum/computer_file/program/secureye/New()
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	var/map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.generate_view(map_name)
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/datum/computer_file/program/secureye/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_NULL(cam_background)
	return ..()

/datum/computer_file/program/secureye/ui_interact(mob/user, datum/tgui/ui)
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
		// Register map objects
		cam_screen.display_to(user)
		user.client.register_map_obj(cam_background)
		return ..()

/datum/computer_file/program/secureye/ui_status(mob/user)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/datum/computer_file/program/secureye/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	var/obj/machinery/camera/active_camera = camera_ref?.resolve()
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/datum/computer_file/program/secureye/ui_static_data()
	var/list/data = list()
	data["mapRef"] = cam_screen.assigned_map
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))

	return data

/datum/computer_file/program/secureye/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "switch_camera")
		var/c_tag = format_text(params["name"])
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/selected_camera = cameras[c_tag]
		camera_ref = WEAKREF(selected_camera)
		playsound(src, get_sfx(SFX_TERMINAL_TYPE), 25, FALSE)

		if(!selected_camera)
			return TRUE

		update_active_camera_screen()

		return TRUE

/datum/computer_file/program/secureye/ui_close(mob/user)
	. = ..()
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	cam_screen.hide_from(user)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		camera_ref = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

/datum/computer_file/program/secureye/proc/update_active_camera_screen()
	var/obj/machinery/camera/active_camera = camera_ref?.resolve()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Get the camera's turf to correctly gather what's visible from it's turf, in case it's located in a moving object (borgs / mechs)
	var/new_cam_turf = get_turf(active_camera)

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	if(last_camera_turf == new_cam_turf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = new_cam_turf

	//Here we gather what's visible from the camera's POV based on its view_range and xray modifier if present
	var/list/visible_things = active_camera.isXRay() ? range(active_camera.view_range, new_cam_turf) : view(active_camera.view_range, new_cam_turf)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	//Get coordinates for a rectangle area that contains the turfs we see so we can then clear away the static in the resulting rectangle area
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/datum/computer_file/program/secureye/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// Returns the list of cameras accessible from this computer
/datum/computer_file/program/secureye/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/cam as anything in GLOB.cameranet.cameras)
		//Get the camera's turf in case it's inside something like a borg
		var/turf/camera_turf = get_turf(cam)
		if(!is_station_level(camera_turf.z))//Only show station cameras.
			continue
		L.Add(cam)
	var/list/camlist = list()
	for(var/obj/machinery/camera/cam in L)
		if(!cam.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(cam.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = cam.network & network
		if(tempnetwork.len)
			camlist["[cam.c_tag]"] = cam
	return camlist
