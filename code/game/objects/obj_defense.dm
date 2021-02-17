
///the essential proc to call when an obj must receive damage of any kind.
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if((resistance_flags & INDESTRUCTIBLE) || obj_integrity <= 0)
		return
	damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
	if(damage_amount < DAMAGE_PRECISION)
		return
	if(SEND_SIGNAL(src, COMSIG_OBJ_TAKE_DAMAGE, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration) & COMPONENT_NO_TAKE_DAMAGE)
		return

	. = damage_amount
	obj_integrity = max(obj_integrity - damage_amount, 0)
	//BREAKING FIRST
	if(integrity_failure && obj_integrity <= integrity_failure * max_integrity)
		obj_break(damage_flag)
	//DESTROYING SECOND
	if(obj_integrity <= 0)
		obj_destruction(damage_flag)

///returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	if(damage_flag == MELEE && damage_amount < damage_deflection)
		return 0
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection) //Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp(armor_protection - armour_penetration, min(armor_protection, 0), 100)
	return round(damage_amount * (100 - armor_protection)*0.01, DAMAGE_PRECISION)

///the sound played when the obj is damaged.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, MELEE, 1, get_dir(src, AM))

/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	..() //contents explosion
	if(QDELETED(src))
		return
	if(target == src)
		take_damage(INFINITY, BRUTE, BOMB, 0)
		return
	switch(severity)
		if(1)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(2)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)

/obj/bullet_act(obj/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, TRUE)
	if(P.suppressed != SUPPRESSED_VERY)
		visible_message("<span class='danger'>[src] is hit by \a [P]!</span>", null, null, COMBAT_MESSAGE_RANGE)
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180), P.armour_penetration)

///Called to get the damage that hulks will deal to the obj.
/obj/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this object, is affected by melee armor

/obj/attack_hulk(mob/living/carbon/human/user)
	..()
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>", "<span class='danger'>You smash [src]!</span>", null, COMBAT_MESSAGE_RANGE)
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
		if(T.intact && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armor_penetration)

/obj/attack_alien(mob/living/carbon/alien/humanoid/user, list/modifiers)
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, TRUE)

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
		if(T.intact && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		resistance_flags |= ON_FIRE
		SSfire_burning.processing[src] = src
		update_icon()
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
		update_icon()
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

///called after the obj takes damage and integrity is below integrity_failure level
/obj/proc/obj_break(damage_flag)
	return

///what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_flag)
	if(damage_flag == ACID)
		acid_melt()
	else if(damage_flag == FIRE)
		burn()
	else
		deconstruct(FALSE)

///changes max_integrity while retaining current health percentage, returns TRUE if the obj got broken.
/obj/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE)
	var/current_integrity = obj_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max)) //don't destroy it as a result
		obj_integrity = current_integrity

	max_integrity = new_max

	if(can_break && integrity_failure && current_integrity <= integrity_failure * max_integrity)
		obj_break(damage_type)
		return TRUE
	return FALSE

///returns how much the object blocks an explosion. Used by subtypes.
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
