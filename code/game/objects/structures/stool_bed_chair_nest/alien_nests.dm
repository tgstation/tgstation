#define ALIEN_NEST_LOCKED_Y_OFFSET 6
//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100

/obj/structure/bed/nest/New()
	..()
	nest_locations += src

/obj/structure/bed/nest/Destroy()
	nest_locations -= src
	..()

/obj/structure/bed/nest/manual_unbuckle(mob/user as mob)
	if(locked_atoms.len)
		var/mob/M = locked_atoms[1]
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[user.name] pulls [M.name] free from the sticky nest!</span>",\
				"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
				"<span class='notice'>You hear squelching...</span>")
			unlock_atom(M)
			overlays.len = 0
		else
			M.visible_message(\
				"<span class='warning'>[M.name] struggles to break free of the gelatinous resin...</span>",\
				"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
				"<span class='notice'>You hear squelching...</span>")

			if(do_after(user,src,1200,60,needhand = FALSE))
				if(user && M && (user.locked_to == src))
					unlock_atom(M)
					overlays.len = 0
		src.add_fingerprint(user)

/obj/structure/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)
	if (locked_atoms.len || !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || user.stat || M.locked_to || istype(user, /mob/living/silicon/pai) )
		return

	if(ishuman(M) && M.client && !M.lying)
		to_chat(user,"<span class='warning'>You must tackle them down before you can trap them on \the [src]</span>")
		to_chat(M,"<span class='warning'>\The [user] is trying in vain to trap you on \the [src]</span>")
		return

	if(istype(M,/mob/living/carbon/alien))
		return
	if(!istype(user,/mob/living/carbon/alien/humanoid) && !istype(user,/mob/living/simple_animal/hostile/alien))
		return

	if(M == usr)
		return
	else
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into \the [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in \the [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")
	lock_atom(M, /datum/locking_category/bed/nest)
	src.add_fingerprint(user)
	overlays += image(icon,"nest-covering",MOB_LAYER)
	stabilize()

/obj/structure/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	user.visible_message("<span class='warning'>[user] hits \the [src] with \the [W]!</span>", \
						 "<span class='warning'>You hit \the [src] with \the [W]!</span>")
	user.delayNextAttack(10)
	healthcheck()

/obj/structure/bed/nest/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

/obj/structure/bed/nest/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/obj/structure/bed/nest/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/bed/nest/proc/stabilize()
	if(!locked_atoms || !locked_atoms.len)
		return

	var/mob/M = locked_atoms[1]

	if(iscarbon(M) && (M.stat != DEAD) && (M.reagents.get_reagent_amount("stabilizine") < 1))
		M.reagents.add_reagent("stabilizine", 2)
	else
		return

	spawn(15)
		if(!gcDestroyed && locked_atoms.len)
			stabilize()

#undef ALIEN_NEST_LOCKED_Y_OFFSET

/datum/locking_category/bed/nest
	pixel_y_offset = 6
