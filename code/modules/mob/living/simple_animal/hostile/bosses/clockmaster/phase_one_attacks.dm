//Summons a set of ocular warden turrets placed at landmarks in the arena. If there are any turrets still active, more will not spawn.
/datum/action/boss/turret_summon
	name = "Raise Ocular Warden"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster
	say_when_triggered = "Arise once more, watchful guardians! Yrg Uvf Tenpvbhf Yvtug thvqr lbhe nvz gehr!"
	var/id = "clockmasterocularwarden"

/datum/action/boss/turret_summon/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/action/boss/turret_summon/Trigger(trigger_flags)
	if(..())
		SEND_GLOBAL_SIGNAL(COMSIG_ACTION_TRIGGER_ID,src)

/obj/effect/landmark/ocularwarden_turret_spawn
	name = "occular warden tower spawner for the cool clock cult arena"
	var/id = "clockmasterocularwarden"

/obj/effect/landmark/ocularwarden_turret_spawn/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs,COMSIG_ACTION_TRIGGER_ID, .proc/OnActionActivation)

//Spawns a turret on the landmark's turf if no turret exists there currently.
/obj/effect/landmark/ocularwarden_turret_spawn/proc/OnActionActivation(datum/source,datum/action/boss/turret_summon/boss)
	SIGNAL_HANDLER

	if(boss.id == id)
		var/turf/turret_tile = get_turf(src)
		if(!(locate(/mob/living/simple_animal/hostile/ocular_warden) in turret_tile))
			new /mob/living/simple_animal/hostile/ocular_warden(turret_tile)


/mob/living/simple_animal/hostile/ocular_warden
	name = "Ocular Warden"
	desc = "A pristine bronze machine with a giant beady eye. It stares at you menancingly."
	icon = 'icons/mob/mob.dmi'
	icon_state = "ocular_warden"
	icon_state = "ocular_warden"
	icon_dead = "drone_clock_dead"
	ranged = 1
	rapid = 2
	rapid_fire_delay = 6
	stop_automated_movement = TRUE
	projectiletype = /obj/projectile/beam/laser/ocularwarden
	speak_chance = 0
	stat_attack = HARD_CRIT
	maxHealth = 35
	health = 35
	rapid_melee = 2
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	deathmessage = "breaks apart into various metallic debris!"
	combat_mode = TRUE
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	speech_span = SPAN_ROBOT
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("clockwork")
	del_on_death = 1

/mob/living/simple_animal/hostile/ocular_warden/Move(atom/newloc)//stop moving please
	return FALSE

/obj/projectile/beam/laser/ocularwarden
	name = "hellfire laser"
	wound_bonus = -35
	damage = 5

/obj/projectile/beam/laser/ocularwarden/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(IS_CULTIST(M))
			M.adjust_bodytemperature(30)
			to_chat(M, span_warning("You feel a burning gaze strike your inner core, as if Ratvar himself is staring you down intently."))

//Activates a series of steam traps placed around the arena. Stepping onto these while active throws the victim back a few tiles and causes burn damage.
/datum/action/boss/steam_traps
	name = "Activate Steam Traps"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 20
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster
	say_when_triggered = "Step into the cleansing steam, burn away your sins for your slights against His Gracious Light!"
	var/vents_active = FALSE
	var/id = "clockmastersteamvent"

/datum/action/boss/steam_traps/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(vents_active)
		return FALSE
	return TRUE

/datum/action/boss/steam_traps/Trigger(trigger_flags)
	if(..())
		SEND_GLOBAL_SIGNAL(COMSIG_ACTION_TRIGGER_ID,src)


/obj/structure/steamvent
	name = "steam pit"
	desc = "An exhaust hole covered by a protective metal grate."
	icon = 'icons/obj/structures.dmi'
	icon_state = "vent_off"
	density = FALSE
	opacity = FALSE
	plane = FLOOR_PLANE
	anchored = TRUE
	var/id = "clockmastersteamvent"
	var/active = FALSE

/obj/structure/steamvent/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs,COMSIG_ACTION_TRIGGER_ID, .proc/OnActionActivation)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/steamvent/proc/OnActionActivation(datum/source,datum/action/boss/steam_traps/boss)
	SIGNAL_HANDLER

	if(!active && boss.id == id)
		active = TRUE
		icon_state = "vent_on"
		addtimer(CALLBACK(src, .proc/VentDisable), 300)

/obj/structure/steamvent/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(active && isliving(AM))
		var/mob/living/L = AM
		var/atom/throw_target = get_edge_target_turf(L, pick(GLOB.cardinals))
		to_chat(L, span_warning("You're blasted by a searing column of steam!"))
		L.adjustFireLoss(rand(10,15))
		L.throw_at(throw_target, 4, 1)

/obj/structure/steamvent/proc/VentDisable()
	active = FALSE
	icon_state = "vent_off"


//summon a small swarm of cogscarabs that attack in a group, weak but helps redirect player attacks elsewhere.
/datum/action/boss/cogscarab_swarm
	name = "Summon Cogscarab Swarm"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 15
	boss_cost = 40
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster
	say_when_triggered = "Devout machines of His Grand Design, arise! Yrg ab Urergvp gerffcnff hcba Uvf Qbznva!"
	var/summoned_cogscarabs = 0
	var/max_cogscarabs = 8
	var/cogscarabs_to_summon = 4

/datum/action/boss/cogscarab_swarm/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(summoned_cogscarabs >= max_cogscarabs)
		return FALSE
	return TRUE

/datum/action/boss/cogscarab_swarm/Trigger(trigger_flags)
	if(..())
		var/directions = GLOB.cardinals.Copy()
		for(var/i in 1 to 4)
			var/mob/living/target = boss
			var/atom/active_cogscarab = new /mob/living/simple_animal/hostile/cogscarab(get_step(target,pick_n_take(directions)))
			RegisterSignal(active_cogscarab, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/lost_cogscarab)
			summoned_cogscarabs++
	else
		boss.atb.refund(boss_cost)

/datum/action/boss/cogscarab_swarm/proc/lost_cogscarab(mob/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	summoned_cogscarabs--

/mob/living/simple_animal/hostile/cogscarab
	name = "Cogscarab"
	desc = "A station maintenance drone adorned in intricate bronze detailing. Its front sensor glows an eery red."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	speak_chance = 0
	turns_per_move = 5
	speed = 2
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 17
	health = 17
	harm_intent_damage = 3
	melee_damage_lower = 3
	melee_damage_upper = 3
	rapid_melee = 2
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	deathmessage = "breaks apart into various metallic debris!"
	combat_mode = TRUE
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	speech_span = SPAN_ROBOT
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("clockwork")
	del_on_death = 1
