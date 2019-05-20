/obj/machinery/pool/drain
	name = "drain"
	icon_state = "drain"
	desc = "A suction system to remove the contents of the pool, and sometimes small objects. Do not insert fingers."
	anchored = TRUE
	var/active = FALSE
	var/status = FALSE //1 is drained, 0 is full.
	var/srange = 6
	var/timer = 0
	var/cooldown
	var/obj/machinery/pool/controller/pool_controller = null

/obj/machinery/pool/drain/Initialize()
	START_PROCESSING(SSprocessing, src)
	. = ..()

/obj/machinery/pool/drain/Destroy()
	pool_controller.linked_drain = null
	pool_controller = null
	return ..()

/obj/machinery/pool/drain/process()
	if(!status) //don't pool/drain an empty pool.
		for(var/obj/item/absorbo in orange(1,src))
			if(absorbo.w_class == WEIGHT_CLASS_TINY)
				step_towards(absorbo, src)
				var/dist = get_dist(src, absorbo)
				if(dist == 0)
					absorbo.forceMove(pool_controller.linked_filter)
	if(active)
		if(status) //if filling up, get back to normal position
			if(timer > 0)
				playsound(src, 'sound/effects/fillingwatter.ogg', 100, TRUE)
				timer--
				for(var/obj/whirlo in orange(1,src))
					if(!whirlo.anchored )
						step_away(whirlo,src)
				for(var/mob/living/carbon/human/whirlm in orange(2,src))
					step_away(whirlm,src)
			else if(!timer)
				for(var/turf/open/pool/undrained in range(5,src))
					undrained.filled = TRUE
					undrained.update_icon()
				for(var/obj/effect/waterspout/undrained3 in range(1,src))
					qdel(undrained3)
				pool_controller.drained = FALSE
				if(pool_controller.bloody < 1000)
					pool_controller.bloody /= 2
				if(pool_controller.bloody > 1000)
					pool_controller.bloody /= 4
				pool_controller.changecolor()
				status = FALSE
				active = FALSE
			return
		if(!status) //if draining, change everything.
			if(timer > 0)
				playsound(src, 'sound/effects/pooldrain.ogg', 100, TRUE)
				playsound(src, "water_wade", 60, TRUE)
				timer--
				for(var/obj/whirlo in orange(2,src))
					if(!whirlo.anchored )
						step_towards(whirlo,src)
				for(var/mob/living/carbon/human/whirlm in orange(2,src))
					step_towards(whirlm,src)
					if(prob(20))
						whirlm.Knockdown(40)
					for(var/i in list(1,2,4,8,4,2,1)) //swirl!
						whirlm.dir = i
						sleep(1)
					if(whirlm.forceMove(loc))
						if(whirlm.health <= -50) //If very damaged, gib.
							whirlm.gib()
						if(whirlm.stat != CONSCIOUS || whirlm.lying) // If
							whirlm.adjustBruteLoss(5)
							playsound(src, pick('sound/misc/crack.ogg','sound/misc/crunch.ogg'), 50, TRUE)
							to_chat(whirlm, "<span class='danger'>You're caught in the drain!</span>")
							continue
						else
							playsound(src, pick('sound/misc/crack.ogg','sound/misc/crunch.ogg'), 50, TRUE)
							whirlm.apply_damage(4, BRUTE, pick("l_leg", "r_leg")) //drain should only target the legs
							to_chat(whirlm, "<span class='danger'>Your legs are caught in the drain!</span>")
							continue

			else if(!timer)
				for(var/turf/open/pool/drained in range(5,src))
					drained.filled = FALSE
					drained.update_icon()
				for(var/obj/effect/whirlpool/drained3 in range(1,src))
					qdel(drained3)
				for(var/obj/machinery/pool/controller/drained4 in range(5,src))
					drained4.drained = TRUE
					drained4.mistoff()
				status = TRUE
				active = FALSE

/obj/machinery/pool/filter
	name = "Filter"
	icon_state = "filter"
	desc = "The part of the pool where all the IDs, ATV keys, and pens, and other dangerous things get trapped."
	var/obj/machinery/pool/controller/pool_controller = null

/obj/machinery/pool/filter/Destroy()
	pool_controller.linked_filter = null
	pool_controller = null
	return ..()

/obj/machinery/pool/filter/emag_act(user as mob)
	if(!(obj_flags & EMAGGED))
		to_chat(user, "<span class='warning'>You disable the [src]'s shark filter! Run!</span>")
		obj_flags |= EMAGGED
		do_sparks(5, TRUE, src)
		icon_state = "filter_b"
		addtimer(CALLBACK(src, /obj/machinery/pool/filter/proc/spawn_shark), 50)
		log_game("[key_name(user)] emagged the pool filter and spawned a shark")
		message_admins("[key_name_admin(user)] emagged the pool filter and spawned a shark")

/obj/machinery/pool/filter/proc/spawn_shark()
	if(prob(50))
		new /mob/living/simple_animal/hostile/shark(loc)
	else
		if(prob(50))
			new /mob/living/simple_animal/hostile/shark/kawaii(loc)
		else
			new /mob/living/simple_animal/hostile/shark/laser(loc)

/obj/machinery/pool/filter/attack_hand(mob/user)
	to_chat(user, "You search the filter.")
	for(var/obj/O in contents)
		O.forceMove(loc)
