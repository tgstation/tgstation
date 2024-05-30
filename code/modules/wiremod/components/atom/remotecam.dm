#define REMOTECAM_RANGE_FAR 7
#define REMOTECAM_RANGE_NEAR 2
#define REMOTECAM_ENERGY_USAGE_NEAR 0.003 * STANDARD_CELL_CHARGE //Normal components have 0.001 * STANDARD_CELL_CHARGE, this is expensive to livestream footage
#define REMOTECAM_ENERGY_USAGE_FAR 0.008 * STANDARD_CELL_CHARGE //Far range vision should be expensive, crank this up 8 times
#define REMOTECAM_EMP_RESET 90 SECONDS

/**
 * # Remote Camera Component
 *
 * Attaches a camera for surveillance-on-the-go.
 */
/obj/item/circuit_component/remotecam
	display_name = "Camera Abstract Type"
	desc = "This is the abstract parent type - do not use this directly!"
	category = "Entity"
	circuit_flags = CIRCUIT_NO_DUPLICATES

	/// Starts the cameraa
	var/datum/port/input/start
	/// Stops the program.
	var/datum/port/input/stop
	/// Camera range flag (near/far)
	var/datum/port/input/camera_range
	/// The network to use
	var/datum/port/input/network
	/// The trigger for the true/false signals
	var/datum/port/input/checkcamera

	/// Signals sent on is active signal
	var/datum/port/output/true
	var/datum/port/output/false
	/// The result from the output
	var/datum/port/output/result

	/// Allow camera range to be set or not
	var/camera_range_settable = 1

	/// Camera object
	var/obj/machinery/camera/shell_camera = null
	/// The shell storing the parent circuit
	var/atom/movable/shell_parent = null
	/// The shell's type (used for prefix naming)
	var/shell_type = "Camera"
	/// Camera random ID
	var/c_tag_random = 0

	/// Used to store the current process state
	var/current_camera_state = FALSE
	/// Used to store the camera emp state
	var/current_camera_emp = FALSE
	/// Used to store the camera emp timer id
	var/current_camera_emp_timer_id
	/// Used to store the last string used for the camera name
	var/current_camera_name = ""
	/// Used to store the current camera range setting (near/far)
	var/current_camera_range = 0
	/// Used to store the last string used for the camera network
	var/current_camera_network = ""

/obj/item/circuit_component/remotecam/get_ui_notices()
	. = ..()
	if(camera_range_settable)
		. += create_ui_notice("Energy Usage For Near (0) Range: [display_energy(REMOTECAM_ENERGY_USAGE_NEAR)] Per [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")
		. += create_ui_notice("Energy Usage For Far (1) Range: [display_energy(REMOTECAM_ENERGY_USAGE_FAR)] Per [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")
	else
		. += create_ui_notice("Energy Usage While Active: [display_energy(current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR)] Per [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")

/obj/item/circuit_component/remotecam/populate_ports()
	start = add_input_port("Start", PORT_TYPE_SIGNAL)
	stop = add_input_port("Stop", PORT_TYPE_SIGNAL)
	if(camera_range_settable)
		camera_range = add_input_port("Camera Range", PORT_TYPE_NUMBER, default = 0)
	network = add_input_port("Network", PORT_TYPE_STRING, default = "ss13")
	checkcamera = add_input_port("Check Camera", PORT_TYPE_SIGNAL)

	true = add_output_port("On", PORT_TYPE_SIGNAL)
	false = add_output_port("Off", PORT_TYPE_SIGNAL)
	result = add_output_port("Result", PORT_TYPE_NUMBER)

	if(camera_range_settable)
		current_camera_range = camera_range.value
	c_tag_random = rand(1, 999)

/obj/item/circuit_component/remotecam/register_shell(atom/movable/shell)
	shell_parent = shell
	stop_process()

/obj/item/circuit_component/remotecam/unregister_shell(atom/movable/shell)
	stop_process()
	remove_camera()
	shell_parent = null

/obj/item/circuit_component/remotecam/Destroy()
	stop_process()
	remove_camera()
	shell_parent = null
	return ..()

/obj/item/circuit_component/remotecam/input_received(datum/port/input/port)
	var/refresh_output_ports = port != network && port != camera_range //Do not update output ports if changed network or camera range
	if(shell_parent && shell_camera)
		update_camera_name_network()
		if(COMPONENT_TRIGGERED_BY(start, port))
			start_process()
			current_camera_state = TRUE
		else if(COMPONENT_TRIGGERED_BY(stop, port))
			stop_process()
			close_camera() //Instantly turn off the camera
			current_camera_state = FALSE
	if(refresh_output_ports)
		var/logic_result = shell_camera ? current_camera_state : FALSE
		if(logic_result)
			true.set_output(COMPONENT_SIGNAL)
		else
			false.set_output(COMPONENT_SIGNAL)
		result.set_output(logic_result)

/**
 * Initializes the camera
 */
/obj/item/circuit_component/remotecam/proc/init_camera()
	shell_camera.desc = "This camera belongs in a circuit. If you see this, tell a coder!"
	shell_camera.AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)
	shell_camera.use_power = NO_POWER_USE
	shell_camera.start_active = TRUE
	shell_camera.internal_light = FALSE
	current_camera_name = ""
	if(camera_range_settable)
		current_camera_range = camera_range.value
	current_camera_emp = FALSE
	current_camera_network = ""
	close_camera()
	update_camera_range()
	update_camera_name_network()
	if(current_camera_state)
		start_process()
		update_camera_location()
	RegisterSignal(shell_parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
	RegisterSignal(shell_parent, COMSIG_ATOM_EMP_ACT, PROC_REF(set_camera_emp))

/**
 * Remove the camera
 */
/obj/item/circuit_component/remotecam/proc/remove_camera()
	if(shell_camera)
		UnregisterSignal(shell_parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_EMP_ACT))
		if(current_camera_emp)
			deltimer(current_camera_emp_timer_id)
			current_camera_emp = FALSE
		QDEL_NULL(shell_camera)

/**
 * Close the camera state (only if it's already active)
 */
/obj/item/circuit_component/remotecam/proc/close_camera()
	if(shell_camera?.camera_enabled)
		shell_camera.toggle_cam(null, 0)

/**
 * Set the camera range
 */
/obj/item/circuit_component/remotecam/proc/update_camera_range()
	shell_camera.setViewRange(current_camera_range > 0 ? REMOTECAM_RANGE_FAR : REMOTECAM_RANGE_NEAR)

/**
 * Updates the camera name and network
 */
/obj/item/circuit_component/remotecam/proc/update_camera_name_network()
	if(!parent || !parent.display_name || parent.display_name == "")
		shell_camera.c_tag = "[shell_type]: unspecified #[c_tag_random]"
		current_camera_name = ""
	else if(current_camera_name != parent.display_name)
		current_camera_name = parent.display_name
		var/new_cam_name = reject_bad_name(current_camera_name, allow_numbers = TRUE, ascii_only = FALSE, strict = TRUE, cap_after_symbols = FALSE)
		//Set camera name using parent circuit name
		if(new_cam_name)
			shell_camera.c_tag = "[shell_type]: [new_cam_name] #[c_tag_random]"
		else
			shell_camera.c_tag = "[shell_type]: unspecified #[c_tag_random]"

	if(!network.value || network.value == "")
		shell_camera.network = list("ss13")
		current_camera_network = ""
	else if(current_camera_network != network.value)
		current_camera_network = network.value
		var/new_net_name = LOWER_TEXT(sanitize(current_camera_network))
		//Set camera network string
		if(new_net_name)
			shell_camera.network = list("[new_net_name]")
		else
			shell_camera.network = list("ss13")

/**
 * Update the chunk for the camera (if enabled)
 */
/obj/item/circuit_component/remotecam/proc/update_camera_location(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	if(current_camera_state)
		GLOB.cameranet.updatePortableCamera(shell_camera, 0.5 SECONDS)

/**
 * Set the camera as emp'd
 */
/obj/item/circuit_component/remotecam/proc/set_camera_emp(datum/source, severity, protection)
	if(current_camera_emp)
		return
	if(!prob(150 / severity))
		return
	current_camera_emp = TRUE
	close_camera()
	current_camera_emp_timer_id = addtimer(CALLBACK(shell_camera, PROC_REF(post_emp_reset)), REMOTECAM_EMP_RESET, TIMER_STOPPABLE)
	for(var/mob/M as anything in GLOB.player_list)
		if (M.client?.eye == shell_camera)
			M.reset_perspective(null)
			to_chat(M, span_warning("The screen bursts into static!"))

/**
 * Restore emp'd camera
 */
/obj/item/circuit_component/remotecam/proc/post_emp_reset()
	current_camera_emp = FALSE

/**
 * Adds the component to the SSclock_component process list
 *
 * Starts draining cell per second while camera is active
 */
/obj/item/circuit_component/remotecam/proc/start_process()
	START_PROCESSING(SSclock_component, src)

/**
 * Removes the component to the SSclock_component process list
 *
 * Stops draining cell per second
 */
/obj/item/circuit_component/remotecam/proc/stop_process()
	STOP_PROCESSING(SSclock_component, src)

/obj/item/circuit_component/remotecam/bci
	display_name = "BCI Camera"
	desc = "Digitizes user's sight for surveillance-on-the-go. User must have fully functional eyes for digitizer to work. Camera range input is either 0 (near) or 1 (far). Network field is used for camera network."
	category = "BCI"

	shell_type = "BCI"
	required_shells = list(/obj/item/organ/internal/cyberimp/bci)

/obj/item/circuit_component/remotecam/drone
	display_name = "Drone Camera"
	desc = "Capture the surrounding sight for surveillance-on-the-go. Camera range input is either 0 (near) or 1 (far). Network field is used for camera network."

	shell_type = "Drone"
	required_shells = list(/mob/living/circuit_drone)

/obj/item/circuit_component/remotecam/airlock
	display_name = "Airlock Camera"
	desc = "A peephole camera that captures both sides of the airlock. Network field is used for camera network."

	shell_type = "Airlock"
	required_shells = list(/obj/machinery/door/airlock)

	camera_range_settable = 0

	current_camera_range = 0

/obj/item/circuit_component/remotecam/polaroid
	display_name = "Polaroid Camera Add-On"
	desc = "Relays a polaroid camera's feed as a digital stream for surveillance-on-the-go. Network field is used for camera network."

	shell_type = "Polaroid"
	required_shells = list(/obj/item/camera)

	camera_range_settable = 0

	current_camera_range = 0

/obj/item/circuit_component/remotecam/bci/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/internal/cyberimp/bci))
		shell_camera = new /obj/machinery/camera (shell_parent)
		init_camera()

/obj/item/circuit_component/remotecam/drone/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /mob/living/circuit_drone))
		shell_camera = new /obj/machinery/camera (shell_parent)
		init_camera()

/obj/item/circuit_component/remotecam/airlock/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/door/airlock))
		shell_camera = new /obj/machinery/camera (shell_parent)
		init_camera()

/obj/item/circuit_component/remotecam/polaroid/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/camera))
		shell_camera = new /obj/machinery/camera (shell_parent)
		init_camera()

/obj/item/circuit_component/remotecam/bci/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return
	//Camera is currently emp'd
	if (current_camera_emp)
		close_camera()
		return
	var/obj/item/organ/internal/cyberimp/bci/bci = shell_parent
	//If shell is not currently inside a head, or user is currently blind, or user is dead
	if(!bci.owner || bci.owner.is_blind() || bci.owner.stat >= UNCONSCIOUS)
		close_camera()
		return
	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	//If owner is nearsighted, set camera range to short (if it wasn't already)
	if(bci.owner.is_nearsighted_currently())
		if(current_camera_range)
			current_camera_range = 0
			update_camera_range()
	//Else if the camera range has changed, update camera range
	else if(!camera_range.value != !current_camera_range)
		current_camera_range = camera_range.value
		update_camera_range()
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.camera_enabled)
		shell_camera.toggle_cam(null, 0)

/obj/item/circuit_component/remotecam/drone/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return
	//Camera is currently emp'd
	if (current_camera_emp)
		close_camera()
		return
	var/mob/living/circuit_drone/drone = shell_parent
	//If shell is destroyed
	if(drone.health < 0)
		close_camera()
		return
	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	//If the camera range has changed, update camera range
	if(!camera_range.value != !current_camera_range)
		current_camera_range = camera_range.value
		update_camera_range()
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.camera_enabled)
		shell_camera.toggle_cam(null, 0)

/obj/item/circuit_component/remotecam/airlock/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return
	//Camera is currently emp'd
	if (current_camera_emp)
		close_camera()
		return
	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.camera_enabled)
		shell_camera.toggle_cam(null, 0)

/obj/item/circuit_component/remotecam/polaroid/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return
	//Camera is currently emp'd
	if (current_camera_emp)
		close_camera()
		return
	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.camera_enabled)
		shell_camera.toggle_cam(null, 0)

#undef REMOTECAM_RANGE_FAR
#undef REMOTECAM_RANGE_NEAR
#undef REMOTECAM_ENERGY_USAGE_NEAR
#undef REMOTECAM_ENERGY_USAGE_FAR
#undef REMOTECAM_EMP_RESET
