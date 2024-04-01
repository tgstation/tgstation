/mob/living/basic/frieza
	name = "Frieza"
	desc = "A self-proclaimed emperor of the universe. He's angry at Nanotrasen now for some reason."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "frieza"
	icon_living = "frieza"
	icon_dead = "frieza"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 400
	health = 400
	basic_mob_flags = DEL_ON_DEATH
	speed = 0
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	melee_attack_cooldown = 0.2 SECONDS
	combat_mode = TRUE
	pressure_resistance = 200
	obj_damage = 1000
	habitable_atmos = null
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500

/mob/living/basic/frieza/Initialize(mapload)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)
	. = ..()
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP, TRAIT_SPACEWALK), INNATE_TRAIT)
	AddElement(/datum/element/wall_tearer, allow_reinforced = TRUE)
	AddElement(/datum/element/dextrous)
	AddElement(/datum/element/footstep, volume = 7.5, footstep_type = FOOTSTEP_MOB_FRIEZA)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_PURPLE)
	AddComponent(/datum/component/personal_crafting)
	AddComponent(/datum/component/basic_inhands)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno,
	)

	grant_actions_by_list(innate_actions)

	RegisterSignal(src, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/mob/living/basic/frieza/proc/on_ranged_attack(mob/living/basic/frieza/source, atom/target, modifiers)
	SIGNAL_HANDLER

	if(!source.combat_mode)
		return
	to_chat(source, span_warning("You shoot with your laser eyes!"))
	source.changeNext_move(CLICK_CD_RANGE)
	source.newtonian_move(get_dir(target, source))
	var/obj/projectile/beam/laser/laser_eyes/LE = new(source.loc)
	LE.firer = source
	LE.def_zone = ran_zone(source.zone_selected)
	LE.preparePixelProjectile(target, source, modifiers)
	INVOKE_ASYNC(LE, TYPE_PROC_REF(/obj/projectile, fire))
	playsound(source, 'sound/weapons/taser2.ogg', 75, TRUE)
