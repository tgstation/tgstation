/**
  * # Space Dragon
  *
  * A space-faring monstrosity who has the ability to breathe dangerous fire breath and uses its powerful wings to knock foes away.
  * Normally spawned as an antagonist during the Space Dragon event, Space Dragon's main goal is to open a rift from which to pull a great tide of carp onto the station.
  * Space Dragon can summon only one rift, and can do so anywhere a blob is allowed to spawn.  In order to trigger his victory condition, Space Dragon must summon and defend 3 rifts while they charge.
  * Space Dragon, when spawned, has 5 minutes to summon the first rift.  Failing to do so will cause Space Dragon to return from whence he came.
  * When the rift spawns, ghosts can interact with it to spawn in as space carp to help complete the mission.  1 carp are granted when the rift is first summoned, with an extra one every 40 seconds.
  * Once the victory condition is met, the shuttle is called and all current rifts are allowed to spawn infinite sentient space carp.
  * If a charging rift is destroyed, Space Dragon will be incredibly slowed, and the endlag on his gust attack is greatly increased on each use.
  * Space Dragon has the following abilities to assist him in the objective:
  * - Can shoot fire in straight line, dealing 30 burn damage and setting those suseptible on fire.
  * - Can use his wings to temporarily stun and knock back any nearby mobs.  This attack has no cooldown, but instead has endlag after the attack where Space Dragon cannot act.  This endlag's time decreases over time, but is added to every time he uses the move.
  * - Can swallow mob corpses to heal for half their max health.  Any corpses swallowed are stored within him, and will be regurgitated on death.
  * - Can tear through any type of wall.  This takes 6 seconds for most walls, and 30 seconds for reinforced walls.
  */

/mob/living/simple_animal/hostile/space_dragon
	name = "Space Dragon"
	desc = "A vile leviathan-esque creature that flies in the most unnatural way.  Slightly looks similar to a space carp."
	maxHealth = 400
	health = 400
	spacewalk = TRUE
	a_intent = INTENT_HARM
	speed = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	icon = 'icons/mob/spacedragon.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	health_doll_icon = "spacedragon"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_NONE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1 | HEAR_1
	melee_damage_upper = 35
	melee_damage_lower = 35
	armour_penetration = 30
	pixel_x = -16
	turns_per_move = 5
	ranged = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	deathmessage = "screeches as its wings turn to dust and it collapses on the floor, life estinguished."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	pressure_resistance = 200
	var/riftTimer = 0
	var/maxRiftTimer = 300
	var/tiredness = 0
	var/tiredness_mult = 1
	var/using_special = FALSE
	var/list/obj/structure/carp_rift/rift_list = list()
	var/rifts_charged = 0
	var/objective_complete = FALSE
	var/small_sprite_type = /datum/action/small_sprite/megafauna/spacedragon
	var/datum/action/innate/space_dragon/gustAttack/gust
	var/datum/action/innate/space_dragon/summonRift/rift

/mob/living/simple_animal/hostile/space_dragon/Initialize(mapload)
	. = ..()
	if(small_sprite_type)
		var/datum/action/small_sprite/small_action = new small_sprite_type()
		small_action.Grant(src)
	gust = new
	gust.Grant(src)
	rift = new
	rift.Grant(src)

/mob/living/simple_animal/hostile/space_dragon/Life(mapload)
	. = ..()
	tiredness = max(tiredness - 1, 0)
	if(rifts_charged == 3 && !objective_complete)
		victory()
	if(riftTimer == -1)
		return
	riftTimer = min(riftTimer + 1, maxRiftTimer + 1)
	if(riftTimer == (maxRiftTimer - 60))
		to_chat(src, "<span class='boldwarning'>You have a minute left to summon the rift!  Get to it!</span>")
		return
	if(riftTimer == maxRiftTimer)
		to_chat(src, "<span class='boldwarning'>You've failed to summon the rift in a timely manner!  You're being pulled back from whence you came!</span>")
		destroy_rifts()
		QDEL_NULL(src)

/mob/living/simple_animal/hostile/space_dragon/AttackingTarget()
	if(using_special)
		return
	if(target == src)
		to_chat(src, "<span class='warning'>You almost bite yourself, but then decide against it.</span>")
		return
	if(istype(target, /turf/closed/wall))
		var/turf/closed/wall/thewall = target
		to_chat(src, "<span class='warning'>You begin tearing through the wall...</span>")
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		var/timetotear = 40
		if(istype(target, /turf/closed/wall/r_wall))
			timetotear = 120
		if(do_after(src, timetotear, target = thewall))
			if(istype(thewall, /turf/open))
				return
			thewall.dismantle_wall(1)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		return
	if(isliving(target)) //Swallows corpses like a snake to regain health.
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(src, "<span class='warning'>You begin to swallow [L] whole...</span>")
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-L.maxHealth * 0.5)
			return
	. = ..()

/mob/living/simple_animal/hostile/space_dragon/Move()
	if(!using_special)
		..()

/mob/living/simple_animal/hostile/space_dragon/OpenFire()
	if(using_special)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	fire_stream()

/mob/living/simple_animal/hostile/space_dragon/death(gibbed)
	empty_contents()
	if(!objective_complete)
		destroy_rifts()
	..()

/mob/living/simple_animal/hostile/space_dragon/wabbajack_act(mob/living/new_mob)
	empty_contents()
	. = ..()

//Calculates a line of paths from the mob to the target, going out a variable distance
/mob/living/simple_animal/hostile/space_dragon/proc/line_target(offset, range, atom/at = target)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y) + offset
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (getline(src, T) - get_turf(src))

//Handles spawning the fire on each of the tiles when fire breath is used
/mob/living/simple_animal/hostile/space_dragon/proc/fire_stream(var/atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, TRUE)
	var/range = 20
	var/list/turfs = list()
	turfs = line_target(0, range, at)
	var/delayFire = -1.5
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			return
		for(var/obj/structure/window/W in T.contents)
			return
		for(var/obj/machinery/door/D in T.contents)
			return
		delayFire += 1.5
		addtimer(CALLBACK(src, .proc/dragon_fire_line, T), delayFire)

//The proc used on each tile to damage enemies on the tile and create a hotspot there as well.  Very effective against mechs.
mob/living/simple_animal/hostile/space_dragon/proc/dragon_fire_line(turf/T)
	var/list/hit_list = list()
	hit_list += src
	new /obj/effect/hotspot(T)
	T.hotspot_expose(700,50,1)
	for(var/mob/living/L in T.contents)
		if(L in hit_list)
			continue
		hit_list += L
		L.adjustFireLoss(30)
		to_chat(L, "<span class='userdanger'>You're hit by [src]'s fire breath!</span>")
	// deals damage to mechs
	for(var/obj/mecha/M in T.contents)
		if(M in hit_list)
			continue
		hit_list += M
		M.take_damage(50, BRUTE, "melee", 1)

//Handles storing the entity inside Space Dragon after they've been consumed
/mob/living/simple_animal/hostile/space_dragon/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		playsound(src, 'sound/magic/demon_attack1.ogg', 100, TRUE)
		visible_message("<span class='warning'>[src] swallows [A] whole!</span>")
		A.forceMove(src)
		return TRUE
	return FALSE

//Randomly disperses consumed objects in an area around the mob
/mob/living/simple_animal/hostile/space_dragon/proc/empty_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

//Resets Space Dragon to a normal stance after using a special
/mob/living/simple_animal/hostile/space_dragon/proc/reset_status()
	if(stat != DEAD)
		icon_state = "spacedragon"
	using_special = FALSE

//Destroys all the currently spawned rifts.  Used on death or when a rift is destroyed.
/mob/living/simple_animal/hostile/space_dragon/proc/destroy_rifts()
	for(var/obj/structure/carp_rift/rift in rift_list)
		rift.dragon = null
		rift_list -= rift
		if(!QDELETED(rift))
			QDEL_NULL(rift)
	rifts_charged = 0

//Handles the windup to using gust, gust itself, and the delay to returning to normal after using it.
/mob/living/simple_animal/hostile/space_dragon/proc/useGust(timer)
	if(timer != 10)
		pixel_y = pixel_y + 2;
		addtimer(CALLBACK(src, .proc/useGust, timer + 1), 1.5)
		return
	pixel_y = 0
	icon_state = "spacedragon_gust_2"
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)
	var/gust_locs = spiral_range_turfs(3, get_turf(src))
	var/list/hit_things = list()
	for(var/turf/T in gust_locs)
		for(var/mob/living/L in T.contents)
			if(L == src)
				continue
			hit_things += L
			visible_message("<span class='boldwarning'>[L] is knocked back by the gust!</span>")
			to_chat(L, "<span class='userdanger'>You're knocked back by the gust!</span>")
			var/dir_to_target = get_dir(get_turf(src), get_turf(L))
			var/throwtarget = get_edge_target_turf(target, dir_to_target)
			L.safe_throw_at(throwtarget, 10, 1, src)
			L.Paralyze(50)
	addtimer(CALLBACK(src, .proc/reset_status), 4 + ((tiredness * tiredness_mult) / 10))
	tiredness = tiredness + (30 * tiredness_mult)

//Method used when Space Dragon wins.  Sets his rifts to spawn infinite carp, and irrevokably calls the shuttle, along with setting Space Dragon's objective to be complete.
/mob/living/simple_animal/hostile/space_dragon/proc/victory()
	objective_complete = TRUE
	var/datum/antagonist/space_dragon/S = mind.has_antag_datum(/datum/antagonist/space_dragon)
	if(S)
		var/datum/objective/summon_carp/main_objective = locate() in S.objectives
		if(main_objective)
			main_objective.completed = TRUE
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	priority_announce("A large amount of lifeforms have been detected approaching [station_name()] at extreme speeds.  Evacuation of the remamining crew will begin immediately.", "Central Command Spacial Corps")
	sleep(50)
	SSshuttle.emergency.request(null, set_coefficient = 0.3)

/datum/action/innate/space_dragon
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_space_dragon.dmi'

/datum/action/innate/space_dragon/gustAttack
	name = "Gust Attack"
	button_icon_state = "gust_attack"
	desc = "Use your wings to knock back foes with gusts of air, pushing them away and stunning them.  Using this too often will leave you vulnerable for longer periods of time."

/datum/action/innate/space_dragon/gustAttack/Activate()
	var/mob/living/simple_animal/hostile/space_dragon/S = owner
	if(S.using_special)
		return
	S.using_special = TRUE
	S.icon_state = "spacedragon_gust"
	S.useGust(0)

/datum/action/innate/space_dragon/summonRift
	name = "Summon Rift"
	button_icon_state = "carp_rift"
	desc = "Summon a rift to bring forth a horde of space carp."

/datum/action/innate/space_dragon/summonRift/Activate()
	var/mob/living/simple_animal/hostile/space_dragon/S = owner
	if(S.using_special)
		return
	var/area/A = get_area(S)
	if(!A.valid_territory)
		to_chat(S, "<span class='warning'>You can't summon a rift here!  Try summoning somewhere secure within the station!</span>")
		return
	for(var/obj/structure/carp_rift/rift in S.rift_list)
		var/area/RA = get_area(rift)
		if(RA == A)
			to_chat(S, "<span class='warning'>You've already summoned a rift in this area!  You have to summon again somewhere else!</span>")
			return
	to_chat(S, "<span class='warning'>You begin to open a rift...</span>")
	if(do_after(S, 100, target = S))
		for(var/obj/structure/carp_rift/c in S.loc.contents)
			return
		var/obj/structure/carp_rift/CR = new /obj/structure/carp_rift(S.loc)
		playsound(S, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
		S.riftTimer = -1
		CR.dragon = S
		S.rift_list += CR
		to_chat(S, "<span class='boldwarning'>The rift has been summoned.  Prevent the crew from destroying it at all costs!</span>")
		notify_ghosts("\[S] has opened a rift!", source = CR, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Rift Opened")
		QDEL_NULL(src)

/obj/structure/carp_rift
	name = "carp rift"
	desc = "A rift akin to the ones space carp use to travel long distances."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift"
	light_color = LIGHT_COLOR_BLUE
	light_range = 10
	anchored = TRUE
	density = FALSE
	var/time_charged = 0
	var/max_charge = 240
	var/carp_stored = 0
	var/mob/living/simple_animal/hostile/space_dragon/dragon

/obj/structure/carp_rift/Initialize(mapload)
	. = ..()
	carp_stored = 1
	time_charged = 1
	START_PROCESSING(SSobj, src)

/obj/structure/carp_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/carp_rift/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(time_charged != max_charge + 1)
		to_chat(dragon, "<span class='boldwarning'>The rift has been destroyed!  You have failed, and find yourself brought down by the weight of your failure.</span>")
		dragon.set_varspeed(5)
		dragon.tiredness_mult = 5
		dragon.destroy_rifts()
		playsound(src, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	return ..()

/obj/structure/carp_rift/process()
	time_charged = min(time_charged + 1, max_charge + 1)
	update_check()
	if(time_charged < max_charge)
		desc = "A rift akin to the ones space carp use to travel long distances.  It seems to be [(time_charged / max_charge) * 100]% charged."
		if(carp_stored == 0)
			icon_state = "carp_rift"
			light_color = LIGHT_COLOR_BLUE
		else
			icon_state = "carp_rift_carpspawn"
			light_color = LIGHT_COLOR_PURPLE
	else
		var/spawncarp = rand(1,40)
		if(spawncarp == 1)
			new /mob/living/simple_animal/hostile/carp(loc)

//Checks to see if the rift is done charging, if it's time to announce the location or add another space carp spawn.
/obj/structure/carp_rift/proc/update_check()
	if(time_charged % 40 == 0 && time_charged != max_charge)
		carp_stored++
	if(time_charged == (max_charge - 120))
		var/area/A = get_area(src)
		priority_announce("A rift is causing an unnaturally large energy flux in [A.map_name].  Stop it at all costs!", "Central Command Spacial Corps", 'sound/ai/spanomalies.ogg')
	if(time_charged == max_charge)
		var/area/A = get_area(src)
		priority_announce("Spatial object has reached peak energy charge in [A.map_name], please stand-by.", "Central Command Spacial Corps")
		obj_integrity = INFINITY
		desc = "A rift akin to the ones space carp use to travel long distances.  This one is fully charged, and is capable of bringing many carp to the station's location."
		icon_state = "carp_rift_charged"
		light_color = LIGHT_COLOR_YELLOW
		armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
		resistance_flags = INDESTRUCTIBLE
		dragon.rifts_charged += 1
		if(dragon.rifts_charged != 3)
			dragon.rift = new
			dragon.rift.Grant(dragon)
			dragon.riftTimer = 0

/obj/structure/carp_rift/attack_ghost(mob/user)
	. = ..()
	summon_carp(user)

//Triggers when a ghost interacts with the portal.  If a carp spawn is available, give them the option to spawn in.
/obj/structure/carp_rift/proc/summon_carp(mob/user)
	if(carp_stored == 0)//Not enough carp points
		return FALSE
	var/carp_ask = alert("Become a carp?", "Help bring forth the horde?", "Yes", "No")
	if(carp_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(carp_stored == 0)
		to_chat(user, "<span class='warning'>The rift already summoned enough carp!</span>")
		return FALSE
	var/mob/living/simple_animal/hostile/carp/newcarp = new /mob/living/simple_animal/hostile/carp(loc)
	newcarp.key = user.key
	var/datum/antagonist/space_dragon/S = dragon.mind.has_antag_datum(/datum/antagonist/space_dragon)
	if(S)
		S.carp += newcarp.mind
	to_chat(newcarp, "<span class='boldwarning'>You have arrived in order to assist the space dragon with securing the rift.  Do not jeopardize the mission, and protect the rift at all costs!</span>")
	carp_stored -= 1
	return TRUE
