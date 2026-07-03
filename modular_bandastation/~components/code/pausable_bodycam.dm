// updates only when watching sources > 0
/datum/component/pausable_bodycam
	dupe_mode = COMPONENT_DUPE_UNIQUE
	VAR_PRIVATE/obj/machinery/camera/bodycam/bodycam
	var/camera_update_time = 0.5 SECONDS
	var/list/sources_watching

/datum/component/pausable_bodycam/Initialize(
	camera_name = "bodycam",
	c_tag = capitalize(camera_name),
	network = "ss13",
	emp_proof = FALSE,
	camera_update_time = 0.5 SECONDS, // maybe tick interval gotta be smaller for a real usage on the server
	camera_enabled = TRUE,
)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.camera_update_time = camera_update_time

	bodycam = new /obj/machinery/camera/bodycam(parent)
	bodycam.bodycam_component = src
	bodycam.network = list(network)
	bodycam.name = camera_name
	bodycam.c_tag = c_tag
	bodycam.camera_enabled = camera_enabled
	if(emp_proof)
		bodycam.AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

	RegisterSignals(bodycam, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(camera_gone))

/datum/component/pausable_bodycam/Destroy()
	force_pause()
	if(bodycam && !QDELETED(bodycam))
		bodycam.bodycam_component = null
		QDEL_NULL(bodycam)
	return ..()

/datum/component/pausable_bodycam/proc/on_watch_start(datum/source)
	LAZYADD(sources_watching, source)
	if(LAZYLEN(sources_watching) != 1)
		return
	// we can still see that the camera exists using the monitor and select it
	if(!bodycam?.camera_enabled)
		return
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate_cam))
	do_update_cam(null)
	if(isliving(parent))
		var/mob/living/L = parent
		L.throw_alert(ALERT_BODYCAM_VIEWED, /atom/movable/screen/alert/bodycam_viewed)

/datum/component/pausable_bodycam/proc/on_watch_stop(datum/source)
	LAZYREMOVE(sources_watching, source)
	if(LAZYLEN(sources_watching) > 0)
		return
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	if(bodycam && !QDELETED(bodycam))
		SScameras.remove_camera_from_chunk(bodycam)
	if(isliving(parent))
		var/mob/living/L = parent
		if(L.has_alert(ALERT_BODYCAM_VIEWED))
			L.clear_alert(ALERT_BODYCAM_VIEWED)

/datum/component/pausable_bodycam/proc/update_cam(datum/source, atom/old_loc, ...)
	SIGNAL_HANDLER
	if(get_turf(old_loc) != get_turf(parent))
		do_update_cam(old_loc)

/datum/component/pausable_bodycam/proc/do_update_cam(atom/old_loc)
	if(!bodycam || QDELETED(bodycam))
		return
	if(!bodycam.can_use())
		return
	SScameras.camera_moved(bodycam, get_turf(old_loc), get_turf(bodycam), camera_update_time)
	notify_watchers_refresh()

/datum/component/pausable_bodycam/proc/rotate_cam(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(bodycam && !QDELETED(bodycam))
		bodycam.setDir(new_dir)

/datum/component/pausable_bodycam/proc/camera_gone(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/datum/component/pausable_bodycam/proc/set_camera_enabled(enabled)
	if(!bodycam || QDELETED(bodycam))
		return
	bodycam.camera_enabled = enabled
	if(!enabled)
		force_pause()

/datum/component/pausable_bodycam/proc/set_broken(broken, camera_on = TRUE)
	if(!bodycam || QDELETED(bodycam))
		return
	bodycam.camera_enabled = !broken && camera_on
	if(broken || !bodycam.camera_enabled)
		force_pause()

/datum/component/pausable_bodycam/proc/notify_watchers_disconnect()
	if(!bodycam || QDELETED(bodycam))
		return
	var/list/to_notify = length(sources_watching) ? sources_watching.Copy() : list()
	for(var/datum/s in to_notify)
		if(istype(s, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/cons = s
			cons.on_camera_disabled(bodycam)
		else if(istype(s, /datum/computer_file/program/secureye))
			var/datum/computer_file/program/secureye/prog = s
			prog.on_camera_disabled(bodycam)

// with this pattren we could have a proc that takes a mode (disable/refresh) and iterates, but that's kinda overkill
/datum/component/pausable_bodycam/proc/notify_watchers_refresh()
	for(var/datum/s in sources_watching)
		if(istype(s, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/cons = s
			cons.update_active_camera_screen()
		else if(istype(s, /datum/computer_file/program/secureye))
			var/datum/computer_file/program/secureye/prog = s
			prog.update_active_camera_screen()

/datum/component/pausable_bodycam/proc/force_pause()
	notify_watchers_disconnect()
	LAZYCLEARLIST(sources_watching)
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	if(bodycam && !QDELETED(bodycam))
		SScameras.remove_camera_from_chunk(bodycam)
	if(isliving(parent))
		var/mob/living/L = parent
		if(L.has_alert(ALERT_BODYCAM_VIEWED))
			L.clear_alert(ALERT_BODYCAM_VIEWED)
