SUBSYSTEM_DEF(vis_overlays)
	name = "Vis contents overlays"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_VIS
	init_order = INIT_ORDER_VIS

	var/list/vis_overlay_cache
	var/list/currentrun
	var/datum/callback/rotate_cb

/datum/controller/subsystem/vis_overlays/Initialize()
	vis_overlay_cache = list()
	rotate_cb = CALLBACK(src, .proc/rotate_vis_overlay)
	return ..()

/datum/controller/subsystem/vis_overlays/fire(resumed = FALSE)
	if(!resumed)
		currentrun = vis_overlay_cache.Copy()
	var/list/current_run = currentrun

	while(current_run.len)
		var/key = current_run[current_run.len]
		var/obj/effect/overlay/vis/overlay = current_run[key]
		current_run.len--
		if(!overlay.unused && !length(overlay.vis_locs))
			overlay.unused = world.time
		else if(overlay.unused && overlay.unused + overlay.cache_expiration < world.time)
			vis_overlay_cache -= key
			qdel(overlay)
		if(MC_TICK_CHECK)
			return

//the "thing" var can be anything with vis_contents which includes images
/datum/controller/subsystem/vis_overlays/proc/add_vis_overlay(atom/movable/thing, icon, iconstate, layer, plane, dir, alpha=255)
	. = "[icon]|[iconstate]|[layer]|[plane]|[dir]|[alpha]"
	var/obj/effect/overlay/vis/overlay = vis_overlay_cache[.]
	if(!overlay)
		overlay = new
		overlay.icon = icon
		overlay.icon_state = iconstate
		overlay.layer = layer
		overlay.plane = plane
		overlay.dir = dir
		overlay.alpha = alpha
		vis_overlay_cache[.] = overlay
	else
		overlay.unused = 0
	thing.vis_contents += overlay

	if(!isatom(thing)) // Automatic rotation is not supported on non atoms
		return

	if(!thing.managed_vis_overlays)
		thing.managed_vis_overlays = list(overlay)
		RegisterSignal(thing, COMSIG_ATOM_DIR_CHANGE, rotate_cb)
	else
		thing.managed_vis_overlays += overlay

/datum/controller/subsystem/vis_overlays/proc/remove_vis_overlay(atom/movable/thing, list/overlays)
	thing.vis_contents -= overlays
	if(!isatom(thing))
		return
	thing.managed_vis_overlays -= overlays
	if(!length(thing.managed_vis_overlays))
		thing.managed_vis_overlays = null
		UnregisterSignal(thing, COMSIG_ATOM_DIR_CHANGE)

/datum/controller/subsystem/vis_overlays/proc/rotate_vis_overlay(atom/thing, old_dir, new_dir)
	var/rotation = dir2angle(old_dir) - dir2angle(new_dir)
	var/list/overlays_to_remove = list()
	for(var/i in thing.managed_vis_overlays)
		var/obj/effect/overlay/vis/overlay = i
		add_vis_overlay(thing, overlay.icon, overlay.icon_state, overlay.layer, overlay.plane, turn(overlay.dir, rotation))
		overlays_to_remove += overlay
	remove_vis_overlay(thing, overlays_to_remove)
