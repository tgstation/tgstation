/obj/vehicle/sealed/car/thanoscar
	name = "thanos car"
	desc = "THANOS CAR! THANOS CAR!"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "thanoscar"
	max_integrity = 250
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 20
	max_occupants = 50
	movedelay = 0.6
	key_type = null

/obj/vehicle/sealed/car/thanoscar/Bump(atom/movable/M)
	. = ..()
	if(isliving(M))
		var/mob/living/L = M
		visible_message("<span class='danger'>[src] rams into [L]!</span>")
		L.throw_at(get_edge_target_turf(src, get_dir(src, L)), 7, 5)
		L.take_bodypart_damage(10, check_armor = TRUE)
		playsound(loc, 'sound/vehicles/clowncar_crash2.ogg', 50, 1)
