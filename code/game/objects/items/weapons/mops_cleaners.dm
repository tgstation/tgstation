/*
CONTAINS:
SPACE CLEANER
MOP

*/
/obj/item/weapon/cleaner/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 1000)

/obj/item/weapon/cleaner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/cleaner/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue Add more cleaner!"
		return

	var/obj/decal/D = new/obj/decal(get_turf(src))
	D.name = "chemicals"
	D.icon = 'chemical.dmi'
	D.icon_state = "chempuff"
	D.create_reagents(10)
	src.reagents.trans_to(D, 10)
	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	spawn(0)
		for(var/i=0, i<3, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)
			sleep(3)
		del(D)

	return

/obj/item/weapon/cleaner/examine()
	set src in usr
	usr << text("\icon[] [] units of cleaner left!", src, src.reagents.total_volume)
	..()
	return

// MOP

/obj/item/weapon/mop/New()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if (src.reagents.total_volume < 1 || mopcount >= 5)
		user << "\blue Your mop is dry!"
		return

	if (istype(A, /turf/simulated))
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red <B>[] begins to clean []</B>", user, A), 1)
		sleep(40)
		user << "\blue You have finished mopping!"
		src.reagents.reaction(A,1,10)
		A.clean_blood()
		for(var/obj/rune/R in A)
			del(R)
		mopcount++
	else if (istype(A, /obj/decal/cleanable/blood) || istype(A, /obj/overlay) || istype(A, /obj/decal/cleanable/xenoblood) || istype(A, /obj/rune) )
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red <B>[user] begins to clean [A]</B>"), 1)
		sleep(20)
		user << "\blue You have finished mopping!"
		var/turf/U = A.loc
		src.reagents.reaction(U)
		if(A) del(A)
		mopcount++

	if(mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
		spawn(5)
			src.reagents.clear_reagents()
			mopcount = 0

	return