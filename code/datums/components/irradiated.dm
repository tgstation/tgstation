/// This atom is irradiated, and will glow green.
/datum/component/irradiated
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/beginning_of_irradiation

/datum/component/irradiated/Initialize()
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	// This isn't incompatible, it's just wrong
	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return

	create_glow()

	beginning_of_irradiation = world.time

/datum/component/irradiated/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))

/datum/component/irradiated/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_GEIGER_COUNTER_SCAN,
	))

/datum/component/irradiated/Destroy(force)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("rad_glow")

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/component/irradiated/proc/create_glow()
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return

	parent_movable.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop), parent_movable), rand(0.1 SECONDS, 1.9 SECONDS)) // Things should look uneven

/datum/component/irradiated/proc/start_glow_loop(atom/movable/parent_movable)
	var/filter = parent_movable.get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/datum/component/irradiated/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if (!(clean_types & CLEAN_TYPE_RADIATION))
		return NONE

	qdel(src)
	return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/datum/component/irradiated/proc/on_geiger_counter_scan(datum/source, mob/user, obj/item/geiger_counter/geiger_counter)
	SIGNAL_HANDLER

	// In case the green wasn't obvious enough...
	to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Target is irradiated."))

	return COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL
