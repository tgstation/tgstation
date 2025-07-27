/// Simple component to integrate a bodycam into a mob
/datum/component/simple_bodycam
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	/// The actual camera, in our mob's contents
	VAR_PRIVATE/obj/machinery/camera/bodycam
	/// How fast we update
	var/camera_update_time = 0.5 SECONDS

/datum/component/simple_bodycam/Initialize(
	camera_name = "bodycam",
	c_tag = capitalize(camera_name),
	network = "ss13",
	emp_proof = FALSE,
	camera_update_time = 0.5 SECONDS,
)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.camera_update_time = camera_update_time

	bodycam = new(parent)
	bodycam.network = list(network)
	bodycam.name = camera_name
	bodycam.c_tag = c_tag
	if(emp_proof)
		bodycam.AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate_cam))
	RegisterSignals(bodycam, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(camera_gone))

	do_update_cam()

/datum/component/simple_bodycam/Destroy()
	if(QDELETED(bodycam))
		bodycam = null
	else
		QDEL_NULL(bodycam)
	return ..()

/datum/component/simple_bodycam/CheckDupeComponent(
	datum/component/simple_bodycam/new_bodycam, // will be null
	camera_name,
	c_tag,
	network = "ss13",
	emp_proof,
	camera_update_time,
)
	// Dupes are only allowed if we don't have a camera on that network already
	return (network in bodycam.network)

/datum/component/simple_bodycam/proc/update_cam(datum/source, atom/old_loc, ...)
	SIGNAL_HANDLER

	if(get_turf(old_loc) != get_turf(parent))
		do_update_cam()

/datum/component/simple_bodycam/proc/do_update_cam()
	GLOB.cameranet.updatePortableCamera(bodycam, camera_update_time)

/datum/component/simple_bodycam/proc/rotate_cam(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	// I don't actually think cameras care about dir but just in case
	bodycam.setDir(new_dir)

/datum/component/simple_bodycam/proc/camera_gone(datum/source)
	SIGNAL_HANDLER
	if (!QDELETED(src))
		qdel(src)
