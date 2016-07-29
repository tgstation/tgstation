<<<<<<< HEAD
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
	else
		return ..()

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
		if(!has_buckled_mobs())
			playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
			if(do_after(user, 20/I.toolspeed, target = src))
				user << "<span class='notice'>You pry the spikes out of the frame.</span>"
				new /obj/item/stack/rods(loc, 4)
				var/obj/F = new /obj/structure/kitchenspike_frame(src.loc,)
				transfer_fingerprints_to(F)
				qdel(src)
		else
			user << "<span class='notice'>You can't do that while something's on the spike!</span>"
	else
		return ..()

/obj/structure/kitchenspike/attack_hand(mob/user)
	if(isliving(user.pulling) && user.a_intent == "grab" && !has_buckled_mobs())
		var/mob/living/L = user.pulling
		if(do_mob(user, src, 120))
			if(has_buckled_mobs()) //to prevent spam/queing up attacks
				return
			if(L.buckled)
				return
			playsound(src.loc, "sound/effects/splat.ogg", 25, 1)
			L.visible_message("<span class='danger'>[user] slams [L] onto the meat spike!</span>", "<span class='userdanger'>[user] slams you onto the meat spike!</span>", "<span class='italics'>You hear a squishy wet noise.</span>")
			L.loc = src.loc
			L.emote("scream")
			L.add_splatter_floor()
			L.adjustBruteLoss(30)
			L.buckled = src
			L.setDir(2)
			buckle_mob(L, force=1)
			var/matrix/m180 = matrix(L.transform)
			m180.Turn(180)
			animate(L, transform = m180, time = 3)
			L.pixel_y = L.get_standard_pixel_y_offset(180)
	else if (has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			user_unbuckle_mob(L, user)
	else
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
=======
//////Kitchen Spike

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1

	var/mob/living/occupant = null
	var/meat_remaining = 0

	var/list/allowed_mobs = list(
		/mob/living/carbon/monkey/diona = "spikebloodynymph",
		/mob/living/carbon/monkey = "spikebloody",
		/mob/living/carbon/alien = "spikebloodygreen",
		/mob/living/simple_animal/hostile/alien = "spikebloodygreen"
		) //Associated with icon states

/obj/structure/kitchenspike/attack_paw(mob/user as mob)
	return src.attack_hand(usr)

/obj/structure/kitchenspike/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (iswrench(W))
		if(occupant)
			to_chat(user, "<span class='warning'>You can't disassemble [src] with meat and gore all over it.</span>")
			return
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 2
		qdel(src)
		return

	if(istype(W,/obj/item/weapon/grab))
		return handleGrab(W,user)

/obj/structure/kitchenspike/proc/handleGrab(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!istype(G))
		return

	var/mob/living/our_mob = G.affecting
	if(!istype(our_mob)) return

	if(occupant)
		to_chat(user, "<span class='warning'>[occupant.name] is already hanging from \the [src], finish collecting its meat first!</span>")
		return

	for(var/T in allowed_mobs)
		if(istype(our_mob, T))
			if(our_mob.abiotic())
				to_chat(user, "<span class='warning'>Subject may not have abiotic items on.</span>")
				return
			else
				src.occupant = our_mob

				if(allowed_mobs[T])
					src.icon_state = allowed_mobs[T]
				else
					src.icon_state = "spikebloody"

				src.meat_remaining = 1 + our_mob.size - our_mob.meat_taken

				user.visible_message("<span class='warning'>[user] has forced [our_mob] onto the spike, killing it instantly!</span>")

				our_mob.death(0)
				our_mob.ghostize()

				our_mob.forceMove(src)
				if(iscarbon(our_mob))
					var/mob/living/carbon/C = our_mob
					C.drop_stomach_contents()
					user.visible_message("<span class='warning'>\The [C]'s stomach contents drop to the ground!</span>")

				returnToPool(G)
				return

/obj/structure/kitchenspike/attack_hand(mob/user as mob)
	if(..())
		return

	if(src.occupant)
		if(src.meat_remaining > 0)
			src.meat_remaining--
			src.occupant.drop_meat(get_turf(src))

			if(src.meat_remaining)
				to_chat(user, "You remove some meat from \the [src.occupant].")
			else
				to_chat(user, "You remove the last piece of meat from \the [src]!")
				src.clean()
	else
		src.clean()

/obj/structure/kitchenspike/proc/clean()
	icon_state = initial(icon_state)
	if(occupant)
		qdel(occupant)
		occupant = null
	meat_remaining = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
