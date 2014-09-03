/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	hitsound = "sound/weapons/whip.ogg"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 3
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked", "slapped", "whipped")

/obj/item/weapon/mop/New()
	. = ..()
	create_reagents(5)

/obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)
	reagents.reaction(A,1,10) //Mops magically make chems ten times more efficient than usual, aka equivalent of 50 units of whatever you're using
	A.clean_blood()
	for(var/obj/effect/O in A)
		if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
			del(O)

/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A))
		return

	if(istype(A, /mob/living))
		if(!(reagents.total_volume < 1)) //Slap slap slap
			A.visible_message("<span class='danger'>[user] covers [A] in the mop's contents</span>")
			reagents.reaction(A,1,10) //I hope you like my polyacid cleaner mix
			reagents.clear_reagents()

	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			user << "<span class='notice'>Your mop is dry!</span>"
			return
		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")
		if(do_after(user, 30))
			if(A)
				clean(get_turf(A))
				reagents.remove_any(1) //Might be a tad wonky with "special mop mixes", but fuck it
				user << "<span class='notice'>You have finished mopping \the [get_turf(A)]!</span>"
