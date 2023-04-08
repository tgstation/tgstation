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

/obj/structure/spider/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
			if(BRUTE)
				damage_amount *= 0.25
	. = ..()

/obj/structure/spider/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 350

/obj/structure/spider/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	///Whether or not the web is from the genetics power
	var/genetic = FALSE
	///Whether or not the web is a sealed web
	var/sealed = FALSE
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/attack_hand(mob/user, list/modifiers)
	.= ..()
	if(.)
		return
	if(!HAS_TRAIT(user,TRAIT_WEB_WEAVER))
		return
	user.balloon_alert_to_viewers("weaving...")
	if(!do_after(user, 2 SECONDS))
		user.balloon_alert(user, "interrupted!")
		return
	qdel(src)
	var/obj/item/stack/sheet/cloth/woven_cloth = new /obj/item/stack/sheet/cloth
	user.put_in_hands(woven_cloth)

/obj/structure/spider/stickyweb/Initialize(mapload)
	if(!sealed && prob(50))
		icon_state = "stickyweb2"
	. = ..()

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(genetic)
		return
	if(sealed)
		return FALSE
	if(isspider(mover))
		return TRUE
	else if(isliving(mover))
		if(istype(mover.pulledby, /mob/living/basic/giant_spider))
			return TRUE
		if(prob(50))
			balloon_alert(mover, "stuck in web!")
			return FALSE
	else if(isprojectile(mover))
		return prob(30)

/obj/structure/spider/stickyweb/sealed
	name = "sealed web"
	desc = "A solid thick wall of web, airtight enough to block air flow."
	icon_state = "sealedweb"
	sealed = TRUE
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/spider/stickyweb/genetic //for the spider genes in genetics
	genetic = TRUE
	var/mob/living/allowed_mob

/obj/structure/spider/stickyweb/genetic/Initialize(mapload, allowedmob)
	allowed_mob = allowedmob
	. = ..()

/obj/structure/spider/stickyweb/genetic/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..() //this is the normal spider web return aka a spider would make this TRUE
	if(mover == allowed_mob)
		return TRUE
	else if(isliving(mover)) //we change the spider to not be able to go through here
		if(mover.pulledby == allowed_mob)
			return TRUE
		if(prob(50))
			balloon_alert(mover, "stuck in web!")
			return FALSE
	else if(isprojectile(mover))
		return prob(30)

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
	var/list/faction = list(FACTION_SPIDER)

/obj/structure/spider/spiderling/Destroy()
	new/obj/item/food/spiderling(get_turf(src))
	. = ..()

/obj/structure/spider/spiderling/Initialize(mapload)
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/swarming)

/obj/structure/spider/spiderling/hunter
	grow_as = /mob/living/basic/giant_spider/hunter

/obj/structure/spider/spiderling/nurse
	grow_as = /mob/living/basic/giant_spider/nurse

/obj/structure/spider/spiderling/midwife
	grow_as = /mob/living/basic/giant_spider/midwife

/obj/structure/spider/spiderling/viper
	grow_as = /mob/living/basic/giant_spider/viper

/obj/structure/spider/spiderling/tarantula
	grow_as = /mob/living/basic/giant_spider/tarantula

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
	addtimer(CALLBACK(src, PROC_REF(do_vent_move), exit_vent, travel_time), travel_time)

/obj/structure/spider/spiderling/proc/do_vent_move(obj/machinery/atmospherics/components/unary/vent_pump/exit_vent, travel_time)
	if(QDELETED(exit_vent) || exit_vent.welded)
		cancel_vent_move()
		return

	if(prob(50))
		audible_message(span_hear("You hear something scampering through the ventilation ducts."))

	addtimer(CALLBACK(src, PROC_REF(finish_vent_move), exit_vent), travel_time)

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
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmos_machines)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								span_hear("You hear something scampering through the ventilation ducts."))

			addtimer(CALLBACK(src, PROC_REF(vent_move), exit_vent), rand(20,60))

	//=================

	else if(prob(33))
		var/list/nearby = oview(10, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			SSmove_manager.move_to(src, target_atom)
			if(prob(40))
				src.visible_message(span_notice("\The [src] skitters[pick(" away"," around","")]."))
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				SSmove_manager.move_to(src, entry_vent, 1)
				break
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if(!grow_as)
				if(prob(3))
					grow_as = pick(/mob/living/basic/giant_spider/tarantula, /mob/living/basic/giant_spider/viper, /mob/living/basic/giant_spider/midwife)
				else
					grow_as = pick(/mob/living/basic/giant_spider, /mob/living/basic/giant_spider/hunter, /mob/living/basic/giant_spider/nurse)
			var/mob/living/basic/giant_spider/S = new grow_as(src.loc)
			S.faction = faction.Copy()
			S.directive = directive
			qdel(src)

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	icon_state = pick("cocoon1","cocoon2","cocoon3")
	. = ..()

/obj/structure/spider/cocoon/container_resist_act(mob/living/user)
	var/breakout_time = 600
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, span_notice("You struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)"))
	visible_message(span_notice("You see something struggling and writhing in \the [src]!"))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message(span_warning("\The [src] splits open."))
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
