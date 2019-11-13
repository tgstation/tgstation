/datum/proximity_monitor/advanced/gravity
	name = "modified gravity zone"
	setup_field_turfs = TRUE
	var/gravity_value = 0
	var/list/grav_components = list()
	field_shape = FIELD_SHAPE_RADIUS_SQUARE

/datum/proximity_monitor/advanced/gravity/setup_field_turf(turf/T)
	. = ..()
	grav_components[T] = T.AddComponent(/datum/component/forced_gravity,gravity_value)

/datum/proximity_monitor/advanced/gravity/cleanup_field_turf(turf/T)
	. = ..()
	var/datum/component/forced_gravity/G = grav_components[T]
	grav_components -= T
	if(G)
		qdel(G)
