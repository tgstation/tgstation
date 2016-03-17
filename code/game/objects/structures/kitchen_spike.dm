//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = 1
	anchored = 0

/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.get_amount() >= 4)
			R.use(4)
			user << "<span class='notice'>You add spikes to the frame.</span>"
			var/obj/F = new /obj/structure/kitchenspike(src.loc,)
			transfer_fingerprints_to(F)
			qdel(src)

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	buckle_lying = 0
	can_buckle = 1


/obj/structure/kitchenspike/attack_paw(mob/user)
	return src.attack_hand(usr)


/obj/structure/kitchenspike/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		if(!buckled_mobs.len)
			playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
			if(do_after(user, 20/I.toolspeed, target = src))
				user << "<span class='notice'>You pry the spikes out of the frame.</span>"
				new /obj/item/stack/rods(loc, 4)
				var/obj/F = new /obj/structure/kitchenspike_frame(src.loc,)
				transfer_fingerprints_to(F)
				qdel(src)
		else
			user << "<span class='notice'>You can't do that while something's on the spike!</span>"
		return
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(istype(G.affecting, /mob/living/))
			if(!buckled_mobs.len)
				if(do_mob(user, src, 120))
					if(buckled_mobs.len) //to prevent spam/queing up attacks
						return
					if(G.affecting.buckled)
						return
					var/mob/living/H = G.affecting
					playsound(src.loc, "sound/effects/splat.ogg", 25, 1)
					H.visible_message("<span class='danger'>[user] slams [G.affecting] onto the meat spike!</span>", "<span class='userdanger'>[user] slams you onto the meat spike!</span>", "<span class='italics'>You hear a squishy wet noise.</span>")
					H.loc = src.loc
					H.emote("scream")
					if(istype(H, /mob/living/carbon/human)) //So you don't get human blood when you spike a giant spidere
						var/turf/pos = get_turf(H)
						pos.add_blood_floor(H)
					H.adjustBruteLoss(30)
					H.buckled = src
					H.dir = 2
					buckle_mob(H, force=1)
					var/matrix/m180 = matrix(H.transform)
					m180.Turn(180)
					animate(H, transform = m180, time = 3)
					H.pixel_y = H.get_standard_pixel_y_offset(180)
					qdel(G)
					return
		user << "<span class='danger'>You can't use that on the spike!</span>"
		return
	..()

/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(buckled_mob)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"[user.name] tries to pull [M.name] free of the [src]!",\
				"<span class='notice'>[user.name] is trying to pull you off the [src], opening up fresh wounds!</span>",\
				"<span class='italics'>You hear a squishy wet noise.</span>")
			if(!do_after(user, 300, target = src))
				if(M && M.buckled)
					M.visible_message(\
					"[user.name] fails to free [M.name]!",\
					"<span class='notice'>[user.name] fails to pull you off of the [src].</span>")
				return

		else
			M.visible_message(\
			"<span class='warning'>[M.name] struggles to break free from the [src]!</span>",\
			"<span class='notice'>You struggle to break free from the [src], exacerbating your wounds! (Stay still for two minutes.)</span>",\
			"<span class='italics'>You hear a wet squishing noise..</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					M << "<span class='warning'>You fail to free yourself!</span>"
				return
		if(!M.buckled)
			return
		var/matrix/m180 = matrix(M.transform)
		m180.Turn(180)
		animate(M, transform = m180, time = 3)
		M.pixel_y = M.get_standard_pixel_y_offset(180)
		M.adjustBruteLoss(30)
		src.visible_message(text("<span class='danger'>[M] falls free of the [src]!</span>"))
		unbuckle_mob(M,force=1)
		M.emote("scream")
		M.AdjustWeakened(10)
