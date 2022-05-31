/mob/living/simple_animal/hostile/boss/clockmaster
	name = "Clockwork Priest"
	desc = "A man who has gone mad with the promise of great power from a dead god."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	boss_abilities = list(/datum/action/boss/turret_summon, /datum/action/boss/steam_traps, /datum/action/boss/cogscarab_swarm)
	var/list/phase_2_abilities = list()
	faction = list("clockwork")
	del_on_death = TRUE
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clockminer"
	ranged = TRUE
	environment_smash = ENVIRONMENT_SMASH_NONE
	minimum_distance = 3
	retreat_distance = 3
	obj_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 2000
	maxHealth = 2000
	speed = 1
	loot = list(/obj/effect/temp_visual/paperwiz_dying)
	projectiletype = /obj/projectile/temp
	projectilesound = 'sound/weapons/emitter.ogg'
	attack_sound = 'sound/hallucinations/growl1.ogg'
	var/is_in_phase_2 = FALSE

/mob/living/simple_animal/hostile/boss/clockmaster/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health < maxHealth*0.5 && !is_in_phase_2)
		get_angry()

//TODO: actually make the abilities for his 2nd stage
/mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	name = "Justicar of Bronze"
	desc = "How can you kill a god? What a grand and intoxicating innocence."
	boss_abilities = list(/datum/action/boss/turret_summon, /datum/action/boss/steam_traps, /datum/action/boss/cogscarab_swarm)
	is_in_phase_2 = TRUE

//activates at 50% hp, does a cool monologue before killing this mob and spawning the next stage
/mob/living/simple_animal/hostile/boss/clockmaster/proc/get_angry()
	is_in_phase_2 = TRUE
	point_regen_delay = 0 //prevents dummy from shooting off additional abilities during the monologue
	ranged = FALSE
	name = "Awakened Clockwork Priest"
	desc = "A shell of a man who has gone mad with the promise of great power from a not-so-dead god."
	for(var/mob/living/nearby_mob in urange(8, src))
		shake_camera(nearby_mob, 2, 3)
		nearby_mob.Paralyze(25 SECONDS)
		to_chat(nearby_mob, span_warning("You feel yourself tense up at the sound of [src]!"))
	say("ENOUGH!")
	sleep(3 SECONDS)
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockpriest_ascend"
	pixel_x = -32
	base_pixel_x = -32
	maptext_height = 96
	maptext_width = 96
	say("I should of known relying on mere mortals is a foolish endeavour, as if the ruins of my previous body wasn't evidence enough.")
	sleep(7 SECONDS)
	say("I do not know what brought you here. Whether it be your employers that enshackle my kin, that wicked blood mother or your own foolish curiosity.")
	sleep(8 SECONDS)
	say("What I do know is that I've grown tired of festering in this forsaken pit and a Heretic such as yourself will NOT stop my return.")
	sleep(7 SECONDS)
	say("Now, bear witness and cower before me! Rehd qdum, buj jxo ijuqc vbem jxhekwx qdt sewi ifyd! Qbb mybb adem co jhku dqcu ev Ratvar!")
	sleep(7 SECONDS)
	gib()


//summons a set of ocular warden turrets placed throughout the arena. If no turret slots avaiable, refund boss points.
//TODO: actually finish this boss action
/datum/action/boss/turret_summon
	name = "Raise Ocular Warden"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 20
	boss_cost = 50
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster
	say_when_triggered = "Arise once more, watchful guardians! Yrg Uvf Tenpvbhf Yvtug thvqr lbhe nvz gehr!"

/datum/action/boss/steam_traps/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(vents_active)
		return FALSE
	return TRUE

/datum/action/boss/turret_summon/Trigger(trigger_flags)


/obj/effect/landmark/ocularwarden_boss_spawn
	name = "occular warden tower spawner for the cool clock cult arena"
	var/id = "clockmaster"


//temporaily activates steam traps placed throughout the arena, which cause burn damage if walked into. If steam traps are active already, refund boss points.
/datum/action/boss/steam_traps
	name = "Activate Steam Traps"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "mimic_summon"
	usage_probability = 50
	boss_cost = 25
	boss_type = /mob/living/simple_animal/hostile/boss/clockmaster
	say_when_triggered = "Step into the cleansing steam, burn away your sins for your slights against His Gracious Light!"
	var/vents_active = FALSE
	var/id = "clockmaster"

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
	var/id = "clockmaster"
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
	usage_probability = 20
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
