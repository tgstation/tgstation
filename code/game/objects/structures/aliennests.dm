//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/stool/bed/nest/manual_unbuckle(mob/user as mob)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				buckled_mob.visible_message(\
					"<span class='notice'>[user.name] pulls [buckled_mob.name] free from the sticky nest!</span>",\
					"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
					"<span class='notice'>You hear squelching...</span>")
				buckled_mob.pixel_y = 0
				unbuckle()
			else
				buckled_mob.visible_message(\
					"<span class='warning'>[buckled_mob.name] struggles to break free of the gelatinous resin...</span>",\
					"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
					"<span class='notice'>You hear squelching...</span>")
				spawn(1200)
					if(user && buckled_mob && user.buckled == src)
						buckled_mob.pixel_y = 0
						unbuckle()
			src.add_fingerprint(user)
	return

/obj/structure/stool/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)
	if ( !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || usr.stat || M.buckled || istype(user, /mob/living/silicon/pai) )
		return

	if(istype(M,/mob/living/carbon/alien))
		return
	if(!istype(user,/mob/living/carbon/alien/humanoid))
		return

	unbuckle()

	if(M == usr)
		return
	else
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in the [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")
	M.buckled = src
	M.loc = src.loc
	M.dir = src.dir
	M.update_canmove()
	M.pixel_y = 6
	src.buckled_mob = M
	src.add_fingerprint(user)
	return

/obj/structure/stool/blob_act()
	del(src)

/obj/structure/stool/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	for(var/mob/M in viewers(src, 7))
		M.show_message("<span class='warning'>[user] hits [src] with [W]!</span>", 1)
	healthcheck()

/obj/structure/stool/bed/nest/proc/healthcheck()
	if(health <=0)
		density = 0
		del(src)
	return
