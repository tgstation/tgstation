/mob/living/simple_animal/hostile/asteroid/curseblob
	name = "curse mass"
	desc = "A mass of purple... smoke?"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "curseblob"
	icon_living = "curseblob"
	icon_aggro = "curseblob"
	mob_biotypes = MOB_SPIRIT
	move_to_delay = 2.5
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
	var/datum/move_loop/has_target/force_move/our_loop

/mob/living/simple_animal/hostile/asteroid/curseblob/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 60 SECONDS)
	AddElement(/datum/element/simple_flying)
	playsound(src, 'sound/effects/curse1.ogg', 100, TRUE, -1)

/mob/living/simple_animal/hostile/asteroid/curseblob/Destroy()
	new /obj/effect/temp_visual/dir_setting/curse/blob(loc, dir)
	set_target = null
	return ..()

/mob/living/simple_animal/hostile/asteroid/curseblob/Goto(move_target, delay, minimum_distance) //Observe
	if(check_for_target())
		return
	move_loop(target, delay)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/move_loop(move_target, delay)
	if(our_loop)
		return
	our_loop = SSmove_manager.force_move(src, move_target, delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!our_loop)
		return
	RegisterSignal(move_target, COMSIG_MOB_STATCHANGE, .proc/stat_change)
	RegisterSignal(move_target, COMSIG_MOVABLE_Z_CHANGED, .proc/target_z_change)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/our_z_change)
	RegisterSignal(our_loop, COMSIG_PARENT_QDELETING, .proc/handle_loop_end)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/stat_change(datum/source, new_stat)
	SIGNAL_HANDLER
	if(new_stat != CONSCIOUS)
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/target_z_change(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/our_z_change(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/handle_loop_end()
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/curseblob/handle_target_del(datum/source)
	. = ..()
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/curseblob/proc/check_for_target()
	if(QDELETED(src) || !set_target)
		return TRUE
	if(set_target.stat != CONSCIOUS)
		return TRUE
	if(set_target.z != z)
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
