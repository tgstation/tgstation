/obj/structure/reflector
	name = "reflector"
	icon_state = "reflector"
	desc = "An angled mirror for reflecting lasers."
	anchored = 1
	density = 1
	layer = 2
	var/static/list/rotations = list("[NORTH]" = list("[SOUTH]" = WEST, "[EAST]" = NORTH),
"[EAST]" = list("[SOUTH]" = EAST, "[WEST]" = NORTH),
"[SOUTH]" = list("[NORTH]" = EAST, "[WEST]" = SOUTH),
"[WEST]" = list("[NORTH]" = WEST, "[EAST]" = SOUTH) )

/obj/structure/reflector/bullet_act(obj/item/projectile/P)
	var/new_dir = 0
	var/turf/reflector_turf = get_turf(src)
	var/turf/reflect_turf
	new_dir = rotations["[src.dir]"]["[P.dir]"]

	if(new_dir)
		reflect_turf = get_step(reflect_turf, new_dir)
	else
		visible_message("<span class='notice'>[src] is hit by the [P]!</span>")
		return ..() //Hits as normal, explodes or emps or whatever

	visible_message("<span class='notice'>[P] bounces off of the [src]</span>")
	reflect_turf = get_step(loc,new_dir)

	P.original = reflect_turf
	P.starting = reflector_turf
	P.current = reflector_turf
	P.yo = reflect_turf.y - reflector_turf.y
	P.xo = reflect_turf.x - reflector_turf.x
	P.kill_count = 50 //Keep the projectile healthy as long as its bouncing off things
	return - 1