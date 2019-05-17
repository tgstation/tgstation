/turf/open/pool
	icon = 'icons/turf/pool.dmi'
	name = "poolwater"
	desc = "You're safer here than in the deep."
	icon_state = "pool_tile"
	heat_capacity = INFINITY
	var/filled = TRUE
	var/next_splash = 1
	var/obj/effect/overlay/water/watereffect
	var/obj/effect/overlay/water/top/watertop
	var/obj/machinery/poolcontroller/controller


/turf/open/pool/Initialize()
	watereffect = new /obj/effect/overlay/water(src)
	watertop = new /obj/effect/overlay/water/top(src)
	. = ..()

/turf/open/pool/Destroy()
	QDEL_NULL(watereffect)
	QDEL_NULL(watertop)
	controller = null
	return ..()

/turf/open/pool/proc/update_icon()
	if(!filled)
		name = "drained pool"
		desc = "No diving!"
		QDEL_NULL(watereffect)
		QDEL_NULL(watertop)
	else
		name = "poolwater"
		desc = "You're safer here than in the deep."
		watereffect = new /obj/effect/overlay/water(src)
		watertop = new /obj/effect/overlay/water/top(src)

/obj/effect/overlay/water
	name = "water"
	icon = 'icons/turf/pool.dmi'
	icon_state = "bottom"
	density = 0
	mouse_opacity = 0
	layer = ABOVE_MOB_LAYER
	anchored = TRUE

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = BELOW_MOB_LAYER

/mob/living
	var/swimming = FALSE

//Put people out of the water
/turf/open/floor/MouseDrop_T(mob/living/M, mob/living/user)
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
			return FALSE
	return ..()

/turf/open/pool/ex_act(severity, target)
	return
	
/turf/open/pool/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	if(isitem(O))
		var/obj/item/I = O
		I.acid_level = 0
		I.extinguish()

/turf/open/pool/proc/wash_mob(mob/living/L)
	SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	L.wash_cream()
	L.ExtinguishMob()
	L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
	L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = TRUE
		for(var/obj/item/I in M.held_items)
			wash_obj(I)

		if(M.back && wash_obj(M.back))
			M.update_inv_back(0)

		var/list/obscured = M.check_obscured_slots()

		if(M.head && wash_obj(M.head))
			M.update_inv_head()

		if(M.glasses && !(SLOT_GLASSES in obscured) && wash_obj(M.glasses))
			M.update_inv_glasses()

		if(M.wear_mask && !(SLOT_WEAR_MASK in obscured) && wash_obj(M.wear_mask))
			M.update_inv_wear_mask()

		if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
			M.update_inv_ears()

		if(M.wear_neck && !(SLOT_NECK in obscured) && wash_obj(M.wear_neck))
			M.update_inv_neck()

		if(M.shoes && !(HIDESHOES in obscured) && wash_obj(M.shoes))
			M.update_inv_shoes()

		var/washgloves = FALSE
		if(M.gloves && !(HIDEGLOVES in obscured))
			washgloves = TRUE

		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_suit && wash_obj(H.wear_suit))
				H.update_inv_wear_suit()
			else if(H.w_uniform && wash_obj(H.w_uniform))
				H.update_inv_w_uniform()

			if(washgloves)
				SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

			if(!H.is_mouth_covered())
				H.lip_style = null
				H.update_body()

			if(H.belt && wash_obj(H.belt))
				H.update_inv_belt()
		else
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	else
		SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

//put people in water, including you
/turf/open/pool/MouseDrop_T(mob/living/M, mob/living/user)
	if(!has_gravity(src))
		return
	if(user.stat || user.lying || !Adjacent(user) || !M.Adjacent(user)|| !iscarbon(M))
		return
	if(!iscarbon(user)) // no silicons or drones in mechas.
		return
	if(M.swimming) //can't lower yourself again
		return
	else
		if(user == M)
			M.visible_message("<span class='notice'>[user] is descending in the pool", \
							"<span class='notice'>You start lowering yourself in the pool.</span>")
			if(do_mob(user, M, 20))
				M.swimming = TRUE
				M.forceMove(src)
				to_chat(user, "<span class='notice'>You lower yourself in the pool.</span>")
		else
			user.visible_message("<span class='notice'>[M] is being put in the pool by [user].</span>", \
							"<span class='notice'>You start lowering [M] in the pool.")
			if(do_mob(user, M, 20))
				M.swimming = TRUE
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
					if (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSMOUTH)
						H.visible_message("<span class='danger'>[H] falls in the water!</span>",
											"<span class='userdanger'>You fall in the water!</span>")
						playsound(src, 'sound/effects/splash.ogg', 60, TRUE, 1)
						H.Knockdown(20)
						H.swimming = TRUE
						return
					else
						H.dropItemToGround(H.get_active_held_item())
						H.adjustOxyLoss(5)
						H.emote("cough")
						H.visible_message("<span class='danger'>[H] falls in and takes a drink!</span>",
											"<span class='userdanger'>You fall in and swallow some water!</span>")
						playsound(src, 'sound/effects/splash.ogg', 60, TRUE, 1)
						H.Knockdown(60)
						H.swimming = TRUE
				else if(!istype(H.head, /obj/item/clothing/head/helmet))
					if(prob(75))
						H.visible_message("<span class='danger'>[H] falls in the drained pool!</span>",
													"<span class='userdanger'>You fall in the drained pool!</span>")
						H.adjustBruteLoss(7)
						H.Knockdown(80)
						H.swimming = TRUE
						playsound(src, 'sound/effects/woodhit.ogg', 60, TRUE, 1)
					else
						H.visible_message("<span class='danger'>[H] falls in the drained pool, and cracks his skull!</span>",
													"<span class='userdanger'>You fall in the drained pool, and crack your skull!</span>")
						H.apply_damage(15, BRUTE, "head")
						H.Knockdown(200) // This should hurt. And it does.
						H.adjustBrainLoss(30) //herp
						H.swimming = TRUE
						playsound(src, 'sound/effects/woodhit.ogg', 60, TRUE, 1)
						playsound(src, 'sound/misc/crack.ogg', 100, TRUE)
				else
					H.visible_message("<span class='danger'>[H] falls in the drained pool, but had an helmet!</span>",
										"<span class='userdanger'>You fall in the drained pool, but you had an helmet!</span>")
					H.Knockdown(40)
					H.swimming = TRUE
					playsound(src, 'sound/effects/woodhit.ogg', 60, TRUE, 1)
		else if(filled)
			wash_mob(M)
			M.adjustStaminaLoss(1)
			playsound(src, "water_wade", 20, 1)
			return

/obj/structure/pool
	name = "pool"
	icon = 'icons/turf/pool.dmi'
	anchored = 1
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/structure/pool/ladder
	name = "Ladder"
	icon_state = "ladder"
	desc = "Are you getting in or are you getting out?."
	layer = 5.1
	dir=4

/obj/structure/pool/ladder/attack_hand(mob/living/user as mob)
	if(Adjacent(user) && user.y == y && user.swimming == 0)
		user.swimming = 1
		user.forceMove(get_step(user, get_dir(user, src))) //Either way, you're getting IN or OUT of the pool.
	else if(user.loc == loc && user.swimming == 1)
		user.swimming = 0
		user.forceMove(get_step(user, turn(dir, 180)))

/obj/structure/pool/Rboard
	name = "JumpBoard"
	density = 0
	icon_state = "boardright"
	desc = "The less-loved portion of the jumping board."
	dir = 4

/obj/structure/pool/Rboard/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.pass_flags & PASSGLASS)
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

/obj/structure/pool/Lboard/proc/backswim(obj/O, mob/living/user) //Puts the sprite back to it's maiden condition after a jump.
	if(jumping)
		for(var/mob/living/jumpee in loc) //hackzors.
			playsound(jumpee, 'sound/effects/splash.ogg', 60, TRUE, 1)
			jumpee.layer = 4
			jumpee.pixel_x = 0
			jumpee.pixel_y = 0
			jumpee.Stun(2)
			jumpee.swimming = TRUE

/obj/structure/pool/Lboard/attack_hand(mob/living/user)
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
				if(pc.drained)
					to_chat(user, "<span class='notice'>That would be suicide</span>")
					return
			if(Adjacent(jumper))
				jumper.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
									 "<span class='notice'>You climb up \the [src] and prepares to jump!</span>")
				jumper.mobility_flags &= ~MOBILITY_MOVE
				jumper.Stun(40)
				jumping = TRUE
				jumper.layer = 5.1
				jumper.pixel_x = 3
				jumper.pixel_y = 7
				jumper.dir=8
				sleep(1)
				jumper.loc = T
				addtimer(CALLBACK(src, .proc/dive, jumper), 10)

/obj/structure/pool/Lboard/proc/dive(mob/living/carbon/jumper)
	switch(rand(1, 100))
		if(1 to 20)
			jumper.visible_message("<span class='notice'>[jumper] goes for a small dive!</span>", \
								 "<span class='notice'>You go for a small dive.</span>")
			sleep(15)
			backswim()
			var/atom/throw_target = get_edge_target_turf(src, dir)
			jumper.throw_at(throw_target, 1, 1)

		if(21 to 40)
			jumper.visible_message("<span class='notice'>[jumper] goes for a dive!</span>", \
								 "<span class='notice'>You're going for a dive!</span>")
			sleep(20)
			backswim()
			var/atom/throw_target = get_edge_target_turf(src, dir)
			jumper.throw_at(throw_target, 2, 1)

		if(41 to 60)
			jumper.visible_message("<span class='notice'>[jumper] goes for a long dive! Stay far away!</span>", \
					"<span class='notice'>You're going for a long dive!!</span>")
			sleep(25)
			backswim()
			var/atom/throw_target = get_edge_target_turf(src, dir)
			jumper.throw_at(throw_target, 3, 1)

		if(61 to 80)
			jumper.visible_message("<span class='notice'>[jumper] goes for an awesome dive! Don't stand in \his way!</span>", \
								 "<span class='notice'>You feel like this dive will be awesome</span>")
			sleep(30)
			backswim()
			var/atom/throw_target = get_edge_target_turf(src, dir)
			jumper.throw_at(throw_target, 4, 1)
		if(81 to 91)
			sleep(20)
			backswim()
			jumper.visible_message("<span class='danger'>[jumper] misses \his step!</span>", \
							 "<span class='userdanger'>You misstep!</span>")
			var/atom/throw_target = get_edge_target_turf(src, dir)
			jumper.throw_at(throw_target, 0, 1)
			jumper.Knockdown(100)
			jumper.adjustBruteLoss(10)

		if(91 to 100)
			jumper.visible_message("<span class='notice'>[jumper] is preparing for the legendary dive! Can he make it?</span>", \
								 "<span class='userdanger'>You start preparing for a legendary dive!</span>")
			jumper.SpinAnimation(7,1)

			sleep(30)
			if(prob(75))
				backswim()
				jumper.visible_message("<span class='notice'>[jumper] fails!</span>", \
						 "<span class='userdanger'>You can't quite do it!</span>")
				var/atom/throw_target = get_edge_target_turf(src, dir)
				jumper.throw_at(throw_target, 1, 1)
			else
				jumper.fire_stacks = min(1,jumper.fire_stacks + 1)
				jumper.IgniteMob()
				sleep(5)
				backswim()
				jumper.visible_message("<span class='danger'>[jumper] bursts into flames of pure awesomness!</span>", \
					 "<span class='userdanger'>No one can stop you now!</span>")
				var/atom/throw_target = get_edge_target_turf(src, dir)
				jumper.throw_at(throw_target, 6, 1)
	jumper.update_mobility()
	addtimer(CALLBACK(src, .proc/togglejumping), 35)

/obj/structure/pool/Lboard/proc/togglejumping()
	jumping = FALSE

/turf/open/pool/attack_hand(mob/living/user)
	if(user.stat == CONSCIOUS && !(user.lying || user.resting) && Adjacent(user) && user.swimming && filled && next_splash < world.time) //not drained, user alive and close, and user in water.
		if(user.x == x && user.y == y)
			return
		else
			playsound(src, 'sound/effects/watersplash.ogg', 8, TRUE, 1)
			next_splash = world.time + 25
			var/obj/effect/splash/S = new /obj/effect/splash(user.loc)
			animate(S, alpha = 0,  time = 8)
			S.Move(src)
			QDEL_IN(S, 20)
			for(var/mob/living/carbon/human/L in src)
				if(!L.wear_mask && !user.stat) //Do not affect those underwater or dying.
					L.emote("cough")
				L.adjustStaminaLoss(4) //You need to give em a break!

/turf/open/pool/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/mop) && filled)
		W.reagents.add_reagent("water", 5)
		to_chat(user, "<span class='notice'>You wet [W] in [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)

/obj/effect/splash
	name = "splash"
	desc = "Wataaa!."
	icon = 'icons/turf/pool.dmi'
	icon_state = "splash"
	layer = ABOVE_ALL_MOB_LAYER
