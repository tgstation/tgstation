/obj/item/circuit_component/camera
	display_name = "Camera"
	desc = "A polaroid camera that takes pictures when triggered. The picture coordinate ports are relative to the position of the camera."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The atom that was photographed from either user click or trigger input.
	var/datum/port/output/photographed_atom
	/// The item that was added/removed.
	var/datum/port/output/picture_taken
	/// If set, the trigger input will target this atom.
	var/datum/port/input/picture_target
	/// If the above is unset, these coordinates will be used.
	var/datum/port/input/picture_coord_x
	var/datum/port/input/picture_coord_y
	/// Adjusts the picture_size_x variable of the camera.
	var/datum/port/input/adjust_size_x
	/// Idem but for picture_size_y.
	var/datum/port/input/adjust_size_y

	/// The camera this circut is attached to.
	var/obj/item/camera/camera

/obj/item/circuit_component/camera/populate_ports()
	picture_taken = add_output_port("Picture Taken", PORT_TYPE_SIGNAL)
	photographed_atom = add_output_port("Photographed Entity", PORT_TYPE_ATOM)

	picture_target = add_input_port("Picture Target", PORT_TYPE_ATOM)
	picture_coord_x = add_input_port("Picture Coordinate X", PORT_TYPE_NUMBER)
	picture_coord_y = add_input_port("Picture Coordinate Y", PORT_TYPE_NUMBER)
	adjust_size_x = add_input_port("Picture Size X", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))
	adjust_size_y = add_input_port("Picture Size Y", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))

/obj/item/circuit_component/camera/register_shell(atom/movable/shell)
	. = ..()
	camera = shell
	RegisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/obj/item/circuit_component/camera/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED)
	camera = null
	return ..()

///Adjuts the zoom of the camera
/obj/item/circuit_component/camera/proc/sanitize_picture_size()
	camera.adjust_zoom(adjust_size_x.value, adjust_size_y.value)

/obj/item/circuit_component/camera/proc/on_image_captured(obj/item/camera/source, atom/target, mob/user)
	SIGNAL_HANDLER
	photographed_atom.set_output(target)
	picture_taken.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/camera/input_received(datum/port/input/port)
	var/atom/target = picture_target.value
	if(!target)
		var/turf/our_turf = get_location()
		target = locate(our_turf.x + picture_coord_x.value, our_turf.y + picture_coord_y.value, our_turf.z)
		if(!target)
			return
	camera.attempt_picture(target)

/obj/item/circuit_component/mod_program/camera
	associated_program = /datum/computer_file/program/maintenance/camera
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///A target to take a picture of.
	var/datum/port/input/picture_target
	///The size of the photo to take.
	var/datum/port/input/picture_size
	///The photographed target
	var/datum/port/output/photographed
	/**
	 * Pinged when the image has been captured.
	 * I'm not using the default trigger output here because the process is asynced,
	 * even though I'm mostly sure it only sleeps if there's a set user.
	 */
	var/datum/port/output/photo_taken

/obj/item/circuit_component/mod_program/camera/populate_ports()
	. = ..()
	picture_target = add_input_port("Picture Target", PORT_TYPE_ATOM)
	picture_size = add_input_port("Picture Size", PORT_TYPE_NUMBER)
	photographed = add_output_port("Photographed Entity", PORT_TYPE_ATOM)
	photo_taken = add_output_port("Photo Taken", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_program/camera/register_shell(atom/movable/shell)
	. = ..()
	var/datum/computer_file/program/maintenance/camera/cam = associated_program
	RegisterSignal(cam.internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/obj/item/circuit_component/mod_program/camera/unregister_shell()
	var/datum/computer_file/program/maintenance/camera/cam = associated_program
	UnregisterSignal(cam.internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED)
	return ..()

/obj/item/circuit_component/mod_program/camera/input_received(datum/port/input/port)
	if(!COMPONENT_TRIGGERED_BY(port, trigger_input))
		return
	var/atom/target = picture_target.value
	if(!target)
		var/turf/our_turf = get_location()
		target = locate(our_turf.x, our_turf.y, our_turf.z)
		if(!target)
			return
	var/datum/computer_file/program/maintenance/camera/cam = associated_program
	cam.internal_camera.attempt_picture(target)

/obj/item/circuit_component/mod_program/camera/proc/on_image_captured(obj/item/camera/source, atom/target, mob/user)
	SIGNAL_HANDLER
	photographed.set_output(target)
	photo_taken.set_output(COMPONENT_SIGNAL)
