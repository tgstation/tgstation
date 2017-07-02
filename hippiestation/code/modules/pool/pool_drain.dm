/obj/machinery/drain
	name = "Drain"
	icon = 'hippiestation/icons/turf/pool.dmi'
	icon_state = "drain"
	desc = "This removes things that clog the pool."
	anchored = TRUE
	var/active = 0
	var/status = 0 //1 is drained, 0 is full.
	var/srange = 6
	var/timer = 0
	var/cooldown
	var/obj/machinery/poolcontroller/poolcontrol = null
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/drain/Initialize()
	. = ..()
	for(var/obj/machinery/poolcontroller/control in range(srange,src))
		src.poolcontrol += control

/obj/machinery/drain/process()
	if(!status) //don't drain an empty pool.
		for(var/obj/item/absorbo in orange(1,src))
			if(absorbo.w_class == 1)
				step_towards(absorbo, src)
		spawn(7) //Gives them just the time to pick their items up.
			for(var/obj/item/absorb in range(0,src))
				if(absorb.w_class == 1)
					for(var/obj/machinery/poolfilter/filter in range(srange,src))
						absorb.loc = filter
	if(active)
		if(status) //if filling up, get back to normal position
			if(timer > 0)
				playsound(src, 'hippiestation/sound/effects/fillingwatter.ogg', 100, 1)
				timer--
				for(var/obj/whirlo in orange(1,src))
					if(!whirlo.anchored )
						step_away(whirlo,src)
				for(var/mob/living/carbon/human/whirlm in orange(2,src))
					step_away(whirlm,src)
			else if(timer == 0)
				for(var/turf/open/pool/undrained in range(5,src))
					undrained.filled = TRUE
					undrained.update_icon()
				for(var/obj/effect/effect/waterspout/undrained3 in range(1,src))
					qdel(undrained3)
				poolcontrol.drained = 0
				if(poolcontrol.bloody < 1000)
					poolcontrol.bloody /= 2
				if(poolcontrol.bloody > 1000)
					poolcontrol.bloody /= 4
				poolcontrol.changecolor()
				status = 0
				active = 0
			return
		if(!status) //if draining, change everything.
			if(timer > 0)
				playsound(src, 'hippiestation/sound/effects/pooldrain.ogg', 100, 1)
				playsound(src, pick('hippiestation/sound/effects/water_wade1.ogg','hippiestation/sound/effects/water_wade2.ogg','hippiestation/sound/effects/water_wade3.ogg','hippiestation/sound/effects/water_wade4.ogg'), 60, 1)
				timer--
				for(var/obj/whirlo in orange(2,src))
					if(!whirlo.anchored )
						step_towards(whirlo,src)
				for(var/mob/living/carbon/human/whirlm in orange(2,src))
					step_towards(whirlm,src)
					if(prob(20))
						whirlm.Weaken(2)
					for(var/i in list(1,2,4,8,4,2,1)) //swirl!
						whirlm.dir = i
						sleep(1)
					if(whirlm.loc == src.loc)
						if(whirlm.health <= -50) //If very damaged, gib.
							whirlm.gib()
						if(whirlm.stat != CONSCIOUS || whirlm.lying) // If
							whirlm.adjustBruteLoss(5)
							playsound(src, pick('hippiestation/sound/misc/crack.ogg','hippiestation/sound/misc/crunch.ogg'), 50, 1)
							to_chat(whirlm, "<span class='danger'>You're caught in the drain!</span>")
							continue
						else
							playsound(src, pick('hippiestation/sound/misc/crack.ogg','hippiestation/sound/misc/crunch.ogg'), 50, 1)
							whirlm.apply_damage(4, BRUTE, pick("l_leg", "r_leg")) //drain should only target the legs
							to_chat(whirlm, "<span class='danger'>Your legs are caught in the drain!</span>")
							continue

			else if(timer == 0)
				for(var/turf/open/pool/drained in range(5,src))
					drained.filled = FALSE
					drained.update_icon()
				for(var/obj/effect/whirlpool/drained3 in range(1,src))
					qdel(drained3)
				for(var/obj/machinery/poolcontroller/drained4 in range(5,src))
					drained4.drained = 1
					drained4.mistoff()
				status = 1
				active = 0

/obj/effect/whirlpool
	name = "Whirlpool"
	icon = 'hippiestation/icons/effects/96x96.dmi'
	icon_state = "whirlpool"
	layer = 5
	anchored = TRUE
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32
	alpha = 90

/obj/effect/effect/waterspout
	name = "Waterspout"
	icon_state = "waterspout"
	color = "#3399AA"
	layer = 5
	anchored = TRUE
	mouse_opacity = 0
	icon = 'hippiestation/icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	alpha = 120

/obj/machinery/poolfilter
	name = "Filter"
	icon = 'hippiestation/icons/turf/pool.dmi'
	icon_state = "filter"
	desc = "The part of the pool that swallows dangerous stuff and ID's"
	anchored = TRUE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/poolfilter/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "<span class='warning'>You disable the [src]'s shark filter! Run!</span>")
		emagged = TRUE
		do_sparks(5, TRUE, src)
		src.icon_state = "filter_b"
		spawn(50)
			if(prob(50))
				new /mob/living/simple_animal/hostile/shark(src.loc)
			else
				if(prob(50))
					new /mob/living/simple_animal/hostile/shark/kawaii(src.loc)
				else
					new /mob/living/simple_animal/hostile/shark/laser(src.loc)
		if(GLOB.adminlog)
			log_say("[key_name(user)] emagged the pool filter and probably spawned sharks")
			message_admins("[key_name_admin(user)] emagged the pool filter and probably spawned sharks")


/obj/machinery/poolfilter/attack_hand(mob/user)
	to_chat(user, "You search the filter.")
	for(var/obj/O in contents)
		O.loc = src.loc