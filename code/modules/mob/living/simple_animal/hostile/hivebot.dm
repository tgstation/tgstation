/obj/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "hivebot"
	desc = "A small robot."
	icon = 'icons/mob/simple/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	health = 15
	maxHealth = 15
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	projectiletype = /obj/projectile/hivebotbullet
	faction = list(FACTION_HIVEBOT)
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	var/alert_light

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/hivebot/Initialize(mapload)
	. = ..()
	death_message = "[src] blows apart!"

/mob/living/simple_animal/hostile/hivebot/Aggro()
	. = ..()
	set_combat_mode(TRUE)
	update_icons()
	if(prob(5))
		say(pick("INTRUDER DETECTED!", "CODE 7-34.", "101010!!"), forced = type)

/mob/living/simple_animal/hostile/hivebot/LoseAggro()
	. = ..()
	set_combat_mode(FALSE)
	update_icons()

/mob/living/simple_animal/hostile/hivebot/update_icons()
	QDEL_NULL(alert_light)
	if(combat_mode)
		icon_state = "[initial(icon_state)]_attack"
		alert_light = mob_light(6, 0.4, COLOR_RED_LIGHT)
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	..(TRUE)

/mob/living/simple_animal/hostile/hivebot/range
	name = "hivebot"
	desc = "A smallish robot, this one is armed!"
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = TRUE
	rapid = 3
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "strong hivebot"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	ranged = TRUE

/mob/living/simple_animal/hostile/hivebot/mechanic
	name = "hivebot mechanic"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "A robot built for base upkeep, intended for use inside hivebot colonies."
	health = 60
	maxHealth = 60
	ranged = TRUE
	rapid = 3
	gold_core_spawnable = HOSTILE_SPAWN
	var/datum/action/innate/hivebot/foamwall/foam

/mob/living/simple_animal/hostile/hivebot/mechanic/Initialize(mapload)
	. = ..()
	foam = new
	foam.Grant(src)

/mob/living/simple_animal/hostile/hivebot/mechanic/AttackingTarget()
	if(ismachinery(target))
		var/obj/machinery/fixable = target
		if(fixable.get_integrity() >= fixable.max_integrity)
			to_chat(src, span_warning("Diagnostics indicate that this machine is at peak integrity."))
			return
		to_chat(src, span_warning("You begin repairs..."))
		if(do_after(src, 50, target = fixable))
			fixable.repair_damage(fixable.max_integrity - fixable.get_integrity())
			do_sparks(3, TRUE, fixable)
			to_chat(src, span_warning("Repairs complete."))
		return
	if(istype(target, /mob/living/simple_animal/hostile/hivebot))
		var/mob/living/simple_animal/hostile/hivebot/fixable = target
		if(fixable.health >= fixable.maxHealth)
			to_chat(src, span_warning("Diagnostics indicate that this unit is at peak integrity."))
			return
		to_chat(src, span_warning("You begin repairs..."))
		if(do_after(src, 50, target = fixable))
			fixable.revive(HEAL_ALL)
			do_sparks(3, TRUE, fixable)
			to_chat(src, span_warning("Repairs complete."))
		return
	return ..()

/datum/action/innate/hivebot
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"

/datum/action/innate/hivebot/foamwall
	name = "Foam Wall"
	desc = "Creates a foam wall that resists against the vacuum of space."

/datum/action/innate/hivebot/foamwall/Activate()
	var/mob/living/simple_animal/hostile/hivebot/H = owner
	var/turf/T = get_turf(H)
	if(T.density)
		to_chat(H, span_warning("There's already something on this tile!"))
		return
	to_chat(H, span_warning("You begin to create a foam wall at your position..."))
	if(do_after(H, 50, target = H))
		for(var/obj/structure/foamedmetal/FM in T.contents)
			to_chat(H, span_warning("There's already a foam wall on this tile!"))
			return
		new /obj/structure/foamedmetal(H.loc)
		playsound(get_turf(H), 'sound/effects/extinguish.ogg', 50, TRUE, -1)
