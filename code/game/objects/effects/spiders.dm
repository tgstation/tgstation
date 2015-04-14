//generic procs copied from obj/effect/alien
/obj/effect/spider
	name = "web"
	desc = "it's stringy and sticky"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	density = 0
	var/health = 15

//similar to weeds, but only barfed out by nurses manually
/obj/effect/spider/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/effect/spider/attackby(var/obj/item/weapon/W, var/mob/user, params)
	if(W.attack_verb.len)
		visible_message("<span class='danger'>[user] has [pick(W.attack_verb)] \the [src] with \the [W]!</span>")
	else
		visible_message("<span class='danger'>[user] has attacked \the [src] with \the [W]!</span>")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/effect/spider/bullet_act(var/obj/item/projectile/Proj)
	..()
	health -= Proj.damage
	healthcheck()

/obj/effect/spider/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/effect/spider/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/obj/effect/spider/stickyweb
	icon_state = "stickyweb1"

/obj/effect/spider/stickyweb/New()
	if(prob(50))
		icon_state = "stickyweb2"

/obj/effect/spider/stickyweb/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/poison/giant_spider))
		return 1
	else if(istype(mover, /mob/living))
		if(prob(50))
			mover << "<span class='danger'>You get stuck in \the [src] for a moment.</span>"
			return 0
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return 1

/obj/effect/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life"
	icon_state = "eggs"
	var/amount_grown = 0
	var/player_spiders = 0

/obj/effect/spider/eggcluster/New()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	SSobj.processing |= src

/obj/effect/spider/eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = rand(3,12)
		for(var/i=0, i<num, i++)
			var/obj/effect/spider/spiderling/S = new /obj/effect/spider/spiderling(src.loc)
			if(player_spiders)
				S.player_spiders = 1
		qdel(src)

/obj/effect/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = 0
	layer = 2.75
	health = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/player_spiders = 0

/obj/effect/spider/spiderling/New()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	SSobj.processing |= src

/obj/effect/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		src.loc = user.loc
	else
		..()

/obj/effect/spider/spiderling/proc/die()
	visible_message("<span class='alert'>[src] dies!</span>")
	qdel(src)

/obj/effect/spider/spiderling/healthcheck()
	if(health <= 0)
		die()

/obj/effect/spider/spiderling/process()
	if(travelling_in_vent)
		if(istype(src.loc, /turf))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventillation ducts!</B>", \
								"<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")

			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return

					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					sleep(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					loc = exit_vent.loc
					entry_vent = null
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)
	//=================

	else if(prob(33))
		var/list/nearby = oview(10, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			walk_to(src, target_atom)
			if(prob(40))
				src.visible_message("<span class='notice'>\The [src] skitters[pick(" away"," around","")].</span>")
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 1)
				break
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if(!grow_as)
				grow_as = pick(typesof(/mob/living/simple_animal/hostile/poison/giant_spider))
			var/mob/living/simple_animal/hostile/poison/giant_spider/S = new grow_as(src.loc)
			if(player_spiders)
				var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)

				shuffle(candidates)

				var/time_passed = world.time
				var/list/consenting_candidates = list()

				for(var/candidate in candidates)

					spawn(0)
						switch(alert(candidate, "Would you like to play as [S.name]? Please choose quickly!","Confirmation","Yes","No"))
							if("Yes")
								if((world.time-time_passed)>=50 || !src)
									return
								consenting_candidates += candidate

				sleep(50)

				if(!src)
					return

				if(consenting_candidates.len)
					var/client/C = null
					C = pick(consenting_candidates)
					S.key = C.key
			qdel(src)




/obj/effect/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web"
	icon_state = "cocoon1"
	health = 60

/obj/effect/spider/cocoon/New()
		icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/effect/spider/cocoon/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You struggle against the tight bonds! (This will take about [breakout_time] minutes.)</span>"
	visible_message("You see something struggling and writhing in \the [src]!")
	if(do_after(user,(breakout_time*60*10)))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)



/obj/effect/spider/cocoon/Destroy()
	src.visible_message("<span class='danger'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.loc = src.loc
	..()
