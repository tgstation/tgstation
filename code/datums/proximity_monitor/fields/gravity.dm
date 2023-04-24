/datum/proximity_monitor/advanced/gravity
	edge_is_a_field = TRUE
	var/gravity_value = 0
	var/list/modified_turfs = list()

/datum/proximity_monitor/advanced/gravity/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, gravity)
	. = ..()
	gravity_value = gravity
	recalculate_field()

/datum/proximity_monitor/advanced/gravity/setup_field_turf(turf/target)
	. = ..()
	if (isnull(modified_turfs[target]))
		return

	target.AddElement(/datum/element/forced_gravity, gravity_value)
	modified_turfs[target] = gravity_value

/datum/proximity_monitor/advanced/gravity/cleanup_field_turf(turf/target)
	. = ..()
	if(isnull(modified_turfs[target]))
		return
	target.RemoveElement(/datum/element/forced_gravity, modified_turfs[target])
	modified_turfs -= target
