
/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, MELEE, 1, get_dir(src, AM))

/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return

	. = ..() //contents explosion
	if(QDELETED(src))
		return
	if(target == src)
		take_damage(INFINITY, BRUTE, BOMB, 0)
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)

/obj/bullet_act(obj/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, TRUE)
	var/no_damage = FALSE
	if(!QDELETED(src) && !take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180), P.armour_penetration)) //Bullet on_hit effect might have already destroyed this object
		no_damage = TRUE
	if(P.suppressed != SUPPRESSED_VERY)
		visible_message(span_danger("[src] is hit by \a [P][no_damage ? ", which doesn't leave a mark" : ""]!"), null, null, COMBAT_MESSAGE_RANGE)

/obj/attack_hulk(mob/living/carbon/human/user)
	..()
	user.visible_message(span_danger("[user] smashes [src]!"), span_danger("You smash [src]!"), null, COMBAT_MESSAGE_RANGE)
	if(density)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
	return TRUE

/obj/blob_act(obj/structure/blob/B)
	if (!..())
		return
	if(isturf(loc))
		var/turf/T = loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/attack_alien(mob/living/carbon/alien/humanoid/user, list/modifiers)
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, TRUE)

/obj/attack_basic_mob(mob/living/basic/user, list/modifiers)
	if(!user.melee_damage_upper && !user.obj_damage) //No damage
		user.emote("custom", message = "[user.friendly_verb_continuous] [src].")
		return FALSE
	else
		if(user.obj_damage)
			. = attack_generic(user, user.obj_damage, user.melee_damage_type, MELEE, TRUE, user.armour_penetration)
		else
			. = attack_generic(user, rand(user.melee_damage_lower,user.melee_damage_upper), user.melee_damage_type, MELEE,TRUE, user.armour_penetration)
		if(.)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)

/obj/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(!user.melee_damage_upper && !user.obj_damage)
		user.emote("custom", message = "[user.friendly_verb_continuous] [src].")
		return FALSE
	else
		var/play_soundeffect = TRUE
		if(user.environment_smash)
			play_soundeffect = FALSE
		if(user.obj_damage)
			. = attack_generic(user, user.obj_damage, user.melee_damage_type, MELEE, play_soundeffect, user.armour_penetration)
		else
			. = attack_generic(user, rand(user.melee_damage_lower,user.melee_damage_upper), user.melee_damage_type, MELEE, play_soundeffect, user.armour_penetration)
		if(. && !play_soundeffect)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		if(user.client)
			log_combat(user, src, "attacked")

/obj/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return TRUE

/obj/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	collision_damage(pusher, force, direction)
	return TRUE

/obj/proc/collision_damage(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	var/amt = max(0, ((force - (move_resist * MOVE_FORCE_CRUSH_RATIO)) / (move_resist * MOVE_FORCE_CRUSH_RATIO)) * 10)
	take_damage(amt, BRUTE)

/obj/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	attack_generic(user, rand(10, 15), BRUTE, MELEE, 1)


/obj/singularity_act()
	SSexplosions.high_mov_atom += src
	if(src && !QDELETED(src))
		qdel(src)
	return 2


///// ACID

GLOBAL_DATUM_INIT(acid_overlay, /mutable_appearance, mutable_appearance('icons/effects/effects.dmi', "acid"))

///the obj's reaction when touched by acid
/obj/acid_act(acidpwr, acid_volume)
	. = ..()
	if((resistance_flags & UNACIDABLE) || (acid_volume <= 0) || acidpwr <= 0)
		return FALSE

	AddComponent(/datum/component/acid, acidpwr, acid_volume)
	return TRUE

///called when the obj is destroyed by acid.
/obj/proc/acid_melt()
	deconstruct(FALSE)

//// FIRE

///Called when the obj is exposed to fire.
/obj/fire_act(exposed_temperature, exposed_volume)
	if(isturf(loc))
		var/turf/T = loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		resistance_flags |= ON_FIRE
		SSfire_burning.processing[src] = src
		update_appearance()
		return 1
	return ..()

///called when the obj is destroyed by fire
/obj/proc/burn()
	if(resistance_flags & ON_FIRE)
		SSfire_burning.processing -= src
	deconstruct(FALSE)

///Called when the obj is no longer on fire.
/obj/proc/extinguish()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		update_appearance()
		SSfire_burning.processing -= src

///Called when the obj is hit by a tesla bolt.
/obj/zap_act(power, zap_flags)
	if(QDELETED(src))
		return 0
	obj_flags |= BEING_SHOCKED
	addtimer(CALLBACK(src, .proc/reset_shocked), 1 SECONDS)
	return power / 2

//The surgeon general warns that being buckled to certain objects receiving powerful shocks is greatly hazardous to your health
///Only tesla coils, vehicles, and grounding rods currently call this because mobs are already targeted over all other objects, but this might be useful for more things later.
/obj/proc/zap_buckle_check(strength)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act((clamp(round(strength/400), 10, 90) + rand(-5, 5)), src, flags = SHOCK_TESLA)

/obj/proc/reset_shocked()
	obj_flags &= ~BEING_SHOCKED

///the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)

///what happens when the obj's integrity reaches zero.
/obj/atom_destruction(damage_flag)
	if(damage_flag == ACID)
		acid_melt()
	else if(damage_flag == FIRE)
		burn()
	else
		deconstruct(FALSE)

///returns how much the object blocks an explosion. Used by subtypes.
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
