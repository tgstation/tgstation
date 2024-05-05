/mob/living/basic/red_rabbit
	name = "jabberwocky"
	desc = "Servant of the moon."
	icon = 'monkestation/icons/bloodsuckers/red_rabbit.dmi'
	icon_state = "red_rabbit"

	health = 500
	maxHealth = 500
	speed = 5
	unsuitable_atmos_damage = NONE
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speak_emote = list("roars")

	armour_penetration = 40
	melee_damage_upper = 40
	melee_damage_lower = 40
	obj_damage = 400

	faction = list(FACTION_RABBITS)
	death_message = "succumbs to the moonlight."
	death_sound = 'sound/effects/gravhit.ogg'
	environment_smash = ENVIRONMENT_SMASH_WALLS
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	pixel_x = -16
	base_pixel_x = -16

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	ai_controller = /datum/ai_controller/basic_controller/red_rabbit
	basic_mob_flags = DEL_ON_DEATH

	///Ability to make rabbit holes
	var/datum/action/cooldown/spell/pointed/red_rabbit_hole/hole_power
	///Ability that makes more rabbits
	var/datum/action/cooldown/spell/rabbit_spawn/rabbit_power
	///Red card shotgun blast attack
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/red_rabbit/cards_power
	///Charge attack
	var/datum/action/cooldown/mob_cooldown/charge/rabbit/spear_power

/mob/living/basic/red_rabbit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
	hole_power = new
	rabbit_power = new
	cards_power = new
	spear_power = new
	cards_power.Grant(src)
	hole_power.Grant(src)
	rabbit_power.Grant(src)
	spear_power.Grant(src)
