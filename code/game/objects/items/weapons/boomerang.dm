/obj/item/weapon/boomerang
	name = "boomerang"
	desc = "A heavy, curved piece of wood used by Space Australians for hunting, sport, entertainment, cooking, religious rituals and warfare. When thrown, it will either deal a devastating blow to somebody's head, or return back to the thrower." //also used for shitposting
	icon_state = "boomerang"

	w_class = W_CLASS_MEDIUM

	throwforce = 16
	throw_range = 7
	throw_speed = 5

	force = 7

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3

/obj/item/weapon/boomerang/Destroy()
	..()

	throwing = 0

/obj/item/weapon/boomerang/toy
	name = "toy boomerang"
	desc = "A small plastic boomerang for children."

	icon_state = "boomerang_toy"

	w_class = W_CLASS_SMALL

	throwforce = 2
	force = 1

	starting_materials = list(MAT_PLASTIC = 1200)
	melt_temperature = MELTPOINT_PLASTIC

/obj/item/weapon/boomerang/throw_at(atom/target, range, speed, override = 1)
	if(!usr)
		return ..()

	spawn()
		animate(src, transform = turn(matrix(), 120), time = 5, loop = -1)
		animate(transform = turn(matrix(), 240), time = 5)
		animate(transform = null, time = 5)

		while(throwing) //Wait until the boomerang is no longer flying. Check on 0.5-second intervals
			sleep(5)

		animate(src) //Stop the animation

	var/turf/original = get_turf(usr)
	//HOW THIS WORKS
	//An imaginary circle is drawn at the target location. Its radius increases with the distance from center to the thrower
	//Three points are chosen on the circle (at angles 90, 0, -90 - assuming 0 is the direction of the throw)
	//The boomerang is thrown at the first point, then the second point, then the third point. Then it returns to the thrower's original position

	var/circle_radius = 1+round(get_dist(usr, target) * 0.5) //Dist = 1, radius = 1. Dist = 2, radius = 2. Dist = 3, radius = 2. Dist = 7, radius = 4

	//Get points
	var/list/points = list()

	var/c_dir = get_dir(usr, target)
	for(var/i = -1 to 1)
		var/m_dir = turn(c_dir, i*90)
		var/T = get_turf(target)

		for(var/step_n = 1 to circle_radius)
			T = get_step(T, m_dir)

		points.Add(T)

	for(var/turf/T in points)
		if(!..(T, range, speed, override, fly_speed = 1))
			return
		if(istype(loc, /turf/space)) //Boomerangs don't work in space
			return

	..(original, range, speed, override, fly_speed = 1)

/obj/item/weapon/boomerang/throw_impact(atom/hit_atom, var/speed, user)
	if(iscarbon(hit_atom) && !isslime(hit_atom))
		if(user == hit_atom)
			var/mob/living/carbon/L = hit_atom

			if(L.get_active_hand() == null)
				to_chat(hit_atom, "<span class='info'>You catch \the [src]!</span>")
				L.put_in_active_hand(src)
				throwing = 0
				return

	return ..()
