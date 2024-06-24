
//Projectile dampening field that slows projectiles and lowers their damage for an energy cost deducted every 1/5 second.
//Only use square radius for this!
/datum/proximity_monitor/advanced/projectile_dampener
	var/static/image/edgeturf_south = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south")
	var/static/image/edgeturf_north = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north")
	var/static/image/edgeturf_west = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west")
	var/static/image/edgeturf_east = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east")
	var/static/image/northwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest")
	var/static/image/southwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest")
	var/static/image/northeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast")
	var/static/image/southeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast")
	var/static/image/generic_edge = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_generic")
	var/list/obj/projectile/tracked = list()
	var/list/obj/projectile/staging = list()
	// lazylist that keeps track of the overlays added to the edge of the field
	var/list/edgeturf_effects

/datum/proximity_monitor/advanced/projectile_dampener/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, atom/projector)
	..()
	RegisterSignal(projector, COMSIG_QDELETING, PROC_REF(on_projector_del))
	recalculate_field(full_recalc = TRUE)
	START_PROCESSING(SSfastprocess, src)

/datum/proximity_monitor/advanced/projectile_dampener/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	for(var/obj/projectile/projectile in tracked)
		release_projectile(projectile)
	return ..()

/datum/proximity_monitor/advanced/projectile_dampener/process()
	var/list/ranged = list()
	for(var/obj/projectile/projectile in range(current_range, get_turf(host)))
		ranged += projectile
	for(var/obj/projectile/projectile in tracked)
		if(!(projectile in ranged) || !projectile.loc)
			release_projectile(projectile)

/datum/proximity_monitor/advanced/projectile_dampener/setup_edge_turf(turf/target)
	. = ..()
	var/image/overlay = get_edgeturf_overlay(get_edgeturf_direction(target))
	var/obj/effect/abstract/effect = new(target) // Makes the field visible to players.
	effect.icon = overlay.icon
	effect.icon_state = overlay.icon_state
	effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	effect.layer = ABOVE_ALL_MOB_LAYER
	SET_PLANE(effect, ABOVE_GAME_PLANE, target)
	LAZYSET(edgeturf_effects, target, effect)

/datum/proximity_monitor/advanced/projectile_dampener/on_z_change(datum/source)
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/projectile_dampener/cleanup_edge_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = LAZYACCESS(edgeturf_effects, target)
	LAZYREMOVE(edgeturf_effects, target)
	if(effect)
		qdel(effect)

/datum/proximity_monitor/advanced/projectile_dampener/proc/get_edgeturf_overlay(direction)
	switch(direction)
		if(NORTH)
			return edgeturf_north
		if(SOUTH)
			return edgeturf_south
		if(EAST)
			return edgeturf_east
		if(WEST)
			return edgeturf_west
		if(NORTHEAST)
			return northeast_corner
		if(NORTHWEST)
			return northwest_corner
		if(SOUTHEAST)
			return southeast_corner
		if(SOUTHWEST)
			return southwest_corner
		else
			return generic_edge

/datum/proximity_monitor/advanced/projectile_dampener/proc/capture_projectile(obj/projectile/projectile)
	if(projectile in tracked)
		return
	SEND_SIGNAL(src, COMSIG_DAMPENER_CAPTURE, projectile)
	tracked += projectile

/datum/proximity_monitor/advanced/projectile_dampener/proc/release_projectile(obj/projectile/projectile)
	SEND_SIGNAL(src, COMSIG_DAMPENER_RELEASE, projectile)
	tracked -= projectile

/datum/proximity_monitor/advanced/projectile_dampener/proc/on_projector_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/proximity_monitor/advanced/projectile_dampener/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(isprojectile(movable) && get_dist(movable, host) > current_range)
		if(movable in tracked)
			release_projectile(movable)

/datum/proximity_monitor/advanced/projectile_dampener/field_edge_crossed(atom/movable/movable, turf/location, turf/old_location)
	if(isprojectile(movable))
		capture_projectile(movable)

/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/process(seconds_per_tick)
	for(var/mob/living/silicon/robot/borg in range(current_range, get_turf(host)))
		if(!borg.has_buckled_mobs())
			continue
		for(var/mob/living/buckled_mob in borg.buckled_mobs)
			buckled_mob.visible_message(span_warning("[buckled_mob] is knocked off of [borg] by the charge in [borg]'s chassis induced by the hyperkinetic dampener field!")) //I know it's bad.
			buckled_mob.Paralyze(1 SECONDS)
			borg.unbuckle_mob(buckled_mob)
			do_sparks(5, 0, buckled_mob)
	..()
