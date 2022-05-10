
/mob/living/carbon/proc/set_screwyhud(hud_type)
	hal_screwyhud = hud_type
	update_health_hud()

/*
/obj/effect/hallucination/simple/clown
	image_icon = 'icons/mob/animal.dmi'
	image_state = "clown"

/obj/effect/hallucination/simple/clown/Initialize(mapload, mob/living/carbon/T, duration)
	..(loc, T)
	name = pick(GLOB.clown_names)
	QDEL_IN(src,duration)

/obj/effect/hallucination/simple/clown/scary
	image_state = "scary_clown"
*/

/datum/hallucination/delusion
	var/list/image/delusions = list()

/datum/hallucination/delusion/New(mob/living/carbon/C, forced, force_kind = null , duration = 300,skip_nearby = TRUE, custom_icon = null, custom_icon_file = null, custom_name = null)
	set waitfor = FALSE
	. = ..()
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("nothing","monkey","corgi","carp","skeleton","demon","zombie")
	feedback_details += "Type: [kind]"
	var/list/nearby
	if(skip_nearby)
		nearby = get_hearers_in_view(7, hallucinator)
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H == hallucinator)
			continue
		if(skip_nearby && (H in nearby))
			continue
		switch(kind)
			if("nothing")
				A = image('icons/effects/effects.dmi',H,"nothing")
				A.name = "..."
			if("monkey")//Monkey
				A = image('icons/mob/human.dmi',H,"monkey")
				A.name = "Monkey ([rand(1,999)])"
			if("carp")//Carp
				A = image('icons/mob/carp.dmi',H,"carp")
				A.name = "Space Carp"
			if("corgi")//Corgi
				A = image('icons/mob/pets.dmi',H,"corgi")
				A.name = "Corgi"
			if("skeleton")//Skeletons
				A = image('icons/mob/human.dmi',H,"skeleton")
				A.name = "Skeleton"
			if("zombie")//Zombies
				A = image('icons/mob/human.dmi',H,"zombie")
				A.name = "Zombie"
			if("demon")//Demon
				A = image('icons/mob/mob.dmi',H,"daemon")
				A.name = "Demon"
			if("custom")
				A = image(custom_icon_file, H, custom_icon)
				A.name = custom_name
		A.override = 1
		if(hallucinator.client)
			delusions |= A
			hallucinator.client.images |= A
	if(duration)
		QDEL_IN(src, duration)

/datum/hallucination/delusion/Destroy()
	for(var/image/I in delusions)
		if(hallucinator.client)
			hallucinator.client.images.Remove(I)
	return ..()

/datum/hallucination/self_delusion
	var/image/delusion

/datum/hallucination/self_delusion/New(mob/living/carbon/C, forced, force_kind = null , duration = 300, custom_icon = null, custom_icon_file = null, wabbajack = TRUE) //set wabbajack to false if you want to use another fake source
	set waitfor = FALSE
	..()
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("monkey","corgi","carp","skeleton","demon","zombie","robot")
	feedback_details += "Type: [kind]"
	switch(kind)
		if("monkey")//Monkey
			A = image('icons/mob/human.dmi',hallucinator,"monkey")
		if("carp")//Carp
			A = image('icons/mob/animal.dmi',hallucinator,"carp")
		if("corgi")//Corgi
			A = image('icons/mob/pets.dmi',hallucinator,"corgi")
		if("skeleton")//Skeletons
			A = image('icons/mob/human.dmi',hallucinator,"skeleton")
		if("zombie")//Zombies
			A = image('icons/mob/human.dmi',hallucinator,"zombie")
		if("demon")//Demon
			A = image('icons/mob/mob.dmi',hallucinator,"daemon")
		if("robot")//Cyborg
			A = image('icons/mob/robots.dmi',hallucinator,"robot")
			hallucinator.playsound_local(hallucinator,'sound/voice/liveagain.ogg', 75, 1)
		if("custom")
			A = image(custom_icon_file, hallucinator, custom_icon)
	A.override = 1
	if(hallucinator.client)
		if(wabbajack)
			to_chat(hallucinator, span_hear("...wabbajack...wabbajack..."))
			hallucinator.playsound_local(hallucinator,'sound/magic/staff_change.ogg', 50, 1)
		delusion = A
		hallucinator.client.images |= A
	QDEL_IN(src, duration)

/datum/hallucination/self_delusion/Destroy()
	if(hallucinator.client)
		hallucinator.client.images.Remove(delusion)
	return ..()

/datum/hallucination/bolts
	var/list/airlocks_to_hit
	var/list/locks
	var/next_action = 0
	var/locking = TRUE

/datum/hallucination/bolts/New(mob/living/carbon/C, forced, door_number)
	set waitfor = FALSE
	..()
	if(!door_number)
		door_number = rand(0,4) //if 0 bolts all visible doors
	var/count = 0
	feedback_details += "Door amount: [door_number]"

	for(var/obj/machinery/door/airlock/A in range(7, hallucinator))
		if(count>door_number && door_number>0)
			break
		if(!A.density)
			continue
		count++
		LAZYADD(airlocks_to_hit, A)

	if(!LAZYLEN(airlocks_to_hit)) //no valid airlocks in sight
		qdel(src)
		return

	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/bolts/process(delta_time)
	next_action -= (delta_time * 10)
	if (next_action > 0)
		return

	if (locking)
		var/atom/next_airlock = pop(airlocks_to_hit)
		if (next_airlock)
			var/obj/effect/hallucination/fake_door_lock/lock = new(get_turf(next_airlock))
			lock.target = target
			lock.airlock = next_airlock
			LAZYADD(locks, lock)

		if (!LAZYLEN(airlocks_to_hit))
			locking = FALSE
			next_action = 10 SECONDS
			return
	else
		var/obj/effect/hallucination/fake_door_lock/next_unlock = popleft(locks)
		if (next_unlock)
			next_unlock.unlock()
		else
			qdel(src)
			return

	next_action = rand(4, 12)

/datum/hallucination/bolts/Destroy()
	. = ..()
	QDEL_LIST(locks)
	STOP_PROCESSING(SSfastprocess, src)

/obj/effect/hallucination/fake_door_lock
	layer = CLOSED_DOOR_LAYER + 1 //for Bump priority
	plane = GAME_PLANE
	var/image/bolt_light
	var/obj/machinery/door/airlock/airlock

/obj/effect/hallucination/fake_door_lock/proc/lock()
	bolt_light = image(airlock.overlays_file, get_turf(airlock), "lights_bolts",layer=airlock.layer+0.1)
	if(hallucinator.client)
		hallucinator.client.images |= bolt_light
		hallucinator.playsound_local(get_turf(airlock), 'sound/machines/boltsdown.ogg',30,0,3)

/obj/effect/hallucination/fake_door_lock/proc/unlock()
	if(hallucinator.client)
		hallucinator.client.images.Remove(bolt_light)
		hallucinator.playsound_local(get_turf(airlock), 'sound/machines/boltsup.ogg',30,0,3)
	qdel(src)

/obj/effect/hallucination/fake_door_lock/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == target && airlock.density)
		return FALSE

/datum/hallucination/hudscrew

/datum/hallucination/hudscrew/New(mob/living/carbon/C, forced = TRUE, screwyhud_type)
	set waitfor = FALSE
	..()
	//Screwy HUD
	var/chosen_screwyhud = screwyhud_type
	if(!chosen_screwyhud)
		chosen_screwyhud = pick(SCREWYHUD_CRIT,SCREWYHUD_DEAD,SCREWYHUD_HEALTHY)
	hallucinator.set_screwyhud(chosen_screwyhud)
	feedback_details += "Type: [hallucinator.hal_screwyhud]"
	QDEL_IN(src, rand(100, 250))

/datum/hallucination/hudscrew/Destroy()
	hallucinator.set_screwyhud(SCREWYHUD_NONE)
	return ..()

/datum/hallucination/dangerflash

/datum/hallucination/dangerflash/New(mob/living/carbon/C, forced = TRUE, danger_type)
	set waitfor = FALSE
	..()
	//Flashes of danger

	var/list/possible_points = list()
	for(var/turf/open/floor/F in view(hallucinator,world.view))
		possible_points += F
	if(possible_points.len)
		var/turf/open/floor/danger_point = pick(possible_points)
		if(!danger_type)
			danger_type = pick("lava","chasm","anomaly")
		switch(danger_type)
			if("lava")
				new /obj/effect/hallucination/danger/lava(danger_point, hallucinator)
			if("chasm")
				new /obj/effect/hallucination/danger/chasm(danger_point, hallucinator)
			if("anomaly")
				new /obj/effect/hallucination/danger/anomaly(danger_point, hallucinator)

	qdel(src)

/obj/effect/hallucination/danger
	var/image/image

/obj/effect/hallucination/danger/proc/show_icon()
	return

/obj/effect/hallucination/danger/proc/clear_icon()
	if(image && hallucinator.client)
		hallucinator.client.images -= image

/obj/effect/hallucination/danger/Initialize(mapload, _hallucinator)
	. = ..()
	target = _target
	show_icon()
	QDEL_IN(src, rand(200, 450))

/obj/effect/hallucination/danger/Destroy()
	clear_icon()
	. = ..()

/obj/effect/hallucination/danger/lava
	name = "lava"

/obj/effect/hallucination/danger/lava/Initialize(mapload, _hallucinator)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/lava/show_icon()
	var/turf/danger_turf = get_turf(src)
	image = image('icons/turf/floors/lava.dmi', src, "lava-[danger_turf.smoothing_junction || 0]", TURF_LAYER)
	if(hallucinator.client)
		hallucinator.client.images += image

/obj/effect/hallucination/danger/lava/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(entered != hallucinator)
		return

	hallucinator.adjustStaminaLoss(20)
	hallucinator.cause_hallucination(/datum/hallucination/fire, source = "fake lava hallucination")

/obj/effect/hallucination/danger/chasm
	name = "chasm"

/obj/effect/hallucination/danger/chasm/Initialize(mapload, _hallucinator)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/chasm/show_icon()
	var/turf/danger_turf = get_turf(src)
	image = image('icons/turf/floors/chasms.dmi', src, "chasms-[danger_turf.smoothing_junction || 0]", TURF_LAYER)
	if(hallucinator.client)
		hallucinator.client.images += image

/obj/effect/hallucination/danger/chasm/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == hallucinator)
		if(istype(hallucinator, /obj/effect/dummy/phased_mob))
			return
		to_chat(hallucinator, span_userdanger("You fall into the chasm!"))
		hallucinator.Paralyze(40)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, hallucinator, span_notice("It's surprisingly shallow.")), 15)
		QDEL_IN(src, 30)

/obj/effect/hallucination/danger/anomaly
	name = "flux wave anomaly"

/obj/effect/hallucination/danger/anomaly/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/anomaly/process(delta_time)
	if(DT_PROB(45, delta_time))
		step(src,pick(GLOB.alldirs))

/obj/effect/hallucination/danger/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/hallucination/danger/anomaly/show_icon()
	image = image('icons/effects/effects.dmi',src,"electricity2",OBJ_LAYER+0.01)
	if(hallucinator.client)
		hallucinator.client.images += image

/obj/effect/hallucination/danger/anomaly/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(entered != hallucinator)
		return

	hallucinator.cause_hallucination(/datum/hallucination/shock, source = "fake anomaly hallucination")

#define RAISE_FIRE_COUNT 3
#define RAISE_FIRE_TIME 3

/datum/hallucination/fire
	var/active = TRUE
	var/stage = 0
	var/image/fire_overlay

	var/next_action = 0
	var/times_to_lower_stamina
	var/fire_clearing = FALSE
	var/increasing_stages = TRUE
	var/time_spent = 0

/datum/hallucination/fire/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	hallucinator.set_fire_stacks(max(hallucinator.fire_stacks, 0.1)) //Placebo flammability
	fire_overlay = image('icons/mob/onfire.dmi', hallucinator, "human_burning", ABOVE_MOB_LAYER)
	if(hallucinator.client)
		hallucinator.client.images += fire_overlay
	to_chat(hallucinator, span_userdanger("You're set on fire!"))
	hallucinator.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire, override = TRUE)
	times_to_lower_stamina = rand(5, 10)
	addtimer(CALLBACK(src, .proc/start_expanding), 20)

/datum/hallucination/fire/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/hallucination/fire/proc/start_expanding()
	if (isnull(hallucinator))
		qdel(src)
		return
	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/fire/process(delta_time)
	if (isnull(hallucinator))
		qdel(src)
		return

	if(hallucinator.fire_stacks <= 0)
		clear_fire()

	time_spent += delta_time

	if (fire_clearing)
		next_action -= delta_time
		if (next_action < 0)
			stage -= 1
			update_temp()
			next_action += 3
	else if (increasing_stages)
		var/new_stage = min(round(time_spent / RAISE_FIRE_TIME), RAISE_FIRE_COUNT)
		if (stage != new_stage)
			stage = new_stage
			update_temp()

			if (stage == RAISE_FIRE_COUNT)
				increasing_stages = FALSE
	else if (times_to_lower_stamina)
		next_action -= delta_time
		if (next_action < 0)
			hallucinator.adjustStaminaLoss(15)
			next_action += 2
			times_to_lower_stamina -= 1
	else
		clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
	else
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
		hallucinator.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(!active)
		return
	active = FALSE
	hallucinator.clear_alert(ALERT_FIRE, clear_override = TRUE)
	if(hallucinator.client)
		hallucinator.client.images -= fire_overlay
	QDEL_NULL(fire_overlay)
	fire_clearing = TRUE
	next_action = 0

#undef RAISE_FIRE_COUNT
#undef RAISE_FIRE_TIME
