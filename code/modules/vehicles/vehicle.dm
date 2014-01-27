
//What do you know about Vehicles being chairs? That's what I thought - RR
//Place vehicle types with unique code here, use "functional_vehicles.dm" for types with no new code

//----------- SIMPLE, LAND VEHICLES -----------\\

/obj/structure/stool/bed/chair/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = ""
	anchored = 0
	density = 1
	desc = "it's just another vehicle..."
	var/spaceworthy = 0 //can it move in space?
	var/cannot_move_txt = "Your vehicle fails to move!" //What feedback the player recieves
	var/position = 1 //0 for inside, 1 for outside

/obj/structure/stool/bed/chair/vehicle/New()
	handle_rotation()


/obj/structure/stool/bed/chair/vehicle/examine()
	set src in usr
	usr << "[desc]"

/obj/structure/stool/bed/chair/vehicle/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle()

	if(isliving(user)) //Nothing else is likely to be riding vehicles

		var/mob/living/L = user
		var/Current_Location = get_turf(L)

		if(istype(Current_Location, /turf/space) && !spaceworthy)
			L << "<span class='userdanger'>[cannot_move_txt]</span>"
			return

	step(src, direction)
	update_mob()
	handle_rotation()

/obj/structure/stool/bed/chair/vehicle/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc


/obj/structure/stool/bed/chair/vehicle/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon))
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs [position ? "onto" : "into"] the [name]!</span>",\
		"<span class='notice'>You climb [position ? "onto" : "into"] the [name]!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)


/obj/structure/stool/bed/chair/vehicle/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()


/obj/structure/stool/bed/chair/vehicle/handle_rotation()
	if(position)
		if(dir == SOUTH)
			layer = FLY_LAYER
		else
			layer = OBJ_LAYER
	else
		layer = FLY_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/stool/bed/chair/vehicle/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir


/obj/structure/stool/bed/chair/vehicle/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		buckled_mob.bullet_act(Proj) //Cause the rider to use their normal Bullet_act by default


//----------- SPACE VEHICLES -----------\\

/obj/structure/stool/bed/chair/vehicle/space
	name = "Space vehicle"
	desc = "A space-worthy vehicle"
	icon_state = "engineering_pod"
	spaceworthy = 1

/obj/structure/stool/bed/chair/vehicle/space/New()
	handle_rotation()
	process_rider()

/obj/structure/stool/bed/chair/vehicle/space/proc/process_rider() //Unfinished, do not even think about it
	if(buckled_mob)
		if(spaceworthy)
			world << "Some dingus ([buckled_mob.name]) is trying to use unfinished code, tell them they're stupid"
			unbuckle()
			process_rider()
		else
			world << "Some dingus ([buckled_mob.name]) is trying to use unfinished code, tell them they're stupid"
			unbuckle()
			process_rider()
	else
		return // There's No rider, let's not bother processing them



