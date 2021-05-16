//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	icon = 'icons/effects/effects.dmi'
	desc = "It's stringy and sticky."
	anchored = TRUE
	density = FALSE
	max_integrity = 15

/obj/structure/spider/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/spider/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
			if(BRUTE)
				damage_amount *= 0.25
	. = ..()

/obj/structure/spider/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/spider/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	var/genetic = FALSE
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/attack_hand(mob/user, list/modifiers)
	.= ..()
	if(.)
		return
	if(!HAS_TRAIT(user,TRAIT_WEB_WEAVER))
		return
	user.visible_message("<span class='notice'>[user] begins weaving [src] into cloth.</span>", "<span class='notice'>You begin weaving [src] into cloth.</span>")
	if(!do_after(user, 2 SECONDS))
		return
	qdel(src)
	var/obj/item/stack/sheet/cloth/woven_cloth = new /obj/item/stack/sheet/cloth
	user.put_in_hands(woven_cloth)

/obj/structure/spider/stickyweb/Initialize()
	if(prob(50))
		icon_state = "stickyweb2"
	. = ..()

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(genetic)
		return
	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return TRUE
	else if(isliving(mover))
		if(istype(mover.pulledby, /mob/living/simple_animal/hostile/giant_spider))
			return TRUE
		if(prob(50))
			to_chat(mover, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/spider/stickyweb/genetic //for the spider genes in genetics
	genetic = TRUE
	var/mob/living/allowed_mob

/obj/structure/spider/stickyweb/genetic/Initialize(mapload, allowedmob)
	allowed_mob = allowedmob
	. = ..()

/obj/structure/spider/stickyweb/genetic/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..() //this is the normal spider web return aka a spider would make this TRUE
	if(mover == allowed_mob)
		return TRUE
	else if(isliving(mover)) //we change the spider to not be able to go through here
		if(mover.pulledby == allowed_mob)
			return TRUE
		if(prob(50))
			to_chat(mover, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	///The amount the egg cluster has grown.  Is able to produce a spider when it hits 100.
	var/amount_grown = 0
	///The mother's directive at the time the egg was produced.  Passed onto the child.
	var/directive = "" //Message from the mother
	///Which factions to give to the produced spider, inherited from the mother.
	var/list/faction = list("spiders")
	///Whether or not a ghost can use the cluster to become a spider.
	var/ghost_ready = FALSE
	///The types of spiders the egg sac could produce.
	var/list/mob/living/potentialspawns = list(/mob/living/simple_animal/hostile/giant_spider,
								/mob/living/simple_animal/hostile/giant_spider/hunter,
								/mob/living/simple_animal/hostile/giant_spider/nurse)

/obj/structure/spider/eggcluster/Initialize()
	pixel_x = base_pixel_x + rand(3,-3)
	pixel_y = base_pixel_y + rand(3,-3)
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	return ..()

/obj/structure/spider/eggcluster/process(delta_time)
	amount_grown += rand(0,1) * delta_time
	if(amount_grown >= 100 && !ghost_ready)
		notify_ghosts("[src] is ready to hatch!", null, enter_link="<a href=?src=[REF(src)];activate=1>(Click to play)</a>", source=src, action=NOTIFY_ORBIT, ignore_key = POLL_IGNORE_SPIDER)
		ghost_ready = TRUE

/obj/structure/spider/eggcluster/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)
			attack_ghost(ghost)

/obj/structure/spider/eggcluster/attack_ghost(mob/user)
	. = ..()
	if(ghost_ready)
		make_spider(user)

/**
 * Makes a ghost into a spider based on the type of egg cluster.
 *
 * Allows a ghost to get a prompt to use the egg cluster to become a spider.
 * Arguments:
 * * user - The ghost attempting to become a spider.
 */
/obj/structure/spider/eggcluster/proc/make_spider(mob/user)
	var/list/spider_list = list()
	var/list/display_spiders = list()
	for(var/choice in potentialspawns)
		var/mob/living/simple_animal/hostile/giant_spider/spider = choice
		spider_list[initial(spider.name)] = choice

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(spider.icon), icon_state = initial(spider.icon_state))
		option.info = "<span class='boldnotice'>[initial(spider.menu_description)]</span>"

		display_spiders[initial(spider.name)] = option

	sortList(display_spiders)
	var/chosen_spider = show_radial_menu(user, src, display_spiders, radius = 38)
	chosen_spider = spider_list[chosen_spider]
	if(QDELETED(src) || QDELETED(user) || !chosen_spider)
		return FALSE
	var/mob/living/simple_animal/hostile/giant_spider/new_spider = new chosen_spider(src.loc)
	new_spider.faction = faction.Copy()
	new_spider.directive = directive
	new_spider.key = user.key
	QDEL_NULL(src)
	return TRUE

/obj/structure/spider/eggcluster/enriched
	name = "enriched egg cluster"
	color = rgb(148,0,211)
	potentialspawns = list(/mob/living/simple_animal/hostile/giant_spider/tarantula,
							/mob/living/simple_animal/hostile/giant_spider/viper,
							/mob/living/simple_animal/hostile/giant_spider/midwife)

/obj/structure/spider/eggcluster/bloody
	name = "bloody egg cluster"
	color = rgb(255,0,0)
	directive = "You are the spawn of a visicious changeling.  You have no ambitions except to wreak havoc and ensure your own survival.  You are aggressive to all living beings outside of your species, including changelings."
	potentialspawns = list(/mob/living/simple_animal/hostile/giant_spider/hunter/flesh)

/obj/structure/spider/eggcluster/midwife
	name = "midwife egg cluster"
	potentialspawns = list(/mob/living/simple_animal/hostile/giant_spider/midwife)
	directive = "Ensure the survival of the spider species and overtake whatever structure you find yourself in."

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/directive = "" //Message from the mother
	var/list/faction = list("spiders")

/obj/structure/spider/spiderling/Destroy()
	new/obj/item/food/spiderling(get_turf(src))
	. = ..()

/obj/structure/spider/spiderling/Initialize()
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/swarming)

/obj/structure/spider/spiderling/hunter
	grow_as = /mob/living/simple_animal/hostile/giant_spider/hunter

/obj/structure/spider/spiderling/nurse
	grow_as = /mob/living/simple_animal/hostile/giant_spider/nurse

/obj/structure/spider/spiderling/midwife
	grow_as = /mob/living/simple_animal/hostile/giant_spider/midwife

/obj/structure/spider/spiderling/viper
	grow_as = /mob/living/simple_animal/hostile/giant_spider/viper

/obj/structure/spider/spiderling/tarantula
	grow_as = /mob/living/simple_animal/hostile/giant_spider/tarantula

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		forceMove(user.loc)
	else
		..()

/obj/structure/spider/spiderling/proc/cancel_vent_move()
	forceMove(entry_vent)
	entry_vent = null

/obj/structure/spider/spiderling/proc/vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return

	forceMove(exit_vent)
	var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
	addtimer(CALLBACK(src, .proc/do_vent_move, exit_vent, travel_time), travel_time)

/obj/structure/spider/spiderling/proc/do_vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent, travel_time)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return

	if(prob(50))
		audible_message("<span class='hear'>You hear something scampering through the ventilation ducts.</span>")

	addtimer(CALLBACK(src, .proc/finish_vent_move, exit_vent), travel_time)

/obj/structure/spider/spiderling/proc/finish_vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return
	forceMove(exit_vent.loc)
	entry_vent = null

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipeline/entry_vent_parent = entry_vent.parents[1]
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								"<span class='hear'>You hear something scampering through the ventilation ducts.</span>")

			addtimer(CALLBACK(src, .proc/vent_move, exit_vent), rand(20,60))

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
				if(prob(3))
					grow_as = pick(/mob/living/simple_animal/hostile/giant_spider/tarantula, /mob/living/simple_animal/hostile/giant_spider/viper, /mob/living/simple_animal/hostile/giant_spider/midwife)
				else
					grow_as = pick(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/giant_spider/S = new grow_as(src.loc)
			S.faction = faction.Copy()
			S.directive = directive
			qdel(src)

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize()
	icon_state = pick("cocoon1","cocoon2","cocoon3")
	. = ..()

/obj/structure/spider/cocoon/container_resist_act(mob/living/user)
	var/breakout_time = 600
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>You struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)</span>")
	visible_message("<span class='notice'>You see something struggling and writhing in \the [src]!</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message("<span class='warning'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
