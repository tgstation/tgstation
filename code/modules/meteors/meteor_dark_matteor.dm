/// The dark matt-eor. Only attracted by emagging 10 satellites and maximizing meteor chances, and it drops a singulo. Otherwise, it's not that bad.
/obj/effect/meteor/dark_matteor
	name = "dark matt-eor"
	icon_state = "dark_matter"
	desc = "The most widely accepted theory is that dark matter is made up of weakly interacting massive particles (WIMPs). But seeing this malevolent force of imminent death careening towards you, gotta admit, it doesn't look so WIMPy anymore..."
	hits = 15
	hitpwr = EXPLODE_DEVASTATE
	heavy = TRUE
	meteorsound = 'sound/effects/curse1.ogg'
	meteordrop = list(/obj/singularity/dark_matteor) //what the FUCK
	dropamt = 1
	threat = 100
	signature = "dark matter"
	/// distortion to really give you that sense of oh shit
	var/atom/movable/warp_effect/warp
	/// and another oh shit in the form of quantum sparks
	var/datum/effect_system/spark_spread/quantum/spark_system

/obj/effect/meteor/dark_matteor/Initialize(mapload)
	. = ..()
	warp = new(src)
	vis_contents += warp
	spark_system = new /datum/effect_system/spark_spread/quantum()
	spark_system.set_up(4, TRUE, src)
	spark_system.attach(src)
	START_PROCESSING(SSobj, src)

/obj/effect/meteor/dark_matteor/process(delta_time)
	//meteor's warp quickly contracts then slowly expands it's ring
	animate(warp, time = delta_time*3, transform = matrix().Scale(0.5,0.5))
	animate(time = delta_time*7, transform = matrix())

/obj/effect/meteor/dark_matteor/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(warp)
		SET_PLANE(warp, PLANE_TO_TRUE(warp.plane), new_turf)

/obj/effect/meteor/dark_matteor/Destroy()
	QDEL_NULL(spark_system)
	vis_contents -= warp
	QDEL_NULL(warp)
	return ..()

/obj/effect/meteor/dark_matteor/Move()
	. = ..()
	if(.)
		spark_system.start()

/obj/effect/meteor/dark_matteor/shield_defense(obj/machinery/satellite/meteor_shield/defender)
	defender.visible_message(span_danger("[defender]'s beam is reflected by [src]!"))
	new /obj/effect/temp_visual/explosion/fast(get_turf(defender))
	qdel(defender)
	return FALSE
