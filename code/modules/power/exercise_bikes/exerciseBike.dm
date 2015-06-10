
/obj/machinery/power/exercise_bike
	name = "exercise bike"
	desc = "A Nanotrasen brand exercise bike, it produces power too!"
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	density = 0
	anchored = 1
	use_power = 0
	can_buckle = 1
	buckle_lying = 0
	var/produced_power = 1250
	var/required_dir = EAST //which button to press to pedal, Alternates WEST/EAST, A/D or arrow keys

/obj/machinery/power/exercise_bike/orderable
	anchored = 0

/obj/machinery/power/exercise_bike/New()
	..()

	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER


//Fixes dodgy inherited attack_hand()
/obj/machinery/power/exercise_bike/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)


/obj/machinery/power/exercise_bike/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/wrench))
		if(!isinspace())
			anchored = !anchored
			user << "<span class='notice'>You [anchored ? "secure":"unsecure"] the exercise bike [anchored ? "to":"from"] the floor.</span>"

			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


/obj/machinery/power/exercise_bike/relaymove(mob/living/user, direction)
	if(user != buckled_mob || !istype(user))
		return

	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()

	if(!anchored)
		user << "<span class='notice'>Secure the exercise bike to the floor before pedalling.</span>"
		return

	if(direction == required_dir)
		user.nutrition = max(user.nutrition - 2, 0)
		add_avail(produced_power)
		switch(required_dir)
			if(EAST)
				required_dir = WEST
				world << "PRESS WEST"
			else
				required_dir = EAST
				world << "PRESS EAST"

	update_visuals()


/obj/machinery/power/exercise_bike/post_buckle_mob(mob/living/M)
	update_visuals()


/obj/machinery/power/exercise_bike/unbuckle_mob()
	var/mob/living/M = ..()
	if(M)
		M.pixel_x = initial(M.pixel_x)
		M.pixel_y = initial(M.pixel_y)
	return M


/obj/machinery/power/exercise_bike/proc/update_visuals()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(NORTH)
				buckled_mob.pixel_y = 4
			else
				buckled_mob.pixel_y = 7