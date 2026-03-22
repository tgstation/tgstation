
/obj/effect/decal/cleanable/greenglow/waste
	name = "caustic sludge"
	desc = "A puddle of industrial waste. Eats through the floor if not cleaned up."
	icon_state = "waste_spill"
	light_power = 1
	beauty = -300
	clean_type = CLEAN_TYPE_ACID
	decal_reagent = /datum/reagent/toxin/acid/industrial_waste
	alpha = 0
	var/datum/looping_sound/soup/bubbling_audio //It's really just bubbling liquid audio, which is what I need here.

/obj/effect/decal/cleanable/greenglow/waste/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	animate(src, alpha=255, time= 0.5 SECONDS)

	bubbling_audio = new /datum/looping_sound/soup(src)
	bubbling_audio.start()
	pre_eat()
	add_shared_particles(/particles/smoke/steam/toxic)

/obj/effect/decal/cleanable/greenglow/waste/Destroy()
	. = ..()
	QDEL_NULL(bubbling_audio)
	remove_shared_particles(/particles/smoke/steam/toxic)

/obj/effect/decal/cleanable/greenglow/waste/proc/pre_eat(display_message = TRUE)
	if(display_message)
		visible_message(span_warning("\The [src] begins corroding \the [get_turf(src)]!"))
	playsound(src, 'sound/items/tools/welder.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(eat_floor)), 45 SECONDS)

/obj/effect/decal/cleanable/greenglow/waste/proc/eat_floor()
	var/atom/splashed_turf = get_turf(src)
	if(!isfloorturf(splashed_turf))
		return
	var/turf/open/splash_floor = splashed_turf
	splash_floor.ScrapeAway(flags = CHANGETURF_IGNORE_AIR) //Eat away the floor
	visible_message(span_warning("The waste eats away at the floor, leaving \the [get_turf(src)] behind."))
	qdel(src)
