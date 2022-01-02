
//Projectile dampening field that slows projectiles and lowers their damage for an energy cost deducted every 1/5 second.
//Only use square radius for this!
/datum/proximity_monitor/advanced/peaceborg_dampener
	var/static/image/edgeturf_south = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south")
	var/static/image/edgeturf_north = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north")
	var/static/image/edgeturf_west = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west")
	var/static/image/edgeturf_east = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east")
	var/static/image/northwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest")
	var/static/image/southwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest")
	var/static/image/northeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast")
	var/static/image/southeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast")
	var/static/image/generic_edge = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_generic")
	var/obj/item/borg/projectile_dampen/projector = null
	var/list/obj/projectile/tracked = list()
	var/list/obj/projectile/staging = list()
	// lazylist that keeps track of the overlays added to the edge of the field
	var/list/edgeturf_effects

/datum/proximity_monitor/advanced/peaceborg_dampener/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, obj/item/borg/projectile_dampen/projector)
	..()
	src.projector = projector
	recalculate_field()
	START_PROCESSING(SSfastprocess, src)

/datum/proximity_monitor/advanced/peaceborg_dampener/Destroy()
	projector = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/proximity_monitor/advanced/peaceborg_dampener/process()
	if(!istype(projector))
		qdel(src)
		return
	var/list/ranged = list()
	for(var/obj/projectile/P in range(current_range, get_turf(host)))
		ranged += P
	for(var/obj/projectile/P in tracked)
		if(!(P in ranged) || !P.loc)
			release_projectile(P)
	for(var/mob/living/silicon/robot/R in range(current_range, get_turf(host)))
		if(R.has_buckled_mobs())
			for(var/mob/living/L in R.buckled_mobs)
				L.visible_message(span_warning("[L] is knocked off of [R] by the charge in [R]'s chassis induced by the hyperkinetic dampener field!")) //I know it's bad.
				L.Paralyze(10)
				R.unbuckle_mob(L)
				do_sparks(5, 0, L)
	..()

/datum/proximity_monitor/advanced/peaceborg_dampener/setup_edge_turf(turf/target)
	. = ..()
	var/image/overlay = get_edgeturf_overlay(get_edgeturf_direction(target))
	var/obj/effect/abstract/effect = new(target) // Makes the field visible to players.
	effect.icon = overlay.icon
	effect.icon_state = overlay.icon_state
	effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	effect.layer = ABOVE_ALL_MOB_LAYER
	effect.plane = ABOVE_FOV_PLANE
	LAZYSET(edgeturf_effects, target, effect)

/datum/proximity_monitor/advanced/peaceborg_dampener/cleanup_edge_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = LAZYACCESS(edgeturf_effects, target)
	LAZYREMOVE(edgeturf_effects, target)
	if(effect)
		qdel(effect)

/datum/proximity_monitor/advanced/peaceborg_dampener/proc/get_edgeturf_overlay(direction)
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

/datum/proximity_monitor/advanced/peaceborg_dampener/proc/capture_projectile(obj/projectile/P, track_projectile = TRUE)
	if(P in tracked)
		return
	projector.dampen_projectile(P, track_projectile)
	if(track_projectile)
		tracked += P

/datum/proximity_monitor/advanced/peaceborg_dampener/proc/release_projectile(obj/projectile/P)
	projector.restore_projectile(P)
	tracked -= P

/datum/proximity_monitor/advanced/peaceborg_dampener/field_edge_uncrossed(atom/movable/movable, turf/location)
	if(istype(movable, /obj/projectile) && get_dist(movable, host) > current_range)
		if(movable in tracked)
			release_projectile(movable)
		else
			capture_projectile(movable, FALSE)

/datum/proximity_monitor/advanced/peaceborg_dampener/field_edge_crossed(atom/movable/movable, turf/location)
	if(istype(movable, /obj/projectile) && !(movable in tracked))
		capture_projectile(movable)
