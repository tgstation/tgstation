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

	/// Allow camera range to be set or not
	var/camera_range_settable = TRUE
	/// Used only for the BCI shell type, as the COMSIG_MOVABLE_MOVED signal need to be assigned to the user mob, not the shell circuit
	var/camera_signal_move_override = FALSE

	/// Camera object
	var/obj/machinery/camera/shell_camera = null
	/// The shell storing the parent circuit
	var/atom/movable/shell_parent = null
	/// The shell's type (used for prefix naming)
	var/camera_prefix = "Camera"
	/// Camera random ID
	var/c_tag_random = 0

	/// Used to store the current process state
	var/current_camera_state = FALSE
	/// Used to store the current cameranet state
	var/current_cameranet_state = TRUE
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
	if(!shell_parent || !shell_camera)
		return
	update_camera_name_network()
	if(COMPONENT_TRIGGERED_BY(start, port))
		start_process()
		cameranet_add()
		current_camera_state = TRUE
	else if(COMPONENT_TRIGGERED_BY(stop, port))
		stop_process()
		close_camera() //Instantly turn off the camera
		current_camera_state = FALSE

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
	current_cameranet_state = TRUE
	current_camera_emp = FALSE
	current_camera_network = ""
	close_camera()
	update_camera_range()
	update_camera_name_network()
	if(current_camera_state)
		start_process()
		update_camera_location()
	else
		cameranet_remove() //Remove camera from global cameranet until user activates the camera first
	if(!camera_signal_move_override)
		RegisterSignal(shell_parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
	RegisterSignal(shell_parent, COMSIG_ATOM_EMP_ACT, PROC_REF(set_camera_emp))

/**
 * Remove the camera
 */
/obj/item/circuit_component/remotecam/proc/remove_camera()
	if(!shell_camera)
		return
	if(!camera_signal_move_override)
		UnregisterSignal(shell_parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(shell_parent, COMSIG_ATOM_EMP_ACT)
	if(current_camera_emp)
		deltimer(current_camera_emp_timer_id)
		current_camera_emp = FALSE
	cameranet_add() //Readd camera to cameranet before deleting camera
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
		shell_camera.c_tag = "[camera_prefix]: unspecified #[c_tag_random]"
		current_camera_name = ""
	else if(current_camera_name != parent.display_name)
		current_camera_name = parent.display_name
		var/new_cam_name = reject_bad_name(current_camera_name, allow_numbers = TRUE, ascii_only = FALSE, strict = TRUE, cap_after_symbols = FALSE)
		//Set camera name using parent circuit name
		if(new_cam_name)
			shell_camera.c_tag = "[camera_prefix]: [new_cam_name] #[c_tag_random]"
		else
			shell_camera.c_tag = "[camera_prefix]: unspecified #[c_tag_random]"

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
	if(current_camera_state && current_cameranet_state)
		GLOB.cameranet.updatePortableCamera(shell_camera, 0.5 SECONDS)

/**
 * Add camera from global cameranet
 */
/obj/item/circuit_component/remotecam/proc/cameranet_add()
	if(current_cameranet_state)
		return
	GLOB.cameranet.cameras += shell_camera
	GLOB.cameranet.addCamera(shell_camera)
	current_cameranet_state = TRUE

/**
 * Remove camera from global cameranet
 */
/obj/item/circuit_component/remotecam/proc/cameranet_remove()
	if(!current_cameranet_state)
		return
	GLOB.cameranet.removeCamera(shell_camera)
	GLOB.cameranet.cameras -= shell_camera
	current_cameranet_state = FALSE

/**
 * Set the camera as emp'd
 */
/obj/item/circuit_component/remotecam/proc/set_camera_emp(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(current_camera_emp)
		return
	if(!prob(150 / severity))
		return
	current_camera_emp = TRUE
	close_camera()
	current_camera_emp_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_camera_emp)), REMOTECAM_EMP_RESET, TIMER_STOPPABLE)
	for(var/mob/M as anything in GLOB.player_list)
		if (M.client?.eye == shell_camera)
			M.reset_perspective(null)
			to_chat(M, span_warning("The screen bursts into static!"))

/**
 * Restore emp'd camera
 */
/obj/item/circuit_component/remotecam/proc/remove_camera_emp()
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

/**
 * Handle power usage and camera state updating
 *
 * This is the generic abstract proc - subtypes with specialized logic should use their own copy of process()
 */
/obj/item/circuit_component/remotecam/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return PROCESS_KILL
	//Camera is currently emp'd
	if (current_camera_emp)
		close_camera()
		return
	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	if(camera_range_settable)
		//If the camera range has changed, update camera range
		if(!camera_range.value != !current_camera_range)
			current_camera_range = camera_range.value
			update_camera_range()
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.camera_enabled)
		shell_camera.toggle_cam(null, 0)

/obj/item/circuit_component/remotecam/bci
	display_name = "BCI Camera"
	desc = "Digitizes user's sight for surveillance-on-the-go. User must have fully functional eyes for digitizer to work. Camera range input is either 0 (near) or 1 (far). Network field is used for camera network."
	category = "BCI"
	camera_prefix = "BCI"
	required_shells = list(/obj/item/organ/internal/cyberimp/bci)

	/// BCIs are organs, and thus the signal must be assigned ONLY when the shell has been installed in a mob - otherwise the camera will never update position
	camera_signal_move_override = TRUE

	/// Store the BCI owner as a variable, so we can remove the move signal if the user was gibbed/destroyed while the BCI is still installed
	var/mob/living/carbon/bciuser = null

/obj/item/circuit_component/remotecam/drone
	display_name = "Remote Camera"
	desc = "Capture the surrounding environment for surveillance-on-the-go. Camera range input is either 0 (near) or 1 (far). Network field is used for camera network."
	camera_prefix = "Drone"

/obj/item/circuit_component/remotecam/airlock
	display_name = "Peephole Camera"
	desc = "A peephole camera that captures both sides of the airlock. Network field is used for camera network."
	camera_prefix = "Airlock"

	/// Hardcode camera to near range
	camera_range_settable = FALSE
	current_camera_range = 0

/obj/item/circuit_component/remotecam/polaroid
	display_name = "Camera Stream Add-On"
	desc = "Relays a polaroid camera's feed as a digital stream for surveillance-on-the-go. The camera stream will not work if stored inside of a container like a backpack/box. Network field is used for camera network."
	camera_prefix = "Polaroid"

	/// Hardcode camera to near range
	camera_range_settable = FALSE
	current_camera_range = 0

/obj/item/circuit_component/remotecam/bci/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell_parent, /obj/item/organ/internal/cyberimp/bci))
		return
	shell_camera = new /obj/machinery/camera (shell_parent)
	init_camera()
	RegisterSignal(shell_parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	RegisterSignal(shell_parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	var/obj/item/organ/internal/cyberimp/bci/bci = shell_parent
	if(bci.owner) //If somehow the camera was added while shell is already installed inside a mob, assign signals
		if(bciuser) //This should never happen... But if it does, unassign move signal from old mob
			UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
		bciuser = bci.owner
		RegisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

/obj/item/circuit_component/remotecam/bci/unregister_shell(atom/movable/shell)
	if(shell_camera)
		if(bciuser)
			UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
			bciuser = null
		UnregisterSignal(shell_parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	return ..()

/obj/item/circuit_component/remotecam/bci/Destroy()
	if(shell_camera)
		if(bciuser)
			UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
			bciuser = null
		UnregisterSignal(shell_parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	return ..()

/obj/item/circuit_component/remotecam/bci/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	if(bciuser)
		return
	bciuser = owner
	RegisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

/obj/item/circuit_component/remotecam/bci/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	if(!bciuser)
		return
	UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
	bciuser = null

/obj/item/circuit_component/remotecam/drone/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell_parent, /mob/living/circuit_drone))
		return
	current_camera_state = FALSE //Always reset camera state for built-in shell components
	shell_camera = new /obj/machinery/camera (shell_parent)
	init_camera()

/obj/item/circuit_component/remotecam/airlock/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell_parent, /obj/machinery/door/airlock))
		return
	current_camera_state = FALSE //Always reset camera state for built-in shell components
	shell_camera = new /obj/machinery/camera (shell_parent)
	init_camera()

/obj/item/circuit_component/remotecam/polaroid/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell_parent, /obj/item/camera))
		return
	current_camera_state = FALSE //Always reset camera state for built-in shell components
	shell_camera = new /obj/machinery/camera (shell_parent)
	init_camera()

/obj/item/circuit_component/remotecam/bci/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return PROCESS_KILL
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

/obj/item/circuit_component/remotecam/polaroid/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return PROCESS_KILL
	//Camera is currently emp'd
	if (current_camera_emp)
		close_camera()
		return
	//If camera is stored inside of bag or something, turn it off
	if(shell_parent.loc.atom_storage)
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
