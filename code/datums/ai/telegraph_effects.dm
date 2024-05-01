/obj/effect/temp_visual/telegraphing
	icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	icon_state = "target_box"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 1
	duration = 2 SECONDS

/obj/effect/temp_visual/telegraphing/vending_machine_tilt
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/lift_travel

/obj/effect/temp_visual/telegraphing/lift_travel/Initialize(mapload, duration)
	src.duration = duration
	return ..()

/obj/effect/temp_visual/telegraphing/thunderbolt
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "target_circle"
	duration = 2 SECONDS

///prototype for telegraphs that creates an atom in its place when timing out
/obj/effect/temp_visual/telegraphing/create_type
	///what to create on destroy, required
	var/created_type
	///visible message on creation, optional. can use %TYPE as a replacement for referring to the created object.
	var/creation_message

/obj/effect/temp_visual/telegraphing/create_type/Destroy()
	if(!created_type)
		CRASH("telegraphed atom creation missing type!")
	var/turf/creation_turf = get_turf(src)
	if(!creation_turf)
		return ..()
	var/atom/created = new created_type(creation_turf)
	if(creation_message)
		var/treated = replacetext(creation_message, "%TYPE", "[created]")
		created.visible_message(treated)
	. = ..()
