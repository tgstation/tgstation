/obj/effect/decal/cleanable/gasoline
	name = "gasoline"
	desc = "I HOPE YOU DIE IN A FIRE!!!"
	icon = 'icons/effects/dirt.dmi'
	icon_state = "water"
	base_icon_state = "water"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLEANABLE_DIRT)
	canSmoothWith = list(SMOOTH_GROUP_CLEANABLE_DIRT, SMOOTH_GROUP_WALLS)
//	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	beauty = -50
	alpha = 64
	color = "#c6845b"

/obj/effect/decal/cleanable/gasoline/update_icon()
	. = ..()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)

/* /obj/effect/decal/cleanable/gasoline/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	(atom/movable/AM, oldloc)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.on_fire)
			var/obj/effect/fire/F = locate() in get_turf(src)
			if(!F)
				new /obj/effect/fire(get_turf(src))
	..(AM) */

/obj/effect/decal/cleanable/gasoline/Initialize()
	. = ..()
/* 	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/floor))
		var/turf/open/floor/F = T
		F.spread_chance = 100
		F.burn_material += 100
 */
	//	smoothing_flags = SMOOTH_BITMASK
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)

/obj/effect/decal/cleanable/gasoline/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/decal/cleanable/gasoline/fire_act(exposed_temperature, exposed_volume)
	if(reagents)
		reagents.expose_temperature(exposed_temperature)
	..()
	//var/obj/effect/fire/F = locate() in loc
	//if(!F)
	//	new /obj/effect/fire(loc)
	..()

/obj/effect/decal/cleanable/gasoline/attackby(obj/item/I, mob/living/user)
	var/attacked_by_hot_thing = I.get_temperature()
	if(attacked_by_hot_thing)
		visible_message("<span class='warning'>[user] tries to ignite [src] with [I]!</span>", "<span class='warning'>You try to ignite [src] with [I].</span>")
		log_combat(user, src, (attacked_by_hot_thing < 480) ? "tried to ignite" : "ignited", I)
		fire_act(attacked_by_hot_thing)
		return
	return ..()
