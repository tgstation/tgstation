//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/obj/smooth_structures/alien/nest.dmi'
	icon_state = "nest"
	var/health = 100
	smooth = SMOOTH_TRUE
	can_be_unanchored = 0
	canSmoothWith = null
	buildstacktype = null
	var/image/nest_overlay

/obj/structure/bed/nest/New()
	nest_overlay = image('icons/mob/alien.dmi', "nestoverlay", layer=MOB_LAYER - 0.2)
	return ..()

/obj/structure/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(buckled_mobs.len)
		for(var/buck in buckled_mobs) //breaking a nest releases all the buckled mobs, because the nest isn't holding them down anymore
			var/mob/living/M = buck

			if(user.getorgan(/obj/item/organ/internal/alien/plasmavessel))
				unbuckle_mob(M)
				add_fingerprint(user)
				return

			if(M != user)
				M.visible_message(\
					"[user.name] pulls [M.name] free from the sticky nest!",\
					"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
					"<span class='italics'>You hear squelching...</span>")
			else
				M.visible_message(\
					"<span class='warning'>[M.name] struggles to break free from the gelatinous resin!</span>",\
					"<span class='notice'>You struggle to break free from the gelatinous resin... (Stay still for two minutes.)</span>",\
					"<span class='italics'>You hear squelching...</span>")
				if(!do_after(M, 1200, target = src))
					if(M && M.buckled)
						M << "<span class='warning'>You fail to unbuckle yourself!</span>"
					return
				if(!M.buckled)
					return
				M.visible_message(\
					"<span class='warning'>[M.name] breaks free from the gelatinous resin!</span>",\
					"<span class='notice'>You break free from the gelatinous resin!</span>",\
					"<span class='italics'>You hear squelching...</span>")

			unbuckle_mob(M)
			add_fingerprint(user)

/obj/structure/bed/nest/user_buckle_mob(mob/living/M, mob/living/user)
	if ( !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.incapacitated() || M.buckled )
		return

	if(M.getorgan(/obj/item/organ/internal/alien/plasmavessel))
		return
	if(!user.getorgan(/obj/item/organ/internal/alien/plasmavessel))
		return

	if(buckled_mobs.len)
		unbuckle_all_mobs()

	if(buckle_mob(M))
		M.visible_message(\
			"[user.name] secretes a thick vile goo, securing [M.name] into [src]!",\
			"<span class='danger'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='italics'>You hear squelching...</span>")

/obj/structure/bed/nest/post_buckle_mob(mob/living/M)
	if(M in buckled_mobs)
		M.pixel_y = 0
		M.pixel_x = initial(M.pixel_x) + 2
		M.layer = MOB_LAYER - 0.3
		overlays += nest_overlay
	else
		M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)
		M.layer = initial(M.layer)
		overlays -= nest_overlay

/obj/structure/bed/nest/attackby(obj/item/weapon/W, mob/user, params)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	visible_message("<span class='danger'>[user] hits [src] with [W]!</span>")
	healthcheck()

/obj/structure/bed/nest/proc/healthcheck()
	if(health <=0)
		density = 0
		qdel(src)
	return
