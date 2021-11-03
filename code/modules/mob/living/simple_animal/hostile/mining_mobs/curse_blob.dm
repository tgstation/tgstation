/mob/living/simple_animal/hostile/asteroid/curseblob
	name = "curse mass"
	desc = "A mass of purple... smoke?"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "curseblob"
	icon_living = "curseblob"
	icon_aggro = "curseblob"
	mob_biotypes = MOB_SPIRIT
	move_to_delay = 5
	vision_range = 20
	aggro_vision_range = 20
	maxHealth = 40 //easy to kill, but oh, will you be seeing a lot of them.
	health = 40
	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_damage_type = BURN
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/effects/curseattack.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	throw_message = "passes through the smokey body of"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	sentience_type = SENTIENCE_BOSS
	layer = LARGE_MOB_LAYER
	var/mob/living/set_target

/mob/living/simple_animal/hostile/asteroid/curseblob/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 60 SECONDS)
	AddElement(/datum/element/simple_flying)
	playsound(src, 'sound/effects/curse1.ogg', 100, TRUE, -1)

/mob/living/simple_animal/hostile/asteroid/curseblob/Destroy()
	new /obj/effect/temp_visual/dir_setting/curse/blob(loc, dir)
	return ..()

/mob/living/simple_animal/hostile/asteroid/curseblob/Goto(move_target, delay, minimum_distance) //Observe
	if(check_for_target())
		return
	move_loop(target, delay)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/move_loop(move_target, delay)
	var/datum/move_loop/new_loop = force_move(src, set_target, delay, override = FALSE)
	if(!new_loop)
		return
	RegisterSignal(new_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/check_target)
	RegisterSignal(new_loop, COMSIG_PARENT_QDELETING, .proc/handle_loop_end)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/check_target()
	SIGNAL_HANDLER
	if(set_target.stat != CONSCIOUS || z != set_target.z)
		return MOVELOOP_STOP_PROCESSING

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/handle_loop_end()
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/check_for_target()
	if(QDELETED(src))
		return TRUE
	if(QDELETED(set_target) || set_target.stat != CONSCIOUS || z != set_target.z)
		qdel(src)
		return TRUE

/mob/living/simple_animal/hostile/asteroid/curseblob/GiveTarget(new_target)
	if(check_for_target())
		return
	new_target = set_target
	. = ..()
	Goto(target, move_to_delay)

/mob/living/simple_animal/hostile/asteroid/curseblob/LoseTarget() //we can't lose our target!
	if(check_for_target())
		return

//if it's not our target, we ignore it
/mob/living/simple_animal/hostile/asteroid/curseblob/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == set_target)
		return FALSE
	if(istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if(P.firer == set_target)
			return FALSE

#define IGNORE_PROC_IF_NOT_TARGET(X) /mob/living/simple_animal/hostile/asteroid/curseblob/##X(AM) { if (AM == set_target) return ..(); }

IGNORE_PROC_IF_NOT_TARGET(attack_hand)

IGNORE_PROC_IF_NOT_TARGET(attack_hulk)

IGNORE_PROC_IF_NOT_TARGET(attack_paw)

IGNORE_PROC_IF_NOT_TARGET(attack_alien)

IGNORE_PROC_IF_NOT_TARGET(attack_larva)

IGNORE_PROC_IF_NOT_TARGET(attack_animal)

IGNORE_PROC_IF_NOT_TARGET(attack_slime)

/mob/living/simple_animal/hostile/asteroid/curseblob/bullet_act(obj/projectile/Proj)
	if(Proj.firer != set_target)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/curseblob/attacked_by(obj/item/I, mob/living/L)
	if(L != set_target)
		return
	return ..()

#undef IGNORE_PROC_IF_NOT_TARGET
