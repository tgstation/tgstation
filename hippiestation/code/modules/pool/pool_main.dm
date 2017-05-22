/turf/open/pool
	icon = 'hippiestation/icons/turf/pool.dmi'
	var/filled = TRUE
	name = "poolwater"
	desc = "You're safer here than in the deep."
	icon_state = "deep"
	var/splashed = 0
	var/obj/effect/overlay/water/watereffect

/turf/open/pool/proc/update_icon()
	if(!filled)
		name = "drained pool"
		desc = "No diving!"
		qdel(watereffect)
		watereffect = null
		icon_state = "drained"
	else
		name = "poolwater"
		desc = "You're safer here than in the deep."
		icon_state = "deep"
		watereffect = new /obj/effect/overlay/water(src)

/obj/effect/overlay/water
	name = "Water"
	icon = 'hippiestation/icons/turf/pool.dmi'
	icon_state = "overlay"
	density = 0
	mouse_opacity = 0
	layer = ABOVE_MOB_LAYER
	anchored = 1


/mob/var/swimming = 0

//Put people out of the water
/turf/open/floor/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(isobserver(usr))
		return
	if(user.stat || user.lying || !Adjacent(user) || !M.Adjacent(user)|| !iscarbon(M))
		if(issilicon(M))
			var/turf/T = get_turf(M)
			if(istype(T, /turf/open/pool))
				M.visible_message("<span class='notice'>[M] begins to float.", \
					"<span class='notice'>You start your emergency floaters.</span>")
				if(do_mob(user, M, 20))
					M.forceMove(src)
					to_chat(user, "<span class='notice'>You get out of the pool.</span>")
		return ..()
	if(!M.swimming) //can't put yourself up if you are not swimming
		return ..()
	if(user == M)
		M.visible_message("<span class='notice'>[user] is getting out the pool", \
						"<span class='notice'>You start getting out of the pool.</span>")
		if(do_mob(user, M, 20))
			M.swimming = FALSE
			M.forceMove(src)
			to_chat(user, "<span class='notice'>You get out of the pool.</span>")
	else
		user.visible_message("<span class='notice'>[M] is being pulled to the poolborder by [user].</span>", \
						"<span class='notice'>You start getting [M] out of the pool.")
		if(do_mob(user, M, 20))
			M.swimming = FALSE
			M.forceMove(src)
			to_chat(user, "<span class='notice'>You get [M] out of the pool.</span>")
			return

/turf/open/floor/CanPass(atom/movable/A, turf/T)
	if(!has_gravity(src))
		return ..()
	else if(istype(A, /mob/living) || istype(A, /obj/structure)) //This check ensures that only specific types of objects cannot pass into the water. Items will be able to get tossed out.
		if(istype(A, /mob/living/simple_animal) || istype(A, /mob/living/carbon/monkey))
			return ..()
		if (istype(A, /obj/structure) && istype(A.pulledby, /mob/living/carbon/human))
			return ..()
		if(istype(get_turf(A), /turf/open/pool) && !istype(T, /turf/open/pool)) //!(locate(/obj/structure/pool/ladder) in get_turf(A).loc)
			return 0
	return ..()

/turf/open/pool/Initialize()
	..()
	watereffect = new /obj/effect/overlay/water(src)

/turf/open/pool/ex_act(severity, target)
	return

/turf/open/pool/proc/wash_mob(mob/living/L)
	L.wash_cream()
	L.ExtinguishMob()
	L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = 1
		for(var/obj/item/I in M.held_items)
			I.clean_blood()
		if(M.back)
			if(M.back.clean_blood())
				M.update_inv_back(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/washgloves = 1
			var/washshoes = 1
			var/washmask = 1
			var/washears = 1
			var/washglasses = 1

			if(H.wear_suit)
				washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
				washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

			if(H.head)
				washmask = !(H.head.flags_inv & HIDEMASK)
				washglasses = !(H.head.flags_inv & HIDEEYES)
				washears = !(H.head.flags_inv & HIDEEARS)

			if(H.wear_mask)
				if (washears)
					washears = !(H.wear_mask.flags_inv & HIDEEARS)
				if (washglasses)
					washglasses = !(H.wear_mask.flags_inv & HIDEEYES)

			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head()
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit()
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform()
			if(washgloves)
				H.clean_blood()
			if(H.shoes && washshoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes()
			if(H.wear_mask)
				if(washmask)
					if(H.wear_mask.clean_blood())
						H.update_inv_wear_mask()
			else
				H.lip_style = null
				H.update_body()
			if(H.glasses && washglasses)
				if(H.glasses.clean_blood())
					H.update_inv_glasses()
			if(H.ears && washears)
				if(H.ears.clean_blood())
					H.update_inv_ears()
			if(H.belt)
				if(H.belt.clean_blood())
					H.update_inv_belt()
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				if(M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
			M.clean_blood()
	else
		L.clean_blood()

//put people in water, including you
/turf/open/pool/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!has_gravity(src))
		return
	if(user.stat || user.lying || !Adjacent(user) || !M.Adjacent(user)|| !iscarbon(M))
		return
	if(!iscarbon(user)) // no silicons or drones in mechas.
		return
	if(M.swimming == 1) //can't lower yourself again
		return
	else
		if(user == M)
			M.visible_message("<span class='notice'>[user] is descending in the pool", \
							"<span class='notice'>You start lowering yourself in the pool.</span>")
			if(do_mob(user, M, 20))
				M.swimming = 1
				M.forceMove(src)
				to_chat(user, "<span class='notice'>You lower yourself in the pool.</span>")
		else
			user.visible_message("<span class='notice'>[M] is being put in the pool by [user].</span>", \
							"<span class='notice'>You start lowering [M] in the pool.")
			if(do_mob(user, M, 20))
				M.swimming = 1
				M.forceMove(src)
				to_chat(user, "<span class='notice'>You lower [M] in the pool.</span>")
				return

//What happens if you don't drop in it like a good person would, you fool.
/turf/open/pool/Exited(atom/A, turf/NL)
	..()
	if(!istype(NL, /turf/open/pool) && isliving(A))
		var/mob/living/M = A
		M.swimming = FALSE

/turf/open/pool/Entered(atom/A, turf/OL)
	..()
	if(isliving(A))
		var/mob/living/M = A
		if(!M.mob_has_gravity())
			return
		if(!M.swimming)
			if(locate(/obj/structure/pool/ladder) in M.loc)
				M.swimming = TRUE
				return
			if(iscarbon(M))
				var/mob/living/carbon/H = M
				if(filled)
					wash_mob(H)
					if (H.wear_mask && H.wear_mask.flags & MASKCOVERSMOUTH)
						H.visible_message("<span class='danger'>[H] falls in the water!</span>",
											"<span class='userdanger'>You fall in the water!</span>")
						playsound(src, 'hippiestation/sound/effects/splash.ogg', 60, 1, 1)
						H.Weaken(1)
						H.swimming = 1
						return
					else
						H.drop_item()
						H.adjustOxyLoss(5)
						H.emote("cough")
						H.visible_message("<span class='danger'>[H] falls in and takes a drink!</span>",
											"<span class='userdanger'>You fall in and swallow some water!</span>")
						playsound(src, 'hippiestation/sound/effects/splash.ogg', 60, 1, 1)
						H.Weaken(3)
						H.swimming = 1
				else if(!istype(H.head, /obj/item/clothing/head/helmet))
					if(prob(75))
						H.visible_message("<span class='danger'>[H] falls in the drained pool!</span>",
													"<span class='userdanger'>You fall in the drained pool!</span>")
						H.adjustBruteLoss(7)
						H.Weaken(4)
						H.swimming = TRUE
						playsound(src, 'sound/effects/woodhit.ogg', 60, 1, 1)
					else
						H.visible_message("<span class='danger'>[H] falls in the drained pool, and cracks his skull!</span>",
													"<span class='userdanger'>You fall in the drained pool, and crack your skull!</span>")
						H.apply_damage(15, BRUTE, "head")
						H.Weaken(10) // This should hurt. And it does.
						H.adjustBrainLoss(30) //herp
						H.swimming = TRUE
						playsound(src, 'sound/effects/woodhit.ogg', 60, 1, 1)
						playsound(src, 'hippiestation/sound/misc/crack.ogg', 100, 1)
				else
					H.visible_message("<span class='danger'>[H] falls in the drained pool, but had an helmet!</span>",
										"<span class='userdanger'>You fall in the drained pool, but you had an helmet!</span>")
					H.Weaken(2)
					H.swimming = TRUE
					playsound(src, 'sound/effects/woodhit.ogg', 60, 1, 1)
		else if(filled)
			wash_mob(M)
			M.adjustStaminaLoss(1)
			playsound(src, pick('hippiestation/sound/effects/water_wade1.ogg','hippiestation/sound/effects/water_wade2.ogg','hippiestation/sound/effects/water_wade3.ogg','hippiestation/sound/effects/water_wade4.ogg'), 20, 1)
			return

/obj/structure/pool
	name = "pool"
	icon = 'hippiestation/icons/turf/pool.dmi'
	anchored = 1
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/structure/pool/ladder
	name = "Ladder"
	icon_state = "ladder"
	desc = "Are you getting in or are you getting out?."
	layer = 5.1
	dir=4

/obj/structure/pool/ladder/attack_hand(mob/user as mob)
	if(Adjacent(user) && user.y == src.y && user.swimming == 0)
		user.swimming = 1
		user.forceMove(get_step(user, get_dir(user, src))) //Either way, you're getting IN or OUT of the pool.
	else if(user.loc == src.loc && user.swimming == 1)
		user.swimming = 0
		user.forceMove(get_step(user, reverse_direction(dir)))

/obj/structure/pool/Rboard
	name = "JumpBoard"
	density = 0
	icon_state = "boardright"
	desc = "The less-loved portion of the jumping board."
	dir = 4

/obj/structure/pool/Rboard/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSGLASS))
		return TRUE
	if(get_dir(O.loc, target) == dir)
		return FALSE
	return TRUE

/obj/structure/pool/Lboard
	name = "JumpBoard"
	icon_state = "boardleft"
	desc = "Get on there to jump!"
	layer = 5
	dir = 8
	var/jumping = FALSE
	var/timer

/obj/structure/pool/Lboard/proc/backswim(obj/O as obj, mob/user as mob) //Puts the sprite back to it's maiden condition after a jump.
	if(jumping)
		for(var/mob/jumpee in src.loc) //hackzors.
			playsound(jumpee, 'hippiestation/sound/effects/splash.ogg', 60, 1, 1)
			jumpee.layer = 4
			jumpee.pixel_x = 0
			jumpee.pixel_y = 0
			jumpee.stunned = 1
			jumpee.swimming = TRUE

/obj/structure/pool/Lboard/attack_hand(mob/user as mob)
	if(iscarbon(user))
		var/mob/living/carbon/jumper = user
		if(jumping)
			to_chat(user, "<span class='notice'>Someone else is already making a jump!</span>")
			return
		var/turf/T = get_turf(src)
		if(user.swimming)
			return
		else
			for(var/obj/machinery/poolcontroller/pc in range(4,src)) //Clunky as fuck I know.
				if(pc.timer > 44) //if it's draining/filling, don't allow.
					to_chat(user,"<span class='notice'>This is not a good idea.</span>")
					return
				if(pc.drained == 1)
					to_chat(user, "<span class='notice'>That would be suicide</span>")
					return
			if(Adjacent(jumper))
				jumper.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
									 "<span class='notice'>You climb up \the [src] and prepares to jump!</span>")
				jumper.canmove = FALSE
				jumper.stunned = 4
				jumping = TRUE
				jumper.layer = 5.1
				jumper.pixel_x = 3
				jumper.pixel_y = 7
				jumper.dir=8
				spawn(1) //somehow necessary
					jumper.loc = T
					jumper.stunned = 4
					spawn(10)
						switch(rand(1, 100))
							if(1 to 20)
								jumper.visible_message("<span class='notice'>[user] goes for a small dive!</span>", \
													 "<span class='notice'>You go for a small dive.</span>")
								sleep(15)
								backswim()
								var/atom/throw_target = get_edge_target_turf(src, dir)
								jumper.throw_at(throw_target, 1, 1)

							if(21 to 40)
								jumper.visible_message("<span class='notice'>[user] goes for a dive!</span>", \
													 "<span class='notice'>You're going for a dive!</span>")
								sleep(20)
								backswim()
								var/atom/throw_target = get_edge_target_turf(src, dir)
								jumper.throw_at(throw_target, 2, 1)

							if(41 to 60)
								jumper.visible_message("<span class='notice'>[user] goes for a long dive! Stay far away!</span>", \
										"<span class='notice'>You're going for a long dive!!</span>")
								sleep(25)
								backswim()
								var/atom/throw_target = get_edge_target_turf(src, dir)
								jumper.throw_at(throw_target, 3, 1)

							if(61 to 80)
								jumper.visible_message("<span class='notice'>[user] goes for an awesome dive! Don't stand in \his way!</span>", \
													 "<span class='notice'>You feel like this dive will be awesome</span>")
								sleep(30)
								backswim()
								var/atom/throw_target = get_edge_target_turf(src, dir)
								jumper.throw_at(throw_target, 4, 1)
							if(81 to 91)
								sleep(20)
								backswim()
								jumper.visible_message("<span class='danger'>[user] misses \his step!</span>", \
												 "<span class='userdanger'>You misstep!</span>")
								var/atom/throw_target = get_edge_target_turf(src, dir)
								jumper.throw_at(throw_target, 0, 1)
								jumper.Weaken(5)
								jumper.adjustBruteLoss(10)

							if(91 to 100)
								jumper.visible_message("<span class='notice'>[user] is preparing for the legendary dive! Can he make it?</span>", \
													 "<span class='userdanger'>You start preparing for a legendary dive!</span>")
								jumper.SpinAnimation(7,1)

								sleep(30)
								if(prob(75))
									backswim()
									jumper.visible_message("<span class='notice'>[user] fails!</span>", \
											 "<span class='userdanger'>You can't quite do it!</span>")
									var/atom/throw_target = get_edge_target_turf(src, dir)
									jumper.throw_at(throw_target, 1, 1)
								else
									jumper.fire_stacks = min(1,jumper.fire_stacks + 1)
									jumper.IgniteMob()
									sleep(5)
									backswim()
									jumper.visible_message("<span class='danger'>[user] bursts into flames of pure awesomness!</span>", \
										 "<span class='userdanger'>No one can stop you now!</span>")
									var/atom/throw_target = get_edge_target_turf(src, dir)
									jumper.throw_at(throw_target, 6, 1)
						jumper.canmove = TRUE
						spawn(35)
							jumping = FALSE
			else
				return

/turf/open/pool/attack_hand(mob/user)
	if(!user.stat && !user.lying && Adjacent(user) && user.swimming && filled && !src.splashed) //not drained, user alive and close, and user in water.
		if(user.x == src.x && user.y == src.y)
			return
		else
			playsound(src, 'hippiestation/sound/effects/watersplash.ogg', 8, 1, 1)
			src.splashed = TRUE
			var/obj/effect/splash/S = new /obj/effect/splash(user.loc)
			animate(S, alpha = 0,  time = 8)
			S.Move(src)
			spawn(20)
				qdel(S)
				spawn(5)
					src.splashed = FALSE //Otherwise, infinite splash party.

			for(var/mob/living/carbon/human/L in src)
				if(!L.wear_mask && !user.stat) //Do not affect those underwater or dying.
					L.emote("cough")
				L.adjustStaminaLoss(4) //You need to give em a break!

/turf/open/pool/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/mop) && filled)
		W.reagents.add_reagent("water", 5)
		to_chat(user, "<span class='notice'>You wet [W] in [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/effect/splash
	name = "splash"
	desc = "Wataaa!."
	icon = 'hippiestation/icons/turf/pool.dmi'
	icon_state = "splash"
	layer = MOB_LAYER + 0.1

/proc/reverse_direction(var/dir) // Could not find an equivalent in this new TGcode.
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST
