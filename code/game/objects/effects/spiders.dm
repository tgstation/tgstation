//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	icon = 'icons/effects/effects.dmi'
	desc = "it's stringy and sticky"
	anchored = 1
	density = 0
	obj_integrity = 15



/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)


/obj/structure/spider/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee")
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
			if(BRUTE)
				damage_amount *= 0.25
	. = ..()

/obj/structure/spider/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/New()
	if(prob(50))
		icon_state = "stickyweb2"
	. = ..()

/obj/structure/spider/stickyweb/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/poison/giant_spider))
		return 1
	else if(isliving(mover))
		if(prob(50))
			mover << "<span class='danger'>You get stuck in \the [src] for a moment.</span>"
			return 0
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return 1

/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life"
	icon_state = "eggs"
	var/amount_grown = 0
	var/player_spiders = 0
	var/poison_type = "toxin"
	var/poison_per_bite = 5
	var/list/faction = list("spiders")

/obj/structure/spider/eggcluster/New()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/spider/eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = rand(3,12)
		for(var/i=0, i<num, i++)
			var/obj/structure/spider/spiderling/S = new /obj/structure/spider/spiderling(src.loc)
			S.poison_type = poison_type
			S.poison_per_bite = poison_per_bite
			S.faction = faction.Copy()
			if(player_spiders)
				S.player_spiders = 1
		qdel(src)

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = 0
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	obj_integrity = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/player_spiders = 0
	var/poison_type = "toxin"
	var/poison_per_bite = 5
	var/list/faction = list("spiders")

/obj/structure/spider/spiderling/New()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/spider/spiderling/hunter
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter

/obj/structure/spider/spiderling/nurse
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/nurse

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		src.loc = user.loc
	else
		..()

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipeline/entry_vent_parent = entry_vent.PARENT1
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventillation ducts!</B>", \
								"<span class='italics'>You hear something scampering through the ventilation ducts.</span>")

			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return

					if(prob(50))
						audible_message("<span class='italics'>You hear something scampering through the ventilation ducts.</span>")
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
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
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
			S.poison_per_bite = poison_per_bite
			S.poison_type = poison_type
			S.faction = faction.Copy()
			if(player_spiders)
				S.playable_spider = TRUE
				notify_ghosts("Spider [S.name] can be controlled", null, enter_link="<a href=?src=\ref[S];activate=1>(Click to play)</a>", source=S, action=NOTIFY_ATTACK)
			qdel(src)



/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web"
	icon_state = "cocoon1"
	obj_integrity = 60

/obj/structure/spider/cocoon/New()
	icon_state = pick("cocoon1","cocoon2","cocoon3")
	. = ..()

/obj/structure/spider/cocoon/container_resist(mob/living/user)
	var/breakout_time = 1
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You struggle against the tight bonds... (This will take about [breakout_time] minutes.)</span>"
	visible_message("You see something struggling and writhing in \the [src]!")
	if(do_after(user,(breakout_time*60*10), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)



/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message("<span class='warning'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
