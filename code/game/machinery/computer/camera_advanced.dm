/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	light_color = COLOR_SOFT_RED
	processing_flags = START_PROCESSING_MANUALLY

	var/list/z_lock = list() // Lock use to these z levels
	var/lock_override = NONE
	var/mob/eye/camera/remote/eyeobj
	var/mob/living/current_user = null
	var/list/networks = list(CAMERANET_NETWORK_SS13)
	/// Typepath of the action button we use as "off"
	/// It's a typepath so subtypes can give it fun new names
	var/datum/action/innate/camera_off/off_action = /datum/action/innate/camera_off
	/// Typepath for jumping
	var/datum/action/innate/camera_jump/jump_action = /datum/action/innate/camera_jump
	/// Typepath of the move up action
	var/datum/action/innate/camera_multiz_up/move_up_action = /datum/action/innate/camera_multiz_up
	/// Typepath of the move down action
	var/datum/action/innate/camera_multiz_down/move_down_action = /datum/action/innate/camera_multiz_down

	/// List of all actions to give to a user when they're well, granted actions
	var/list/actions = list()
	///Should we supress any view changes?
	var/should_supress_view_changes = TRUE
	///Should we add a usb port to this console?
	var/add_usb_port = TRUE

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_REQUIRES_SIGHT

/obj/machinery/computer/camera_advanced/Initialize(mapload)
	. = ..()
	for(var/i in networks)
		networks -= i
		networks += LOWER_TEXT(i)
	if(lock_override)
		if(lock_override & CAMERA_LOCK_STATION)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_STATION)
		if(lock_override & CAMERA_LOCK_MINING)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_MINING)
		if(lock_override & CAMERA_LOCK_CENTCOM)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_CENTCOM)

	if(off_action)
		actions += new off_action(src)
	if(jump_action)
		actions += new jump_action(src)
	//Camera action button to move up a Z level
	if(move_up_action)
		actions += new move_up_action(src)
	//Camera action button to move down a Z level
	if(move_down_action)
		actions += new move_down_action(src)
	if(add_usb_port)
		AddComponent(/datum/component/usb_port, \
			list(
				/obj/item/circuit_component/advanced_camera,
				/obj/item/circuit_component/advanced_camera_intercept,
			), \
			extra_registration_callback = PROC_REF(register_usb_port), \
			extra_unregistration_callback = PROC_REF(unregister_usb_port) \
		)

/obj/machinery/computer/camera_advanced/Destroy()
	unset_machine()
	QDEL_NULL(eyeobj)
	QDEL_LIST(actions)
	current_user = null
	return ..()

/obj/machinery/computer/camera_advanced/process()
	if(!can_use(current_user) || (issilicon(current_user) && !HAS_SILICON_ACCESS(current_user)))
		unset_machine()
		return PROCESS_KILL

/obj/machinery/computer/camera_advanced/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	for(var/i in networks)
		networks -= i
		networks += "[port.shuttle_id]_[i]"

/obj/machinery/computer/camera_advanced/syndie
	icon_keyboard = "syndie_key"
	circuit = /obj/item/circuitboard/computer/advanced_camera

/obj/machinery/computer/camera_advanced/syndie/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return //For syndie nuke shuttle, to spy for station.

/**
 * Initializes a camera eye.
 * Returns TRUE if initialization was successful.
 * Will return nothing if it runtimes.
 */
/obj/machinery/computer/camera_advanced/proc/CreateEye()
	if(eyeobj)
		CRASH("Tried to make another eyeobj for some reason. Why?")

	eyeobj = new(get_turf(src), src)
	return TRUE

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	for(var/datum/action/to_grant as anything in actions)
		to_grant.Grant(user)

/obj/machinery/proc/remove_eye_control(mob/living/user)
	CRASH("[type] does not implement camera eye handling")

/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	if(isnull(user?.client))
		return

	current_user = user
	eyeobj.assign_user(user)
	GrantActions(user)

	if(should_supress_view_changes)
		user.client.view_size.supress()
	begin_processing()

/obj/machinery/computer/camera_advanced/remove_eye_control(mob/living/user)
	if(isnull(user?.client))
		return

	for(var/datum/action/actions_removed as anything in actions)
		actions_removed.Remove(user)

	eyeobj.assign_user(null)
	current_user = null

	user.client.view_size.unsupress()

	playsound(src, 'sound/machines/terminal/terminal_off.ogg', 25, FALSE)

/obj/machinery/computer/camera_advanced/on_set_is_operational(old_value)
	if(!is_operational)
		unset_machine()

/obj/machinery/computer/camera_advanced/proc/unset_machine()
	if(!QDELETED(current_user))
		remove_eye_control(current_user)
	end_processing()

/obj/machinery/computer/camera_advanced/proc/can_use(mob/living/user)
	return can_interact(user)

/obj/machinery/computer/camera_advanced/abductor/can_use(mob/user)
	if(!isabductor(user))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_use(user))
		return
	if(isnull(user.client))
		return
	if(!QDELETED(current_user))
		to_chat(user, span_warning("The console is already in use!"))
		return

	if(eyeobj)
		give_eye_control(user)
		eyeobj.setLoc(eyeobj.loc)
		return
	/* We're attempting to initialize the eye past this point */

	if(!CreateEye())
		to_chat(user, span_warning("\The [src] flashes a bunch of never-ending errors on the display. Something is really wrong."))
		return

	SEND_SIGNAL(src, COMSIG_ADVANCED_CAMERA_EYE_CREATED, eyeobj)

	var/camera_location
	var/turf/myturf = get_turf(src)
	var/consider_zlock = (!!length(z_lock))

	if(!eyeobj.use_visibility)
		if(consider_zlock && !(myturf.z in z_lock))
			camera_location = locate(round(world.maxx * 0.5), round(world.maxy * 0.5), z_lock[1])
		else
			camera_location = myturf
	else
		if((!consider_zlock || (myturf.z in z_lock)) && GLOB.cameranet.checkTurfVis(myturf))
			camera_location = myturf
		else
			for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
				if(!C.can_use() || consider_zlock && !(C.z in z_lock))
					continue
				var/list/network_overlap = networks & C.network
				if(length(network_overlap))
					camera_location = get_turf(C)
					break

	if(camera_location)
		give_eye_control(user)
		eyeobj.setLoc(camera_location, TRUE)
	else
		unset_machine()

/obj/machinery/computer/camera_advanced/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/computer/camera_advanced/attack_ai(mob/user)
	return //AIs would need to disable their own camera procs to use the console safely. Bugs happen otherwise.

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin_ref.resolve()
	console.remove_eye_control(owner)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin_ref.resolve()

	var/list/cameras_by_tag = GLOB.cameranet.get_available_camera_by_tag_list(origin.networks, origin.z_lock)

	playsound(origin, 'sound/machines/terminal/terminal_prompt.ogg', 25, FALSE)
	var/camera = tgui_input_list(usr, "Camera to view", "Cameras", cameras_by_tag)
	if(isnull(camera))
		return

	playsound(src, SFX_TERMINAL_TYPE, 25, FALSE)

	var/obj/machinery/camera/chosen_camera = cameras_by_tag[camera]
	if(isnull(chosen_camera))
		playsound(origin, 'sound/machines/terminal/terminal_prompt_deny.ogg', 25, FALSE)
		return

	playsound(origin, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 25, FALSE)
	remote_eye.setLoc(get_turf(chosen_camera))
	owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
	owner.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!

/datum/action/innate/camera_multiz_up
	name = "Move up a floor"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "move_up"

/datum/action/innate/camera_multiz_up/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(UP))
		to_chat(owner, span_notice("You move upwards."))
	else
		to_chat(owner, span_notice("You couldn't move upwards!"))

/datum/action/innate/camera_multiz_down
	name = "Move down a floor"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "move_down"

/datum/action/innate/camera_multiz_down/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(DOWN))
		to_chat(owner, span_notice("You move downwards."))
	else
		to_chat(owner, span_notice("You couldn't move downwards!"))

/obj/machinery/computer/camera_advanced/human_ai/screwdriver_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "repackaging...")
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_BLOCKING
	tool.play_tool_sound(src, 40)
	new /obj/item/secure_camera_console_pod(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Equipment action component support

/obj/machinery/computer/camera_advanced/proc/register_usb_port(datum/component/usb_port/port)
	RegisterSignal(port, COMSIG_USB_PORT_REGISTER_PHYSICAL_OBJECT, PROC_REF(on_port_register_object))
	RegisterSignal(port, COMSIG_USB_PORT_UNREGISTER_PHYSICAL_OBJECT, PROC_REF(on_port_unregister_object))
	if(port.physical_object)
		on_port_register_object(port, port.physical_object)

/obj/machinery/computer/camera_advanced/proc/on_port_register_object(datum/component/usb_port/source, atom/movable/object)
	SIGNAL_HANDLER
	var/obj/item/integrated_circuit/circuit = source.attached_circuit
	if(object == circuit)
		return
	RegisterSignal(object, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(add_circuit_action))
	RegisterSignal(object, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(remove_circuit_action))
	for(var/obj/item/circuit_component/equipment_action/action_comp in circuit.attached_components)
		add_circuit_action(null, action_comp)

/obj/machinery/computer/camera_advanced/proc/add_circuit_action(datum/_source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/camera_circuit_action/new_action = new(src, action_comp)
	LAZYADD(actions, new_action)
	if(current_user)
		new_action.Grant(current_user)

/obj/machinery/computer/camera_advanced/proc/remove_circuit_action(datum/_source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/camera_circuit_action/action = action_comp.granted_to[REF(src)]
	if(!istype(action))
		return
	LAZYREMOVE(actions, action)
	qdel(action)

/obj/machinery/computer/camera_advanced/proc/on_port_unregister_object(datum/component/usb_port/source, atom/movable/object)
	SIGNAL_HANDLER
	var/obj/item/integrated_circuit/circuit = source.attached_circuit
	for(var/obj/item/circuit_component/equipment_action/action_comp in circuit.attached_components)
		remove_circuit_action(null, action_comp)
	UnregisterSignal(object, list(COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED))

/obj/machinery/computer/camera_advanced/proc/unregister_usb_port(datum/component/usb_port/port)
	if(port.physical_object)
		on_port_unregister_object(port, port.physical_object)
	UnregisterSignal(port, list(COMSIG_USB_PORT_REGISTER_PHYSICAL_OBJECT, COMSIG_USB_PORT_UNREGISTER_PHYSICAL_OBJECT))

/datum/action/innate/camera_circuit_action
	name = "Action"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_power"

	var/obj/machinery/computer/camera_advanced/console
	var/obj/item/circuit_component/equipment_action/action_comp

/datum/action/innate/camera_circuit_action/New(obj/machinery/computer/camera_advanced/console, obj/item/circuit_component/equipment_action/action_comp)
	. = ..()
	src.console = console
	action_comp.granted_to[REF(console)] = src
	src.action_comp = action_comp

/datum/action/innate/camera_circuit_action/Destroy()
	action_comp.granted_to -= REF(console)
	action_comp = null

	return ..()

/datum/action/innate/camera_circuit_action/Activate()
	action_comp.user.set_output(owner)
	action_comp.signal.set_output(COMPONENT_SIGNAL)

	return ..()

/// Advanced camera component

/obj/item/circuit_component/advanced_camera
	display_name = "Advanced Camera Console"
	desc = "Gets the position being viewed through the console."

	var/datum/port/output/eye_x
	var/datum/port/output/eye_y
	var/datum/port/output/eye_z

	var/obj/machinery/computer/camera_advanced/attached_console

/obj/item/circuit_component/advanced_camera/populate_ports()
	eye_x = add_output_port("X", PORT_TYPE_NUMBER)
	eye_y = add_output_port("Y", PORT_TYPE_NUMBER)
	eye_z = add_output_port("Z", PORT_TYPE_NUMBER)

/obj/item/circuit_component/advanced_camera/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/camera_advanced))
		attached_console = parent
		if(attached_console.eyeobj)
			register_eyeobj(attached_console.eyeobj)
		else
			RegisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED, PROC_REF(on_parent_eye_created))

/obj/item/circuit_component/advanced_camera/proc/on_parent_eye_created(datum/_source, mob/eye/camera/remote/eyeobj)
	SIGNAL_HANDLER
	UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
	register_eyeobj(eyeobj)

/obj/item/circuit_component/advanced_camera/proc/register_eyeobj(mob/eye/camera/remote/eyeobj)
	RegisterSignal(eyeobj, COMSIG_MOVABLE_MOVED, PROC_REF(on_eyeobj_moved))

/obj/item/circuit_component/advanced_camera/unregister_usb_parent(atom/movable/parent)
	if(istype(parent, /obj/machinery/computer/camera_advanced))
		UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
		if(attached_console.eyeobj)
			UnregisterSignal(attached_console.eyeobj, COMSIG_MOVABLE_MOVED)
		attached_console = null
	return ..()

/obj/item/circuit_component/advanced_camera/proc/on_eyeobj_moved(atom/movable/source)
	SIGNAL_HANDLER
	var/turf/eye_turf = get_turf(source)
	if(!eye_turf)
		return
	if(!GLOB.cameranet.checkTurfVis(eye_turf))
		return
	eye_x.set_output(source.x)
	eye_y.set_output(source.y)
	eye_z.set_output(source.z)

/// Advanced camera target intercept component

/obj/item/circuit_component/advanced_camera_intercept
	display_name = "Advanced Camera Target Intercept"
	desc = "Allows the user to target an entity or position with the console."

	var/datum/port/input/enabled

	var/datum/port/output/target_x
	var/datum/port/output/target_y
	var/datum/port/output/target_z

	var/datum/port/output/target_port

	var/datum/port/output/primary_click
	var/datum/port/output/secondary_click

	var/obj/machinery/computer/camera_advanced/attached_console

/obj/item/circuit_component/advanced_camera_intercept/populate_ports()
	. = ..()
	enabled = add_input_port("Enabled", PORT_TYPE_NUMBER)

	target_x = add_output_port("X", PORT_TYPE_NUMBER)
	target_y = add_output_port("Y", PORT_TYPE_NUMBER)
	target_z = add_output_port("Z", PORT_TYPE_NUMBER)

	target_port = add_output_port("Target", PORT_TYPE_ATOM)

	primary_click = add_output_port("Primary", PORT_TYPE_SIGNAL)
	secondary_click = add_output_port("Secondary", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/advanced_camera_intercept/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/camera_advanced))
		attached_console = parent
		if(attached_console.eyeobj)
			register_eyeobj(attached_console.eyeobj)
		else
			RegisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED, PROC_REF(on_parent_eye_created))

/obj/item/circuit_component/advanced_camera_intercept/input_received(datum/port/input/port, list/return_values)
	if(port != enabled)
		return
	if(enabled.value)
		attached_console.current_user?.click_intercept = src
	else
		attached_console.current_user?.click_intercept = null

/obj/item/circuit_component/advanced_camera_intercept/proc/on_parent_eye_created(datum/_source, mob/eye/camera/remote/eyeobj)
	SIGNAL_HANDLER
	UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
	register_eyeobj(eyeobj)

/obj/item/circuit_component/advanced_camera_intercept/proc/register_eyeobj(mob/eye/camera/remote/eyeobj)
	RegisterSignal(eyeobj, COMSIG_REMOTE_CAMERA_ASSIGN_USER, PROC_REF(on_parent_assign_user))
	if(enabled.value)
		attached_console.current_user?.click_intercept = src

/obj/item/circuit_component/advanced_camera_intercept/unregister_usb_parent(atom/movable/parent)
	if(istype(parent, /obj/machinery/computer/camera_advanced))
		attached_console.current_user?.click_intercept = null
		if(attached_console.eyeobj)
			UnregisterSignal(attached_console.eyeobj, COMSIG_REMOTE_CAMERA_ASSIGN_USER)
		UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
		attached_console = null
	return ..()

/obj/item/circuit_component/advanced_camera_intercept/proc/on_parent_assign_user(datum/_source, mob/living/new_user, mob/living/old_user)
	SIGNAL_HANDLER
	old_user?.click_intercept = null
	if(enabled.value)
		new_user?.click_intercept = src

/obj/item/circuit_component/advanced_camera_intercept/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		return
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return
	if(!GLOB.cameranet.checkTurfVis(target_turf))
		return
	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_TARGET_INTERCEPT))
		return
	target_x.set_output(target.x)
	target_y.set_output(target.y)
	target_z.set_output(target.z)

	target_port.set_output(target)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		secondary_click.set_output(COMPONENT_SIGNAL)
	else
		primary_click.set_output(COMPONENT_SIGNAL)
	if(parent.shell)
		TIMER_COOLDOWN_START(parent.shell, COOLDOWN_CIRCUIT_TARGET_INTERCEPT, 1 SECONDS)
	return TRUE
