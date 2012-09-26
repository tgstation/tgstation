/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0


/obj/item/weapon/mop/New()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src


obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)
	reagents.reaction(A,1,10)
	A.clean_blood()
	for(var/obj/effect/O in A)
		if( istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay) )
			del(O)


/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()


/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if(reagents.total_volume < 1 || mopcount >= 5)
		user << "<span class='notice'>Your mop is dry!</span>"
		return

	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")
		if(do_after(user, 40))
			if(A)
				clean(get_turf(A))
			user << "<span class='notice'>You have finished mopping!</span>"
			mopcount++

	if(mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
		spawn(5)
			reagents.clear_reagents()
			mopcount = 0
	return