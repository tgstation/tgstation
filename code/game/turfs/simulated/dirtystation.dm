//Janitors!  Janitors, janitors, janitors!  -Sayu


//Conspicuously not-recent versions of suspicious cleanables

//This file was made not awful by Xhuis on September 13, 2016

/obj/effect/decal/cleanable/blood/old
	name = "dried blood"
	desc = "Looks like it's been here a while.  Eew."
	bloodiness = 0

/obj/effect/decal/cleanable/blood/old/New()
	..()
	icon_state += "-old" //This IS necessary because the parent /blood type uses icon randomization.
	blood_DNA["Non-human DNA"] = "A+"

/obj/effect/decal/cleanable/blood/gibs/old
	name = "old rotting gibs"
	desc = "Space Jesus, why didn't anyone clean this up?  It smells terrible."
	bloodiness = 0

/obj/effect/decal/cleanable/blood/gibs/old/New()
	..()
	setDir(pick(1,2,4,8))
	icon_state += "-old"
	blood_DNA["Non-human DNA"] = "A+"

/obj/effect/decal/cleanable/vomit/old
	name = "crusty dried vomit"
	desc = "You try not to look at the chunks, and fail."

/obj/effect/decal/cleanable/vomit/old/New()
	..()
	icon_state += "-old"

/obj/effect/decal/cleanable/robot_debris/old
	name = "dusty robot debris"
	desc = "Looks like nobody has touched this in a while."

//Making the station dirty, one tile at a time. Called by master controller's setup_objects

/turf/open/floor/proc/MakeDirty()
	if(prob(66))	//fastest possible exit 2/3 of the time
		return

	if(!(flags & CAN_BE_DIRTY))
		return

	if(locate(/obj/structure/grille) in contents)
		return

	var/area/A = get_area(src)

	if(A && !(A.flags & CAN_BE_DIRTY))
		return

	//The code below here isn't exactly optimal, but because of the individual decals that each area uses it's still applicable.

				//high dirt - 1/3
	if(istype(A, /area/toxins/test_area) || istype(A, /area/mine/production) || istype(A, /area/mine/living_quarters) || istype(A, /area/mine/north_outpost) || istype(A, /area/mine/west_outpost) || istype(A, /area/wreck) || istype(A, /area/derelict) || istype(A, /area/djstation))
		new /obj/effect/decal/cleanable/dirt(src)	//vanilla, but it works
		return

	if(prob(80))	//mid dirt  - 1/15
		return

	if(istype(A, /area/engine) || istype(A,/area/assembly) || istype(A,/area/maintenance) || istype(A,/area/construction))
	 	//Blood, sweat, and oil.  Oh, and dirt.
		if(prob(3))
			new /obj/effect/decal/cleanable/blood/old(src)
		else
			if(prob(35))
				if(prob(4))
					new /obj/effect/decal/cleanable/robot_debris/old(src)
				else
					new /obj/effect/decal/cleanable/oil(src)
			else
				new /obj/effect/decal/cleanable/dirt(src)
		return

	if(istype(A, /area/crew_quarters/toilet) || istype(A, /area/crew_quarters/locker/locker_toilet))
		if(prob(40))
			if(prob(90))
				new /obj/effect/decal/cleanable/vomit/old(src)
			else
				new /obj/effect/decal/cleanable/blood/old(src)
		return

	if(istype(A, /area/quartermaster))
		if(prob(25))
			new /obj/effect/decal/cleanable/oil(src)
		return

	if(prob(75))	//low dirt  - 1/60
		return

	if(istype(A, /area/ai_monitored/turret_protected) || istype(A, /area/security))	//chance of incident
		if(prob(20))
			if(prob(5))
				new /obj/effect/decal/cleanable/blood/gibs/old(src)
			else
				new /obj/effect/decal/cleanable/blood/old(src)
		return


	if(istype(A, /area/crew_quarters/kitchen))	//Kitchen messes
		if(prob(60))
			if(prob(50))
				new /obj/effect/decal/cleanable/egg_smudge(src)
			else
				new /obj/effect/decal/cleanable/flour(src)
		return

	if(istype(A, /area/medical))	//Kept clean, but chance of blood
		if(prob(66))
			if(prob(5))
				new /obj/effect/decal/cleanable/blood/gibs/old(src)
			else
				new /obj/effect/decal/cleanable/blood/old(src)
		else if(prob(30))
			if(istype(A, /area/medical/morgue))
				new /obj/item/weapon/ectoplasm(src)
			else
				new /obj/effect/decal/cleanable/vomit/old(src)
		return

	if(istype(A, /area/toxins))
		if(prob(20))
			new /obj/effect/decal/cleanable/greenglow(src)	//this cleans itself up but it might startle you when you see it.
		return

	return TRUE
