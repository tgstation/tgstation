
/particles/unusual_effect
	width = 32
	height = 32
	count = 10
	spawning = 5
	bound1 = list(-16, -16, -100)
	bound2 = list(16, 16, 0)
	lifespan = 10
	gradient = list("#FFBF00", "#FFEA00")
	color_change = 0.1
	position = generator("box", list(-16, -16, -100), list(16, 16, -100))
	velocity = generator("box", list(-1, -1), list(1, 1))
	fade = 3
	fadein = 3

/datum/component/unusual_effect
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

/datum/component/unusual_effect/Initialize(color, include_particles)
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return COMPONENT_INCOMPATIBLE

	parent_movable.add_filter("unusual_effect", 2, list("type" = "outline", "color" = color, "size" = 2))
	parent_movable.particles = new /particles/unusual_effect()
	START_PROCESSING(SSobj, src)

/datum/component/unusual_effect/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))

/datum/component/unusual_effect/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_GEIGER_COUNTER_SCAN,
	))

/datum/component/unusual_effect/Destroy(force, silent)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("unusual_effect")
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/unusual_effect/process(seconds_per_tick)
	var/filter = parent_movable.get_filter("unusual_effect")
	if (!filter)
		qdel(src)
		return PROCESS_KILL
	animate(filter, alpha = 110, time = seconds_per_tick / 2, loop = -1)
	animate(alpha = 40, time = seconds_per_tick / 2)
